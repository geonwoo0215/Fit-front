import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fit_fe/pages/email_input_page.dart';
import 'package:fit_fe/pages/find_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FIT', // Your service name
                style: TextStyle(
                  fontSize: 24.0, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text;
                    String password = _passwordController.text;

                    _login(email, password);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FindPasswordPage()),
                        );
                      },
                      child: Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.0),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmailInputPage()),
                        );
                      },
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(String email, String password) async {
    try {
      Dio dio = Dio();
      const String apiUrl = 'http://10.0.2.2:8080/login';

      FormData formData = FormData.fromMap({
        'email': email,
        'password': password,
      });

      Response response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(
          validateStatus: (status) {
            return status == 401 || status == 200 || status == 400;
          },
        ),
      );

      if (response.statusCode == 200) {
        String? authorizationHeader = response.headers.value('Authorization');
        if (authorizationHeader != null) {
          String token = authorizationHeader;
          // 토큰 저장
          await _secureStorage.write(key: 'jwt_token', value: token);
          String? cookieValues = response.headers['set-cookie']?[0];
          Cookie cookie = Cookie.fromSetCookieValue(cookieValues!);
          String cookieString = cookie.toString();
          await _secureStorage.write(key: 'refresh_token', value: cookieString);
          print('로그인 성공 : $token');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print('토큰을 찾을 수 없습니다.');
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              surfaceTintColor: Colors.white,
              title: Text('로그인 실패'),
              content: Text('이메일과 비밀번호를 다시 확인해주세요.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the alert
                  },
                  child: Text('확인', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('오류 발생: $error');
    }
  }
}
