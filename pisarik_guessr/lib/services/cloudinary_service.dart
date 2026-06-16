import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = "dv9aezcua";
  static const String uploadPreset = "guessr";

  final Dio _dio = Dio();


  Future<XFile?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
  }

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'upload_preset': uploadPreset,
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      } else {
        print('Cloudinary upload error: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Ошибка загрузки на Cloudinary: $e');
      return null;
    }
  }
}