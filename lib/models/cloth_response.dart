class ClothResponse {
  final int id;
  final String type;
  final String information;
  final String size;

  ClothResponse({
    required this.id,
    required this.type,
    required this.information,
    required this.size,
  });

  factory ClothResponse.fromJson(Map<String, dynamic> json) {
    return ClothResponse(
        id: json['id'],
        type: json['type'],
        information: json['information'],
        size: json['size']);
  }
}
