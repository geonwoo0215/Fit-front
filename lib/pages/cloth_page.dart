import 'package:dio/dio.dart';
import 'package:fit_fe/handler/token_refresh_handler.dart';
import 'package:fit_fe/models/cloth_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'add_cloth_page.dart';

class ClothsPage extends StatefulWidget {
  @override
  _ClothsPageState createState() => _ClothsPageState();
}

class _ClothsPageState extends State<ClothsPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<ClothResponse> clothResponses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClothContents(null);
  }

  Future<void> fetchClothContents(String? clothType) async {
    final dio = Dio();
    const String apiUrl = 'https://fitcorp.xyz/cloths';

    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        apiUrl,
        queryParameters: {
          'type': clothType,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data['data'];
        setState(() {
          clothResponses =
              jsonResponse.map((item) => ClothResponse.fromJson(item)).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        await fetchClothContents(clothType);
      } else {
        print(
            'Failed to fetch cloth list. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Failed to fetch cloth list: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToAddClothPage() async {
    bool refreshClothList = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddClothPage()),
    );

    if (refreshClothList == true) {
      fetchClothContents(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('옷 목록'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _navigateToAddClothPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: Text(
              '옷 추가',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : (clothResponses.isEmpty
                    ? Center(child: Text('에러 또는 데이터를 불러올 수 없습니다.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: clothResponses.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(clothResponses[index].information),
                            subtitle: Text(
                                '옷 종류: ${clothResponses[index].type}, Size: ${clothResponses[index].size}'),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
