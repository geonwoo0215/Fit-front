import 'package:flutter/material.dart';
import 'package:fit_fe/pages/email_verification_page.dart';
import 'package:dio/dio.dart';

class EmailInputPage extends StatefulWidget {
  @override
  _EmailInputPageState createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  final TextEditingController _signupEmailController = TextEditingController();
  bool _isEmailValid = true;
  Dio dio = Dio();

  void _validateEmail(String email) {
    bool isValid =
        RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);

    setState(() {
      _isEmailValid = isValid;
    });
  }

  Future<void> sendEmail() async {
    try {
      await dio.get(
        'http://10.0.2.2:8080/members/email',
        queryParameters: {'email': _signupEmailController.text},
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EmailVerificationPage(_signupEmailController.text),
        ),
      );
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 400) {
          _showSnackBar('${e.response?.data['message']}');
        } else {
          _showSnackBar('Error sending email: ${e.message}');
        }
      } else {
        _showSnackBar('Error sending email: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // 메시지가 표시되는 시간 설정
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
          children: [
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                '연락 가능한 이메일을 작성해 주세요',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _signupEmailController,
                  onChanged: (value) {
                    _validateEmail(value);
                  },
                  decoration: InputDecoration(
                    labelText: '이메일',
                    errorText: _isEmailValid ? null : '올바른 이메일 형식이 아닙니다.',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  sendEmail();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  '다음',
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
