import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fit_fe/models/cloth_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fit_fe/models/save_board_request.dart';

class CreatePostStep2 extends StatefulWidget {
  final String imagePath;

  CreatePostStep2(this.imagePath);

  @override
  _CreatePostStep2State createState() => _CreatePostStep2State();
}

class _CreatePostStep2State extends State<CreatePostStep2> {
  // Controllers for text fields
  TextEditingController photoContentController = TextEditingController();
  TextEditingController minTemperatureController = TextEditingController();
  TextEditingController maxTemperatureController = TextEditingController();

  Map<String, bool> clothAppropriates = {};

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<String> availableWeatherConditions = ['맑음', '비', '흐림', '눈']; // Add more if needed
  String selectedWeather = ''; // Track the selected weather condition

  List<String> availableGroundConditions = ['평범한', '눈길', '미끄러운']; // Add more if needed
  String selectedGroundCondition = '';

  List<String> availableClothTypes = ['상의', '하의', '신발'];
  String selectedClothType = '';

  // Variables to store user input
  bool isPublic = true;

  bool isTopAppropriate = false;
  bool isBottomAppropriate = false;
  bool isShoesAppropriate = false;

  final dio = Dio();

  String selectedTop = '';
  String selectedBottom = '';
  String selectedShoes = '';

