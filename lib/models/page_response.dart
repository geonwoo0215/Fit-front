import 'package:fit_fe/models/board_response.dart';

class PageResponse {
  final int totalElements;
  final int totalPages;
  final int number;
  final List<BoardResponse> content;

  PageResponse({
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.content,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json) {
    return PageResponse(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      number: json['number'] ?? 0,
      content: (json['data']['content'] as List<dynamic>?)
          ?.map((boardJson) => BoardResponse.fromJson(boardJson))
          .toList() ?? [],
    );
  }
}