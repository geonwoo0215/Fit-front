import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fit_fe/handler/token_refresh_handler.dart';

class AddClothPage extends StatefulWidget {
  @override
  _AddClothPageState createState() => _AddClothPageState();
}

class _AddClothPageState extends State<AddClothPage> {
  final TextEditingController informationController = TextEditingController();
  final TextEditingController shoeController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<String> clothTypes = ['상의', '하의', '악세사리', '신발'];
  List<String> clothSizes = ['S', 'M', 'L', 'XL'];
  List<String> shoeSizes = ['220', '225', '230', '235', '240', '245', '250', '255','260','265','270','275','280','285','290','295','300'];

  String selectedType = '';
  String selectedSize = '';
  String selectedShoeSize = '';

  final Map<String, String> clothTypeCodes = {
    '상의': '001',
    '하의': '002',
    '악세사리': '003',
    '신발': '004',
  };

  void _addCloth() async {
    final dio = Dio();
    const String apiUrl = 'http://10.0.2.2:8080/cloths';

    String clothTypeCode = clothTypeCodes[selectedType] ?? '';

    Map<String, dynamic> requestData = {
      'type': clothTypeCode,
      'size': selectedSize,
      'information': informationController.text,
      'shoe': shoeController.text == 'true',
    };
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');
    try {
      final response = await dio.post(
        apiUrl,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        Navigator.pop(
            context, true);
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        _addCloth();
      } else {
        print('Failed to add cloth. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to add cloth: $error');
    }
  }

  void _selectClothType(String clothType) {
    setState(() {
      selectedType = clothType;
      selectedSize = '';
      selectedShoeSize = '';
    });
  }

  void _selectSize(String size) {
    setState(() {
      selectedSize = size;
    });
  }

  void _selectShoeSize(String shoeSize) {
    setState(() {
      selectedShoeSize = shoeSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('옷 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('옷 종류'),
            SizedBox(height: 10),
            Wrap(
              children: [
                for (String clothType in clothTypes)
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        _selectClothType(clothType);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType == clothType
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: selectedType == clothType
                            ? Colors.white
                            : Colors.grey,
                      ),
                      child: Text(clothType),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (selectedType != '신발')
              Column(
                children: [
                  Text('사이즈'),
                  SizedBox(height: 10),
                  Wrap(
                    children: [
                      for (String size in clothSizes)
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              _selectSize(size);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedSize == size
                                  ? Colors.black
                                  : Colors.white,
                              foregroundColor: selectedSize == size
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            child: Text(size),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            if (selectedType == '신발')
              Column(
                children: [
                  Text('신발 사이즈'),
                  SizedBox(height: 10),
                  Wrap(
                    children: [
                      for (String shoeSize in shoeSizes)
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              _selectShoeSize(shoeSize);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedShoeSize == shoeSize
                                  ? Colors.black
                                  : Colors.white,
                              foregroundColor: selectedShoeSize == shoeSize
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            child: Text(shoeSize),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 16),
            TextField(
              controller: informationController,
              decoration: InputDecoration(
                labelText: '옷 정보',
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCloth,
              child: Text(
                '추가',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