  String selectedTopId = '';
  String selectedBottomId = '';
  String selectedShoesId = '';

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    photoContentController.dispose();
    minTemperatureController.dispose();
    maxTemperatureController.dispose();
    super.dispose();
  }

  String _mapClothTypeToCode(String clothType) {
    switch (clothType) {
      case '상의':
        return '001';
      case '하의':
        return '002';
      case '신발':
        return '003';
    // 추가적인 옷 종류가 있을 경우 계속해서 추가
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('게시물 작성'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the selected image from Step 1 with adjusted size
              Align(
                alignment: Alignment.topLeft,
                child: Image.file(
                  File(widget.imagePath),
                  height: 100, // 원하는 높이로 조절
                  width: 100,  // 원하는 너비로 조절
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              // Additional UI for Step 2
              // Text field for photo content
              Container(
                child: TextField(
                  controller: photoContentController,
                  onChanged: (value) {
                    setState(() {
                      // No need to use value as the controller handles it
                    });
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '내용 입력',
                    contentPadding: EdgeInsets.all(10.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Text fields for min and max temperatures
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minTemperatureController,
                      onChanged: (value) {
                        setState(() {
                          // No need to use value as the controller handles it
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '최소 기온 입력',
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: maxTemperatureController,
                      onChanged: (value) {
                        setState(() {
                          // No need to use value as the controller handles it
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '최대 기온 입력',
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Switch for public visibility
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
                children: [
                  Text('날씨 선택'), // Text on a new line
                  SizedBox(height: 10), // Add vertical spacing between text and buttons
                  Row(
                    children: [
                      for (String weatherCondition in availableWeatherConditions)
                        Padding(
                          padding: EdgeInsets.only(right: 10), // Add spacing between buttons
                          child: ElevatedButton(
                            onPressed: () {
                              _selectWeatherOption(weatherCondition);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedWeather == weatherCondition ? Colors.black : Colors.white,
                              foregroundColor: selectedWeather == weatherCondition ? Colors.white : Colors.grey,
                              side: BorderSide(
                                color: selectedWeather == weatherCondition ? Colors.black : Colors.grey,
                              ),
                            ),
                            child: Text(weatherCondition),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
                children: [
                  Text('바닥 상태 선택'), // Text on a new line
                  SizedBox(height: 10), // Add vertical spacing between text and buttons
                  Row(
                    children: [
                      for (String groundCondition in availableGroundConditions)
                        Padding(
                          padding: EdgeInsets.only(right: 10), // Add spacing between buttons
                          child: ElevatedButton(
                            onPressed: () {
                              _selectGroundConditionOption(groundCondition);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: selectedGroundCondition == groundCondition ? Colors.green : Colors.white,
                              foregroundColor: selectedGroundCondition == groundCondition ? Colors.white : Colors.grey,
                              side: BorderSide(
                                color: selectedGroundCondition == groundCondition ? Colors.green : Colors.grey,
                              ),
                            ),
                            child: Text(groundCondition),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _selectClothTypeOption('상의');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          side: BorderSide(color: Colors.black),
                        ),
                        child: Text(selectedTop.isEmpty ? '상의 선택' : selectedTop, style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: selectedTop.isEmpty
                            ? null // Disable the button if selectedTop is empty
                            : () {
                          setState(() {
                            // Toggle between '적절' and '부적절'
                            isTopAppropriate = !isTopAppropriate;
                            // Update the appropriateness in the map using the selectedTopId
                            clothAppropriates[selectedTopId] = isTopAppropriate;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: isTopAppropriate ? Colors.green : Colors.red,
                        ),
                        child: Text(isTopAppropriate ? '적절' : '부적절', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _selectClothTypeOption('하의');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          side: BorderSide(color: Colors.black),
                        ),
                        child: Text(selectedBottom.isEmpty ? '하의 선택' : selectedBottom, style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: selectedBottom.isEmpty
                            ? null // Disable the button if selectedTop is empty
                            : () {
                          setState(() {
                            // Toggle between '적절' and '부적절'
                            isBottomAppropriate = !isBottomAppropriate;
                            // Update the appropriateness in the map using the selectedTopId
                            clothAppropriates[selectedBottomId] = isBottomAppropriate;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: isBottomAppropriate ? Colors.green : Colors.red,
                        ),
                        child: Text(isBottomAppropriate ? '적절' : '부적절', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _selectClothTypeOption('신발');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          side: BorderSide(color: Colors.black),
                        ),
                        child: Text(selectedShoes.isEmpty ? '신발 선택' : selectedShoes, style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: selectedShoes.isEmpty
                            ? null // Disable the button if selectedTop is empty
                            : () {
                          setState(() {
                            // Toggle between '적절' and '부적절'
                            isShoesAppropriate = !isShoesAppropriate;
                            // Update the appropriateness in the map using the selectedTopId
                            clothAppropriates[selectedShoesId] = isShoesAppropriate;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: isShoesAppropriate ? Colors.green : Colors.red,
                        ),
                        child: Text(isShoesAppropriate ? '적절' : '부적절', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Add functionality for Step 2 button press
                  print('Step 2 button pressed');
                  print('내용: ${photoContentController.text}');
                  print('최저 기온: ${minTemperatureController.text}');
                  print('최고 기온: ${maxTemperatureController.text}');
                  print('공개 여부: $isPublic');
                  print('Weather: $selectedWeather');
                  print('Ground Condition: $selectedGroundCondition');
                  print('clothAppropriates: $clothAppropriates');
                  await uploadImage([File(widget.imagePath)]);

                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.black),
                ),
                child: Text('입력 완료', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _selectWeatherOption(String weatherCondition) {
    setState(() {
      // If already selected, revert to an empty string (unselected state)
      selectedWeather = selectedWeather == weatherCondition ? '' : weatherCondition;
    });
  }

  void _selectGroundConditionOption(String groundCondition) {
    setState(() {
      // If already selected, revert to an empty string (unselected state)
      selectedGroundCondition = selectedGroundCondition == groundCondition ? '' : groundCondition;
    });
  }

  Future<void> uploadImage(List<File> images) async {
    try {
      String apiUrl = 'http://10.0.2.2:8080/file/multiparty-files';

      FormData formData = FormData.fromMap({
        'multipartFiles': images.map((File file) =>
            MultipartFile.fromFileSync(file.path, filename: file.path.split("/").last)).toList(),
      });

      String? jwtToken = await _secureStorage.read(key: 'jwt_token');

      Response response = await dio.post(
          apiUrl,
          data: formData,
          options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),);

      if (response.statusCode == 201) {
        // Image upload successful
        List<String> uploadedUrls = List<String>.from(response.data['data']);
        SaveBoardRequest boardRequest = SaveBoardRequest(
          content: photoContentController.text,
          lowestTemperature: int.parse(minTemperatureController.text),
          highestTemperature: int.parse(maxTemperatureController.text),
          open: isPublic,
          weather: selectedWeather,
          roadCondition: selectedGroundCondition,
          clothAppropriates: clothAppropriates,
          imageUrls: uploadedUrls,
        );

        await createBoard(boardRequest);
        // Do something with the uploadedUrls if needed
        print('Image uploaded successfully. URLs: $uploadedUrls');
      } else {
        // Image upload failed
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<void> createBoard(SaveBoardRequest boardRequest) async {
    try {
      String apiUrl = 'http://10.0.2.2:8080/boards'; // 실제 API 엔드포인트로 교체

      String? jwtToken = await _secureStorage.read(key: 'jwt_token');

      Response response = await dio.post(
        apiUrl,
        data: boardRequest.toJson(), // SaveBoardRequest에 toJson 메서드가 있다고 가정합니다.
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        // 게시물 생성 성공
        print('게시물이 성공적으로 생성되었습니다.');
      } else {
        // 게시물 생성 실패
        print('게시물 생성 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (error) {
      print('게시물 생성 오류: $error');
    }
  }


  void _selectClothTypeOption(String clothType) async {
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      final response = await dio.get(
        'http://10.0.2.2:8080/cloths',
        queryParameters: {
          'type': _mapClothTypeToCode(clothType),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Convert the dynamic map data to a List<ClothResponse>
        List<ClothResponse> clothList = (response.data['data'] as List)
            .map((item) => ClothResponse.fromJson(item))
            .toList();

        // Display the cloth list in a dialog
        _showClothListDialog(clothList, clothType);
      } else {
        print('Failed to fetch cloth list. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch cloth list: $error');
    }
  }

  void _showClothListDialog(List<ClothResponse> clothList, String clothType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$clothType List'),
          content: Column(
            children: clothList.map((ClothResponse cloth) {
              int clothId = cloth.id;
              return ListTile(
                title: Text(cloth.information),
                onTap: () {
                  setState(() {
                    switch (clothType) {
                      case '상의':
                        selectedTop = cloth.information;
                        selectedTopId = clothId.toString();
                        clothAppropriates[selectedTopId] = isTopAppropriate;
                        break;
                      case '하의':
                        selectedBottom = cloth.information;
                        selectedBottomId = clothId.toString();
                        clothAppropriates[selectedBottomId] = isBottomAppropriate;
                        break;
                      case '신발':
                        selectedShoes = cloth.information;
                        selectedShoesId = clothId.toString();
                        clothAppropriates[selectedShoesId] = isShoesAppropriate;
                        break;
                    // 추가적인 옷 종류가 있을 경우 계속해서 추가
                    }
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

