import 'cloth_response.dart';

class BoardResponse {
  final int id;
  final String content;
  final int lowestTemperature;
  final int highestTemperature;
  final bool open;
  final String weather;
  final String roadCondition;
  final String place;
  final List<ClothResponse> clothResponses;
  final List<String> imageUrls;
  final bool like;
  final String nickname;
  final bool mine;

  BoardResponse({
    required this.id,
    required this.content,
    required this.lowestTemperature,
    required this.highestTemperature,
    required this.open,
    required this.weather,
    required this.roadCondition,
    required this.place,
    required this.clothResponses,
    required this.imageUrls,
    required this.like,
    required this.nickname,
    required this.mine,
  });

  factory BoardResponse.fromJson(Map<String, dynamic> json) {
    return BoardResponse(
      id: json['id'],
      content: json['content'],
      lowestTemperature: json['lowestTemperature'],
      highestTemperature: json['highestTemperature'],
      open: json['open'],
      weather: json['weather'],
      roadCondition: json['roadCondition'],
      place: json['place'],
      clothResponses: (json['clothResponses'] as List<dynamic>?)
          ?.map((clothJson) => ClothResponse.fromJson(clothJson))
          .toList() ?? [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((imageUrl) => imageUrl.toString())
          .toList() ?? [],
      like: json['like'],
      nickname: json['nickname'],
      mine: json['mine']
    );
  }
}