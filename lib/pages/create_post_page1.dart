import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fit_fe/utils/image_helper.dart';
import 'package:fit_fe/pages/create_post_page2.dart';

class CreatePostStep1 extends StatefulWidget {
  @override
  _CreatePostStep1State createState() => _CreatePostStep1State();
}

class _CreatePostStep1State extends State<CreatePostStep1> {
  ImageHelper imageHelper = ImageHelper();

  String? selectedImagePath;

  Future<void> _pickImage() async {
    String? imagePath = await imageHelper.pickSingleImage();

    if (imagePath != null) {
      setState(() {
        selectedImagePath = imagePath;
      });
    }
  }

  void _navigateToNextStep() {
    if (selectedImagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostStep2(selectedImagePath!),
        ),
      );
    } else {
      print('Please select a photo first.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('게시물 사진'),
        actions: [
          IconButton(
            onPressed: _navigateToNextStep,
            icon: Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedImagePath != null)
              Image.file(
                File(selectedImagePath!),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: BorderSide(color: Colors.black)),
              child: Text('사진 선택',
                style: TextStyle(
                  color: Colors.white,
                ),),
            ),
          ],
        ),
      ),
    );
  }
}
