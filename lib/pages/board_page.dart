import 'package:flutter/material.dart';
import 'package:fit_fe/models/board_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fit_fe/pages/board_detail_page.dart';
import 'package:fit_fe/models/page_response.dart';
import 'package:fit_fe/handler/token_refresh_handler.dart';
class BoardPage extends StatefulWidget {
  @override
  _BoardListPageState createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<BoardResponse> boardResponses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBoardContents();
  }

  Future<void> fetchBoardContents() async {
    final dio = Dio();
    const String apiUrl = 'http://10.0.2.2:8080/boards';

    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
          validateStatus: (status) {
            return status == 401 || status == 200 || status ==400;
          },
        ),

      );

      if (response.statusCode == 200) {
        PageResponse pageResponse = PageResponse.fromJson(response.data);

        print('Raw Response: ${response.data.toString()}');

        setState(() {
          isLoading = false;
          boardResponses = pageResponse.content;
        });
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        await fetchBoardContents();
      } else {
        print('게시판 목록을 가져오지 못했습니다. 상태 코드: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('게시판 목록을 가져오지 못했습니다.: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : (boardResponses.isEmpty
              ? Center(child: Text('에러 또는 데이터를 불러올 수 없습니다.'))
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 0.8,
            ),
            itemCount: boardResponses.length,
            itemBuilder: (context, index) {
              BoardResponse board = boardResponses[index];
              return _buildGridItem(board);
            },
          )),
        ),
      ],
    );
  }

  Widget _buildGridItem(BoardResponse board) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BoardDetailPage(board: board),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.network(
                  'https://fit-image-bucket.s3.ap-northeast-2.amazonaws.com/${board.imageUrls.first}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.content,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '날씨: ${board.weather}, 도로 상태: ${board.roadCondition}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}