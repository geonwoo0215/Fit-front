import 'package:fit_fe/pages/home_page.dart';
import 'package:fit_fe/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTokenValid = checkTokenValidity();

    return MaterialApp(
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
    return false;
  }
}
