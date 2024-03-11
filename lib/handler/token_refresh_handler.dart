import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRefreshHandler {
  static final Dio dio = Dio();

  static Future<void> refreshAccessToken(BuildContext context) async {
    final _secureStorage = FlutterSecureStorage();

    String? refreshToken = await _secureStorage.read(key: 'refresh_token');
    Cookie cookie = Cookie.fromSetCookieValue(refreshToken!);
    var value = cookie.value;
    print('refreshtoken = $value');
    try {
      final response = await dio.post(
        'https://fitcorp.xyz:8080/members/tokens',
        options: Options(
          headers: {
            HttpHeaders.cookieHeader: 'refreshToken=$value',
          },
          validateStatus: (status) {
            return status == 401 || status == 201;
          },
        ),
      );

      if (response.statusCode == 201) {
        print('Token refresh success.');
        String? newAccessToken = response.headers.value('Authorization');
        await _secureStorage.write(key: 'jwt_token', value: newAccessToken);
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('Token refresh failed. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Token refresh failed. Error: $error');
    }
  }
}
