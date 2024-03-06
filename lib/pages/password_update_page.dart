import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fit_fe/pages/login_page.dart';
import 'package:flutter/material.dart';

class PasswordUpdatePage extends StatefulWidget {
  final String email;

  PasswordUpdatePage(this.email);

  @override
  _PasswordUpdatePageState createState() => _PasswordUpdatePageState();
}

class _PasswordUpdatePageState extends State<PasswordUpdatePage> {
  final Dio dio = Dio();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _passwordsMatch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('비밀번호 변경'),
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
                  labelText: '새 비밀번호',
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
                  labelText: '새 비밀번호 확인',
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
                  '비밀번호 변경 완료',
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

      if (!_passwordsMatch) {
        print('비밀번호가 일치하지 않습니다.');
        return;
      }

      Map<String, dynamic> updateData = {
        'email': widget.email,
        'password': password,
      };

      Response response = await dio.patch(
        'http://10.0.2.2:8080/members/password',
        data: jsonEncode(updateData),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 204) {
        print('비밀번호 변경을 성공하였습니다.!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        print('비밀번호 변경 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('Error ㅎ: $e');
    }
  }
}
