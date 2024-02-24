import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:fit_fe/models/page_response.dart';
import 'package:fit_fe/models/board_response.dart';
import 'package:fit_fe/pages/board_detail_page.dart';

class RankPage extends StatefulWidget {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<BoardResponse> boardResponses = [];
  bool isLoading = true;

  bool isDailyRankingSelected = true;

  @override
  void initState() {
    super.initState();
    fetchRankContents();
  }

  Future<void> fetchRankContents() async {
    final dio = Dio();
    const String apiUrl = '';
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
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

  Widget _buildGrid(List<BoardResponse> boards) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        return _buildGridItem(boards[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isDailyRankingSelected = true;
                  isLoading = true;
                });
                fetchRankContents();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDailyRankingSelected ? Colors.black : Colors.white,
                foregroundColor: isDailyRankingSelected ? Colors.white : Colors.black,
                side: BorderSide(color: Colors.black),
              ),
              child: Text('일간 랭킹'),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isDailyRankingSelected = false;
                  isLoading = true;
                });
                fetchRankContents();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !isDailyRankingSelected ? Colors.black : Colors.white,
                foregroundColor: !isDailyRankingSelected ? Colors.white : Colors.black,
                side: BorderSide(color: Colors.black),
              ),
              child: Text('주간 랭킹'),
            ),
          ],
        ),
        isLoading
            ? CircularProgressIndicator()
            : Expanded(
          child: _buildGrid(boardResponses),
        ),
      ],
    );
  }
}