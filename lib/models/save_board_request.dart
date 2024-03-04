class SaveBoardRequest {
  final String content;
  final int lowestTemperature;
  final int highestTemperature;
  final bool open;
  final String weather;
  final String roadCondition;
  final String place;
  final Map<String, bool> clothAppropriates;
  final List<String> imageUrls;

  SaveBoardRequest({
    required this.content,
    required this.lowestTemperature,
    required this.highestTemperature,
    required this.open,
    required this.weather,
    required this.place,
    required this.roadCondition,
    required this.clothAppropriates,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'lowestTemperature': lowestTemperature,
      'highestTemperature': highestTemperature,
      'open': open,
      'weather': weather,
      'roadCondition': roadCondition,
      'place': place,
      'clothAppropriates': clothAppropriates,
      'imageUrls': imageUrls,
    };
  }
}