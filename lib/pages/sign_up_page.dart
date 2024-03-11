import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fit_fe/pages/login_page.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  final String email;

  SignUpPage(this.email);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Dio dio = Dio();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  bool _passwordsMatch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('가입 정보 입력'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  helperText: '영문 대소문자, 숫자, 특수문자를 포함한 8자 이상',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  errorText: !_passwordsMatch ? '비밀번호가 일치하지 않습니다.' : null,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _passwordsMatch = _passwordController.text == value;
                  });
                },
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _handleSignUp(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  '가입 완료',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignUp(BuildContext context) async {
    try {
      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;
      String nickname = _nicknameController.text;

      if (!_passwordsMatch) {
        print('비밀번호가 일치하지 않습니다.');
        return;
      }

      Map<String, dynamic> signUpData = {
        'password': password,
        'email': widget.email,
        'nickname': nickname,
      };

      Response response = await dio.post(
        'https://fitcorp.xyz/members',
        data: jsonEncode(signUpData),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        print('가입 성공: ${response.data}');
        print('가입이 완료되었습니다!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        print('가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during sign-up: $e');
    }
  }
}
