import 'package:flutter/material.dart';
import 'package:fit_fe/models/cloth_response.dart';
import 'package:dio/dio.dart';
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
    const String apiUrl = 'http://10.0.2.2:8080/cloths';

    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        apiUrl,
        queryParameters: {
          'type': clothType, // Add type as a query parameter
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
          clothResponses = jsonResponse.map((item) => ClothResponse.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch cloth list. Status code: ${response.statusCode}');
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
      // 새로 고침이 필요한 경우
      fetchClothContents(null);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _navigateToAddClothPage,
          child: Text('옷 추가'),
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
    );
  }
}