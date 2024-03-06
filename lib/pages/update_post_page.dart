import 'package:dio/dio.dart';
import 'package:fit_fe/models/update_board_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UpdatePostPage extends StatefulWidget {
  final int id;

  UpdatePostPage(this.id);

  @override
  _UpdatePostPageState createState() => _UpdatePostPageState();
}

class _UpdatePostPageState extends State<UpdatePostPage> {
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
        title: Text('게시물 수정'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              ElevatedButton(
                onPressed: () {
                  UpdateBoardRequest boardRequest = UpdateBoardRequest(
                    content: photoContentController.text,
                    lowestTemperature: int.parse(minTemperatureController.text),
                    highestTemperature:
                        int.parse(maxTemperatureController.text),
                    open: isPublic,
                    weather: selectedWeather,
                    roadCondition: selectedGroundCondition,
                    place: selectedPlace,
                  );

                  updateBoard(boardRequest);

                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.black),
                ),
                child: Text('수정 완료', style: TextStyle(color: Colors.white)),
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

  Future<void> updateBoard(UpdateBoardRequest boardRequest) async {
    try {
      String apiUrl = 'http://10.0.2.2:8080/boards/${widget.id}';

      String? jwtToken = await _secureStorage.read(key: 'jwt_token');

      Response response = await dio.patch(
        apiUrl,
        data: boardRequest.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      if (response.statusCode == 204) {
        print('게시물이 성공적으로 수정되었습니다.');
      } else {
        print('게시물 수정 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (error) {
      print('게시물 수정 오류: $error');
    }
  }
}
