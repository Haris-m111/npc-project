import 'package:npc/core/api/api_constants.dart';
import 'package:npc/core/api/base_api_service.dart';
import 'package:npc/data/models/about_app_model.dart';
import 'dart:io';

class AboutAppRepository {
  final BaseApiService _apiService = BaseApiService();

  Future<AboutAppModel> fetchAboutApp({String language = 'en'}) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final url =
          "${ApiConstants.baseUrl}${ApiConstants.aboutAppEndpoint}?language=$language&platform=$platform";
      final response = await _apiService.getResponse(url);
      return AboutAppModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
