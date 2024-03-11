import 'package:dio/dio.dart';
import 'package:fit_fe/handler/token_refresh_handler.dart';
import 'package:fit_fe/models/board_response.dart';
import 'package:fit_fe/models/page_response.dart';
import 'package:fit_fe/pages/board_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _minTemperatureController = TextEditingController();
  TextEditingController _maxTemperatureController = TextEditingController();
  String _selectedFloorCondition = '';
  String _selectedWeatherTag = '';
  String _selectedLocation = '';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<BoardResponse> boardResponses = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: Text('검색 조건'),
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '온도 입력',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Container(
                          width: 80.0,
                          margin: EdgeInsets.only(right: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: TextFormField(
                              controller: _minTemperatureController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '최저 온도',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '~',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 80.0,
                          margin: EdgeInsets.only(left: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: TextFormField(
                              controller: _maxTemperatureController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '최고 온도',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        _showFloorConditionBottomSheet();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey)),
                      child: Text(
                        '바닥 상태 선택: $_selectedFloorCondition',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        _showWeatherTagBottomSheet();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey)),
                      child: Text(
                        '날씨 태그 선택: $_selectedWeatherTag',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        _showLocationBottomSheet();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey)),
                      child: Text(
                        '장소 선택: $_selectedLocation',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          _searchPosts();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            side: BorderSide(color: Colors.black)),
                        child: Text(
                          '검색',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: boardResponses.isEmpty
                ? Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: boardResponses.length,
                    itemBuilder: (context, index) {
                      BoardResponse board = boardResponses[index];
                      return _buildGridItem(board);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BoardResponse board) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BoardDetailPage(board: board),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.network(
                  'https://fit-image-bucket.s3.ap-northeast-2.amazonaws.com/${board.imageUrls.first}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.content,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '날씨: ${board.weather}, 도로 상태: ${board.roadCondition}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFloorConditionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            ListTile(
              title: Text('평범한'),
              onTap: () {
                setState(() {
                  _selectedFloorCondition = '평범한';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('미끄러운'),
              onTap: () {
                setState(() {
                  _selectedFloorCondition = '미끄러운';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('눈길'),
              onTap: () {
                setState(() {
                  _selectedFloorCondition = '눈길';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('모래'),
              onTap: () {
                setState(() {
                  _selectedFloorCondition = '모래';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showWeatherTagBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            ListTile(
              title: Text('맑음'),
              onTap: () {
                setState(() {
                  _selectedWeatherTag = '맑음';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('흐림'),
              onTap: () {
                setState(() {
                  _selectedWeatherTag = '흐림';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('눈'),
              onTap: () {
                setState(() {
                  _selectedWeatherTag = '눈';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('비'),
              onTap: () {
                setState(() {
                  _selectedWeatherTag = '비';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLocationBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            ListTile(
              title: Text('결혼식'),
              onTap: () {
                setState(() {
                  _selectedLocation = '결혼식';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('외출'),
              onTap: () {
                setState(() {
                  _selectedLocation = '외출';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('스포츠'),
              onTap: () {
                setState(() {
                  _selectedLocation = '스포츠';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('페스티벌'),
              onTap: () {
                setState(() {
                  _selectedLocation = '페스티벌';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('파티'),
              onTap: () {
                setState(() {
                  _selectedLocation = '파티';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchPosts() async {
    String minTemperature = _minTemperatureController.text;
    String maxTemperature = _maxTemperatureController.text;

    String apiUrl = 'https://fitcorp.xyz/boards';

    Dio dio = Dio();
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');
    try {
      Map<String, dynamic> queryParameters = {
        'lowestTemperature': minTemperature,
        'highestTemperature': maxTemperature,
      };

      if (_selectedWeatherTag.isNotEmpty) {
        queryParameters['weather'] = _selectedWeatherTag;
      }

      if (_selectedFloorCondition.isNotEmpty) {
        queryParameters['roadCondition'] = _selectedFloorCondition;
      }

      if (_selectedLocation.isNotEmpty) {
        queryParameters['place'] = _selectedLocation;
      }

      Response response = await dio.get(apiUrl,
          queryParameters: queryParameters,
          options: Options(
            headers: {
              'Authorization': 'Bearer $jwtToken',
            },
          ));

      if (response.statusCode == 200) {
        PageResponse pageResponse = PageResponse.fromJson(response.data);
        print(response.data);
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        await _searchPosts();
      }
    } catch (error) {
      print('Dio Error: $error');
    }
  }
}
