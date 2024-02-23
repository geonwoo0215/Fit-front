import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fit_fe/models/board_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fit_fe/models/page_response.dart';
import 'package:fit_fe/pages/my_board_page.dart';
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Dio dio = Dio();
  List<BoardResponse> boardResponses = [];
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyBoards();
  }

  Future<void> fetchMyBoards() async {
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        'https://10.0.2.2:8080/boards',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
        queryParameters: {'mine': true},
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

  void _navigateToMyBoardsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyBoardsPage(boardResponses: boardResponses),
      ),
    );
  }

  void _logout() async {
    try {
      String? jwtToken = await _secureStorage.read(key: 'jwt_token');

      final response = await dio.post(
        'http://10.0.2.2:8080/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
          validateStatus: (status) {
            return status == 302 || status == 200;
          },
        )
      );

      if (response.statusCode == 302) {
        await _secureStorage.delete(key: 'jwt_token');
        print('로그아웃 성공. 상태 코드: ${response.statusCode}');
        Navigator.pushReplacementNamed(context, '/login');
        
      } else {
        print('로그아웃 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사용자 이름',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '이메일 주소',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _navigateToMyBoardsPage,
            style: ElevatedButton.styleFrom(
              primary: Colors.white, // Background color
              onPrimary: Colors.black, // Text color
              side: BorderSide(color: Colors.black), // Border color
            ),
            child: Text('내 게시물 보기'),
          ),
          SizedBox(height: 16.0),
          TextButton(
            onPressed: _logout,
            style: TextButton.styleFrom(
              primary: Colors.red, // Text color
            ),
            child: Text('로그아웃'),
          ),

        ],
      ),
    );
  }
}