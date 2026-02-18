import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:npc/core/services/token_service.dart';

// Custom Exception class to handle API status codes
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

// Ye class networking calls (HTTP requests) ko handle karne ke liye banayi gayi hai
class BaseApiService {
  final TokenService _tokenService = TokenService();

  // Simple POST request (Without Token)
  Future<dynamic> postResponse(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _returnResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // POST request with Bearer Token (Authorized APIs ke liye)
  Future<dynamic> postAuthorizedResponse(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      // TokenService se access token mangwa rhy hain
      String? token = await _tokenService.getAccessToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Header mein token bhej rhy hain
        },
        body: jsonEncode(data),
      );
      return _returnResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // GET request with Bearer Token (Profile fetching ke liye)
  Future<dynamic> getAuthorizedResponse(String url) async {
    try {
      String? token = await _tokenService.getAccessToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _returnResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // PUT request with Bearer Token (Data update karne ke liye)
  Future<dynamic> putAuthorizedResponse(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      String? token = await _tokenService.getAccessToken();
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      return _returnResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request with Bearer Token (Account delete karne ke liye)
  Future<dynamic> deleteAuthorizedResponse(String url) async {
    try {
      String? token = await _tokenService.getAccessToken();
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _returnResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Server sy aaye hue response codes ko check karne ka logic
  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw ApiException(
          400,
          'Ghalat request. Meherbani farma kar details check kryn.',
        );
      case 401:
        throw ApiException(
          401,
          'Session khatam ho gaya ha. Dobara login kryn.',
        );
      case 403:
        throw ApiException(403, 'Aap ko is kaam ki ijazat nahi ha.');
      case 404:
        throw ApiException(404, 'Data nahi mila (Not Found).');
      case 409:
        throw ApiException(409, 'User pehle se mojood ha.');
      case 500:
        throw ApiException(500, 'Server me koi masla ha. Thora intezar kryn.');
      default:
        throw ApiException(
          response.statusCode,
          'An unexpected error occurred: ${response.statusCode}',
        );
    }
  }
}
