class MemberResponse {
  late String email;
  late String nickname;

  MemberResponse({
    required this.email,
    required this.nickname,
  });

  factory MemberResponse.fromJson(Map<String, dynamic> json) {
    return MemberResponse(
      email: json['email'],
      nickname: json['nickname']
    );
  }
}