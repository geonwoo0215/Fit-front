import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fit_fe/pages/password_update_page.dart';
import 'package:flutter/material.dart';

class FindPasswordEmailVerificationPage extends StatefulWidget {
  final String email;

  FindPasswordEmailVerificationPage(this.email);

  @override
  _FindPasswordEmailVerificationPageState createState() =>
      _FindPasswordEmailVerificationPageState();
}

class _FindPasswordEmailVerificationPageState
    extends State<FindPasswordEmailVerificationPage> {
  bool _isTimerRunning = true;
  int _timerSeconds = 300;
  late Timer _timer;

  Dio dio = Dio();

  TextEditingController _verificationCodeController = TextEditingController();

  bool _isVerificationCodeComplete() {
    return _verificationCodeController.text.length == 5;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer.cancel();
          _isTimerRunning = false;
        }
      });
    });
  }

  void checkCode() async {
    try {
      Response response = await dio.post(
        'https://fitcorp.xyz/members/email',
        data: {'email': widget.email, 'code': _verificationCodeController.text},
      );

      if (response.statusCode == 200) {
        print('API call successful: ${response.data}');
        _navigateToPasswordUpdatePage();
      } else {
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling API: $e');
    }
  }

  void _navigateToPasswordUpdatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordUpdatePage(widget.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('이메일 인증'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                '이메일로 전송된 인증번호를 입력해주세요.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  labelText: '인증번호',
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
                keyboardType: TextInputType.number,
                onChanged: (value) {},
              ),
            ),
            SizedBox(height: 16.0),
            _isTimerRunning
                ? Text(
                    '남은 시간: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 14.0),
                  )
                : Text('시간 초과'),
            SizedBox(height: 16.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_isTimerRunning && _isVerificationCodeComplete()) {
                    checkCode();
                  } else {
                    if (!_isTimerRunning) {
                      print('Timer has expired');
                    } else {
                      print('Please fill in the verification code box');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
