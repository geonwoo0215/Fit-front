import 'package:dio/dio.dart';
import 'package:fit_fe/handler/token_refresh_handler.dart';
import 'package:fit_fe/models/board_response.dart';
import 'package:fit_fe/models/cloth_response.dart';
import 'package:fit_fe/models/comment_response.dart';
import 'package:fit_fe/pages/update_post_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
          'commentId': commentId,
        },
      );

      if (response.statusCode == 201) {
        CommentResponse newComment =
            CommentResponse.fromJson(response.data['data']);
        setState(() {
          comments.add(newComment);
        });
      } else if (response.statusCode == 401) {
        await TokenRefreshHandler.refreshAccessToken(context);
        await postComment(comment);
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

      fetchComments();
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
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  String? jwtToken =
                      await _secureStorage.read(key: 'jwt_token');
                  final response = await dio.delete(
                    'http://10.0.2.2:8080/boards/${widget.board.id}',
                    options: Options(
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $jwtToken',
                      },
                    ),
                  );
                } catch (error) {
                  print('삭제 오류: $error');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UpdatePostPage(
                                                    widget.board.id)),
                                      );
                                    },
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showCommentsModal();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.comment),
                        SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () {
                      toggleLike();
                    },
                    child: Row(
                      children: [
                        Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                        SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Text(
                '장소: ${widget.board.place}',
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
                children: [
                  TextField(
                    onTap: () {},
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: '댓글 작성...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
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
