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
        // 최대 이미지 수를 제한하고자 하는 경우에는 여기서 처리 가능
        // 예를 들어, 최대 5개까지만 선택할 경우
        List<String> paths = pickedFiles.map((file) => file.path).toList();
        return paths.length <= 5 ? paths : null;
      } else {
        // 사용자가 이미지 선택을 취소한 경우 또는 아무 이미지도 선택하지 않은 경우
        return null;
      }
    } catch (e) {
      print('이미지를 선택하는 중에 오류가 발생했습니다: $e');
      return null;
    }
  }
}