import 'package:dio/dio.dart';
import 'package:fit_fe/handler/token_refresh_handler.dart';
import 'package:fit_fe/models/board_response.dart';
import 'package:fit_fe/models/member_response.dart';
import 'package:fit_fe/models/page_response.dart';
import 'package:fit_fe/pages/cloth_page.dart';
import 'package:fit_fe/pages/my_board_page.dart';
import 'package:fit_fe/pages/password_input_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Dio dio = Dio();
  List<BoardResponse> boardResponses = [];
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool isLoading = true;
  late MemberResponse memberResponse = MemberResponse(email: '', nickname: '');

  @override
  void initState() {
    super.initState();
    fetchMyProfile();
  }

  Future<void> fetchMyBoards() async {
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        'http://10.0.2.2:8080/boards',
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
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        await fetchMyBoards();
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

  void _navigateToClothsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClothsPage(),
      ),
    );
  }

  void _logout() async {
    try {
      String? jwtToken = await _secureStorage.read(key: 'jwt_token');

      final response = await dio.post('https://fitcorp.xyz/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $jwtToken',
            },
            validateStatus: (status) {
              return status == 302 || status == 200;
            },
          ));

      if (response.statusCode == 302) {
        await _secureStorage.delete(key: 'jwt_token');
        print('로그아웃 성공. 상태 코드: ${response.statusCode}');
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        _logout();
      } else {
        print('로그아웃 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }

  Future<void> fetchMyProfile() async {
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        'https://fitcorp.xyz/members/my-profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
          validateStatus: (status) {
            return status == 401 || status == 200 || status == 400;
          },
        ),
      );

      if (response.statusCode == 200) {
        print('프로필을 성공적으로 가져왔습니다. 응답 데이터: ${response.data}');
        memberResponse = MemberResponse.fromJson(response.data['data']);
        setState(() {
          isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        await TokenRefreshHandler.refreshAccessToken(context);
        await fetchMyProfile();
      } else {
        print('프로필을 가져오지 못했습니다. 상태 코드: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('프로필을 가져오지 못했습니다.: $error');
      setState(() {
        isLoading = false;
      });
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
          isLoading
              ? Text('Loading...')
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar(
                    //   radius: 50,
                    //   backgroundImage: AssetImage('assets/default_profile.png'),
                    // ),
                    SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memberResponse.nickname,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          memberResponse.email,
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
          Row(
            children: [
              ElevatedButton(
                onPressed: _navigateToMyBoardsPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black),
                ),
                child: Text('내 게시물 보기'),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: _navigateToClothsPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black),
                ),
                child: Text('내 옷 보기'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          TextButton(
            onPressed: _logout,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('로그아웃'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PasswordInputPage(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('회원탈퇴'),
          ),
        ],
      ),
    );
  }
}
