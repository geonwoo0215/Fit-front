import 'package:flutter/material.dart';
import 'package:fit_fe/models/board_response.dart';
import 'package:fit_fe/models/cloth_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fit_fe/models/comment_response.dart';
import 'package:dio/dio.dart';

class BoardDetailPage extends StatefulWidget {
  final BoardResponse board;

  BoardDetailPage({required this.board});

  @override
  _BoardDetailPageState createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<CommentResponse> comments = [];
  bool isLoadingComments = false;
  TextEditingController commentController = TextEditingController();
  Dio dio = Dio();

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    // 좋아요 상태 초기화
    setState(() {
      isLiked = widget.board.like;
    });
  }

  void toggleLike() async {
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');

    try {
      if (isLiked) {
        await dio.delete(
          'http://10.0.2.2:8080/boards/${widget.board.id}/like',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          ),
        );
      } else {
        await dio.post(
          'http://10.0.2.2:8080/boards/${widget.board.id}/like',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          ),
        );
      }

      // 좋아요 상태 토글
      setState(() {
        isLiked = !isLiked;
      });
    } catch (error) {
      print('좋아요 토글 오류: $error');
    }
  }

  Future<void> fetchComments() async {
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');
    try {
      Response response = await dio.get(
        'http://10.0.2.2:8080/boards/${widget.board.id}/comments',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Response data: $data');
        setState(() {
          comments = List.from(data['data']['content'])
              .map<CommentResponse>(
                (commentJson) => CommentResponse.fromJson(commentJson),
              )
              .toList();
          isLoadingComments = false;
        });
      } else {
        print('댓글 불러오기 실패');
        setState(() {
          isLoadingComments = false;
        });
      }
    } catch (error) {
      print('댓글 불러오기 오류: $error');
      setState(() {
        isLoadingComments = false;
      });
    }
  }

  Future<void> postComment(String comment, {int commentId = 0}) async {
    String? jwtToken = await _secureStorage.read(key: 'jwt_token');
    try {
      Response response = await dio.post(
        'http://10.0.2.2:8080/boards/${widget.board.id}/comments',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
        ),
        data: {
          'comment': comment,
          'commentId': commentId, // CommentSaveRequest에 commentId 추가
        },
      );

      if (response.statusCode == 201) {
        // 댓글 작성 성공 시, 새로운 댓글을 화면에 추가
        CommentResponse newComment =
            CommentResponse.fromJson(response.data['data']);
        setState(() {
          comments.add(newComment);
        });
      } else {
        print('댓글 작성 실패');
      }
    } catch (error) {
      print('댓글 작성 오류: $error');
    }
  }

  void showCommentsModal() {
    if (!isLoadingComments) {
      setState(() {
        isLoadingComments = true;
      });

      fetchComments(); // 버튼이 눌렸을 때 댓글을 가져옵니다.
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                '댓글 보기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    CommentResponse comment = comments[index];
                    return ListTile(
                      title: Text(comment.nickname),
                      subtitle: Text(comment.comment),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // 삭제 버튼을 눌렀을 때 수행할 로직 추가
                // 예: 데이터 삭제 함수 호출
                Navigator.pop(context); // 다이얼로그 닫기

                // 삭제 API 호출
                try {
                  String? jwtToken =
                      await _secureStorage.read(key: 'jwt_token');
                  await dio.delete(
                    'http://10.0.2.2:8080/boards/${widget.board.id}',
                    options: Options(
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $jwtToken',
                      },
                    ),
                  );
                  // 삭제 성공
                  // 추가로 필요한 로직 수행
                } catch (error) {
                  print('삭제 오류: $error');
                  // 삭제 실패 처리 또는 사용자에게 알림
                }
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  String getTypeText(String type) {
    switch (type) {
      case '001':
        return '상의';
      case '002':
        return '하의';
      case '003':
        return '악세사리';
      case '004':
        return '신발';
      default:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 상세 정보'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.board.nickname}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  if (widget.board.mine)
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 500,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    title: Text('수정'),
                                    onTap: () {},
                                  ),
                                  ListTile(
                                    title: Text(
                                      '삭제',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      showDeleteConfirmationDialog(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
            Container(
              height: 600.0,
              child: PageView.builder(
                itemCount: widget.board.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    'https://fit-image-bucket.s3.ap-northeast-2.amazonaws.com/${widget.board.imageUrls[index]}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Text(
                widget.board.content,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Text(
                '날씨: ${widget.board.weather}',
                style: TextStyle(fontSize: 14.0),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Text(
                '도로 상태: ${widget.board.roadCondition}',
                style: TextStyle(fontSize: 14.0),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.board.clothResponses.length,
                itemBuilder: (context, index) {
                  ClothResponse cloth = widget.board.clothResponses[index];
                  return ListTile(
                    title: Text(getTypeText(cloth.type)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Information: ${cloth.information}'),
                        Text('Size: ${cloth.size}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showCommentsModal();
                    },
                    icon: Icon(Icons.comment),
                    label: Text('댓글'),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      toggleLike();
                    },
                    icon:
                        Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                    label: Text('좋아요'),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: '댓글 작성...',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      postComment(commentController.text);
                      commentController.clear();
                    },
                    child: Text('댓글 작성'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}