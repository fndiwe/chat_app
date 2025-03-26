import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  Future<File?> getImage() async {
    try {
      final ImagePicker imagePicker = ImagePicker();

      final XFile? image =
          await imagePicker.pickImage(source: ImageSource.gallery);

      return File(image!.path);
    } catch (_) {
      return null;
    }
  }

  Future<String> uploadProfilePhoto(File? uploadedImage) async {
    String imageUrl;
    final FormData formData;
    if (uploadedImage == null) {
      throw Exception("No file found");
    } else if (await uploadedImage.length() > 5000000) {
      throw Exception("File size show not exceed 5MB");
    } else {
      formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(uploadedImage.path,
            filename: uploadedImage.path.split("/").last),
        'upload_preset': 'image_upload_preset'
      });
    }
    Response<dynamic> response;
    try {
      response = await Dio().post(
          'https://api.cloudinary.com/v1_1/dnrw1lkqj/upload',
          data: formData,
          options: Options(headers: {'X-Requested-With': 'XMLHttpRequest'}));
    } on DioException catch (e) {
      throw Exception(e.type == DioExceptionType.connectionError ? "Network error" : e.message);
    } catch (e) {
      throw Exception(e.toString());
    }

    if (response.statusCode == 200) {
      imageUrl = response.data['url'];
    } else {
      throw Exception(response.data['error']['message']);
    }

    return imageUrl;
  }
}
