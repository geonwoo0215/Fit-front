import 'package:flutter/material.dart';
import 'package:fit_fe/pages/login_page.dart';
import 'package:fit_fe/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTokenValid = checkTokenValidity();

    return MaterialApp(
      // 조건부로 홈 페이지 또는 로그인 페이지를 반환합니다.
      home: isTokenValid ? HomePage() : LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
      theme: ThemeData(
        primaryColor: Colors.blue,

      ),
    );
  }

  bool checkTokenValidity() {
    // 여기에서 실제 토큰 유효성을 확인하는 로직을 구현합니다.
    // 이 예시에서는 항상 false를 반환하도록 되어 있습니다.
    // 실제로는 토큰이 유효한지 여부를 확인하는 로직을 작성해야 합니다.
    return false;
  }
}