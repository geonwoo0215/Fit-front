import 'package:flutter/material.dart';
import 'package:fit_fe/models/board_response.dart';

class MyBoardsPage extends StatelessWidget {
  final List<BoardResponse> boardResponses;

  MyBoardsPage({required this.boardResponses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 게시물 보기'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: boardResponses.length,
        itemBuilder: (context, index) {
          return _buildGridItem(context, boardResponses[index]);
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, BoardResponse board) {
    return GestureDetector(
      onTap: () {

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
}