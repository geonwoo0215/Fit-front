import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  List<String> shoeSizes = ['220', '230', '240', '250'];

  String selectedType = '';
  String selectedSize = '';
  String selectedShoeSize = '';

  // Map of cloth types to their codes
  final Map<String, String> clothTypeCodes = {
    '상의': '001',
    '하의': '002',
    '악세사리': '003',
    '신발': '004',
  };

  void _addCloth() async {
    final dio = Dio();
    const String apiUrl = 'http://10.0.2.2:8080/cloths';

    // Use the mapped code for the selected cloth type
    String clothTypeCode = clothTypeCodes[selectedType] ?? '';

    // TODO: Replace the following values with actual data
    Map<String, dynamic> requestData = {
      'type': clothTypeCode,
      'size': selectedSize,
      'information': informationController.text,
      'shoe': shoeController.text == 'true', // Convert to Boolean
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
        // Cloth added successfully
        Navigator.pop(context, true);// Close the AddClothPage after successful addition
      } else {
        // Handle error
        print('Failed to add cloth. Status code: ${response.statusCode}');
        // TODO: Add error handling based on your requirements
      }
    } catch (error) {
      print('Failed to add cloth: $error');
      // TODO: Add error handling based on your requirements
    }
  }

  void _selectClothType(String clothType) {
    setState(() {
      selectedType = clothType;
      selectedSize = ''; // Reset selected size when cloth type changes
      selectedShoeSize = ''; // Reset selected shoe size when cloth type changes
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
      appBar: AppBar(
        title: Text('옷 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('옷 종류'),
            SizedBox(height: 10),
            Row(
              children: [
                for (String clothType in clothTypes)
                  ElevatedButton(
                    onPressed: () {
                      _selectClothType(clothType);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedType == clothType ? Colors.green : null,
                    ),
                    child: Text(clothType),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (selectedType != '신발')
              Column(
                children: [
                  Text('사이즈'),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      for (String size in clothSizes)
                        ElevatedButton(
                          onPressed: () {
                            _selectSize(size);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedSize == size ? Colors.green : null,
                          ),
                          child: Text(size),
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
                  Row(
                    children: [
                      for (String shoeSize in shoeSizes)
                        ElevatedButton(
                          onPressed: () {
                            _selectShoeSize(shoeSize);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedShoeSize == shoeSize ? Colors.green : null,
                          ),
                          child: Text(shoeSize),
                        ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 16),
            TextField(
              controller: informationController,
              decoration: InputDecoration(labelText: 'Information'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCloth,
              child: Text('Add Cloth'),
            ),
          ],
        ),
      ),
    );
  }
}