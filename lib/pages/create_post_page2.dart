import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fit_fe/handler/token_refresh_handler.dart';
import 'package:fit_fe/models/cloth_response.dart';
import 'package:fit_fe/models/save_board_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreatePostStep2 extends StatefulWidget {
  final String imagePath;

  CreatePostStep2(this.imagePath);

  @override
  _CreatePostStep2State createState() => _CreatePostStep2State();
}

class _CreatePostStep2State extends State<CreatePostStep2> {
  TextEditingController photoContentController = TextEditingController();
  TextEditingController minTemperatureController = TextEditingController();
  TextEditingController maxTemperatureController = TextEditingController();

  Map<String, bool> clothAppropriates = {};

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<String> availableWeatherConditions = ['맑음', '비', '흐림', '눈'];
  String selectedWeather = '';

  List<String> availableGroundConditions = ['평범한', '눈길', '미끄러운'];
  String selectedGroundCondition = '';

  List<String> availableClothTypes = ['상의', '하의', '신발'];
  String selectedClothType = '';

  List<String> availablePlace = ['결혼식', '외출', '스포츠', '페스티발', '파티'];
  String selectedPlace = '';

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
              Align(
                alignment: Alignment.topLeft,
                child: Image.file(
                  File(widget.imagePath),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: TextField(
                  controller: photoContentController,
                  onChanged: (value) {
                    setState(() {});
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minTemperatureController,
                      onChanged: (value) {
                        setState(() {});
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
                        setState(() {});
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
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('날씨 선택'),
                      SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          for (String weatherCondition
                              in availableWeatherConditions)
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  _selectWeatherOption(weatherCondition);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedWeather == weatherCondition
                                          ? Colors.black
                                          : Colors.white,
                                  foregroundColor:
                                      selectedWeather == weatherCondition
                                          ? Colors.white
                                          : Colors.grey,
                                  side: BorderSide(
                                    color: selectedWeather == weatherCondition
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                                child: Text(weatherCondition),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('바닥 상태 선택'),
                      SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          for (String groundCondition
                              in availableGroundConditions)
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  _selectGroundConditionOption(groundCondition);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedGroundCondition == groundCondition
                                          ? Colors.black
                                          : Colors.white,
                                  foregroundColor:
                                      selectedGroundCondition == groundCondition
                                          ? Colors.white
                                          : Colors.grey,
                                  side: BorderSide(
                                    color: selectedGroundCondition ==
                                            groundCondition
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                                child: Text(groundCondition),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('장소 선택'),
                      SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          for (String place in availablePlace)
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  _selectPlaceOption(place);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedPlace == place
                                      ? Colors.black
                                      : Colors.white,
                                  foregroundColor: selectedPlace == place
                                      ? Colors.white
                                      : Colors.grey,
                                  side: BorderSide(
                                    color: selectedPlace == place
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                                child: Text(place),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black),
                        ),
                        child: Text(selectedTop.isEmpty ? '상의 선택' : selectedTop,
                            style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: selectedTop.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  isTopAppropriate = !isTopAppropriate;
                                  clothAppropriates[selectedTopId] =
                                      isTopAppropriate;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isTopAppropriate ? Colors.green : Colors.red,
                        ),
                        child: Text(isTopAppropriate ? '적절' : '부적절',
                            style: TextStyle(color: Colors.black)),
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black),
                        ),
                        child: Text(
                            selectedBottom.isEmpty ? '하의 선택' : selectedBottom,
                            style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: selectedBottom.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  isBottomAppropriate = !isBottomAppropriate;
                                  clothAppropriates[selectedBottomId] =
                                      isBottomAppropriate;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isBottomAppropriate ? Colors.green : Colors.red,
                        ),
                        child: Text(isBottomAppropriate ? '적절' : '부적절',
                            style: TextStyle(color: Colors.black)),
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black),
                        ),
                        child: Text(
                            selectedShoes.isEmpty ? '신발 선택' : selectedShoes,
                            style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: selectedShoes.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  isShoesAppropriate = !isShoesAppropriate;
                                  clothAppropriates[selectedShoesId] =
                                      isShoesAppropriate;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isShoesAppropriate ? Colors.green : Colors.red,
                        ),
                        child: Text(isShoesAppropriate ? '적절' : '부적절',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
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
      selectedWeather =
          selectedWeather == weatherCondition ? '' : weatherCondition;
    });
  }

  void _selectGroundConditionOption(String groundCondition) {
    setState(() {
      selectedGroundCondition =
          selectedGroundCondition == groundCondition ? '' : groundCondition;
    });
  }

  void _selectPlaceOption(String place) {
    setState(() {
      selectedPlace = selectedPlace == place ? '' : place;
    });
  }

  Future<void> uploadImage(List<File> images) async {
    try {
      String apiUrl = 'https://fitcorp.xyz/file/multiparty-files';

      FormData formData = FormData.fromMap({
        'multipartFiles': images
            .map((File file) => MultipartFile.fromFileSync(file.path,
                filename: file.path.split("/").last))
            .toList(),
      });

      String? jwtToken = await _secureStorage.read(key: 'jwt_token');

      Response response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        List<String> uploadedUrls = List<String>.from(response.data['data']);
        SaveBoardRequest boardRequest = SaveBoardRequest(
          content: photoContentController.text,
          lowestTemperature: int.parse(minTemperatureController.text),
          highestTemperature: int.parse(maxTemperatureController.text),
          open: isPublic,
          weather: selectedWeather,
          roadCondition: selectedGroundCondition,
          place: selectedPlace,
          clothAppropriates: clothAppropriates,
          imageUrls: uploadedUrls,
        );

        await createBoard(boardRequest);

        print('Image uploaded successfully. URLs: $uploadedUrls');
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        await uploadImage(images);
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<void> createBoard(SaveBoardRequest boardRequest) async {
    try {
      String apiUrl = 'https://fitcorp.xyz/boards';

      String? jwtToken = await _secureStorage.read(key: 'jwt_token');

      Response response = await dio.post(
        apiUrl,
        data: boardRequest.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        print('게시물이 성공적으로 생성되었습니다.');
      } else {
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
        'https://fitcorp.xyz/cloths',
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
        List<ClothResponse> clothList = (response.data['data'] as List)
            .map((item) => ClothResponse.fromJson(item))
            .toList();

        _showClothListDialog(clothList, clothType);
      } else {
        print(
            'Failed to fetch cloth list. Status code: ${response.statusCode}');
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
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
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
                        clothAppropriates[selectedBottomId] =
                            isBottomAppropriate;
                        break;
                      case '신발':
                        selectedShoes = cloth.information;
                        selectedShoesId = clothId.toString();
                        clothAppropriates[selectedShoesId] = isShoesAppropriate;
                        break;
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
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
