import 'package:http/http.dart' as http;
import 'package:npc/core/api/api_constants.dart';
import 'package:npc/core/api/base_api_service.dart';

class S3Repository {
  final BaseApiService _apiService = BaseApiService();

  // File upload karne ka main function
  Future<List<String>> uploadFiles({
    required String email,
    required List<String> filePaths,
    required String keyName, // e.g., 'files'
    String scope = 'profile', // Default scope added
  }) async {
    try {
      final url = ApiConstants.baseUrl + ApiConstants.uploadS3Endpoint;

      // Multipart files create kryn
      List<http.MultipartFile> multipartFiles = [];
      for (String path in filePaths) {
        // Professional apps mein key hamesha backend ke mutabiq hoti ha
        multipartFiles.add(await http.MultipartFile.fromPath(keyName, path));
      }

      final fields = {
        'email': email,
        'scope': scope, // Scope field add krdi
      };

      final response = await _apiService.postMultipartResponse(
        url: url,
        fields: fields,
        files: multipartFiles,
      );

      // Backend Response structure: { "files": [ { "url": "..." }, ... ] }
      if (response['files'] != null && response['files'] is List) {
        return (response['files'] as List)
            .map((file) => file['url'].toString())
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // File delete karne ka logic
  Future<void> deleteFile(String key) async {
    try {
      final url =
          "${ApiConstants.baseUrl}${ApiConstants.deleteS3Endpoint}/$key";
      await _apiService.deleteAuthorizedResponse(url);
    } catch (e) {
      rethrow;
    }
  }
}
