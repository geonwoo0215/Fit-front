import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fit_fe/pages/login_page.dart';

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
                decoration: InputDecoration(labelText: '닉네임'),
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
        // 비밀번호 확인이 일치하지 않을 경우 처리
        print('비밀번호가 일치하지 않습니다.');
        return;
      }

      Map<String, dynamic> signUpData = {
        'password': password,
        'email': widget.email,
        'nickname': nickname,
      };

      Response response = await dio.post(
        'http://10.0.2.2:8080/members',
        data: jsonEncode(signUpData),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        print('가입 성공: ${response.data}');
        print('가입이 완료되었습니다!');
        // 가입 성공 시 다음 페이지로 이동하거나 성공 메시지를 표시할 수 있습니다.
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        print('가입 실패: ${response.statusCode}');
        // 실패 시 사용자에게 알림을 표시할 수 있습니다.
      }
    } catch (e) {
      print('Error during sign-up: $e');
      // 예외 발생 시 사용자에게 알림을 표시할 수 있습니다.
    }
  }
}