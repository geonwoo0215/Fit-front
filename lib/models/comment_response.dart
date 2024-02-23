class CommentResponse {
  final int id;
  final String comment;
  final String nickname;
  final String parentCommentMemberNickname;

  CommentResponse({
    required this.id,
    required this.comment,
    required this.nickname,
    required this.parentCommentMemberNickname,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      id: json['id'],
      comment: json['comment'],
      nickname: json['nickname'],
      parentCommentMemberNickname: json['parentCommentMemberNickname'] ?? '',
    );
  }
}