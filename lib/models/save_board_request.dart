class SaveBoardRequest {
  final String content;
  final int lowestTemperature;
  final int highestTemperature;
  final bool open;
  final String weather;
  final String roadCondition;
  final Map<String, bool> clothAppropriates;
  final List<String> imageUrls;

  SaveBoardRequest({
    required this.content,
    required this.lowestTemperature,
    required this.highestTemperature,
    required this.open,
    required this.weather,
    required this.roadCondition,
    required this.clothAppropriates,
    required this.imageUrls,
  });

  // Convert the object to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'lowestTemperature': lowestTemperature,
      'highestTemperature': highestTemperature,
      'open': open,
      'weather': weather,
      'roadCondition': roadCondition,
      'clothAppropriates': clothAppropriates,
      'imageUrls': imageUrls,
    };
  }
}