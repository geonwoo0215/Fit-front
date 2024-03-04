import 'package:image_picker/image_picker.dart';

class ImageHelper {
  final ImagePicker _imagePicker = ImagePicker();

  Future<String?> pickSingleImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      return pickedFile?.path;
    } catch (e) {
      print('이미지를 선택하는 중에 오류가 발생했습니다: $e');
      return null;
    }
  }

  Future<List<String>?> pickMultipleImages() async {
    try {
      final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        List<String> paths = pickedFiles.map((file) => file.path).toList();
        return paths.length <= 5 ? paths : null;
      } else {
        return null;
      }
    } catch (e) {
      print('이미지를 선택하는 중에 오류가 발생했습니다: $e');
      return null;
    }
  }
}