import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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
      debugPrint("API Request: POST $url");
      debugPrint("Request Body: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      debugPrint("API Response: ${response.statusCode} - ${response.body}");
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
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
      debugPrint("API Request (Auth): POST $url");
      debugPrint("Request Body: ${jsonEncode(data)}");
      String? token = await _tokenService.getAccessToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Header mein token bhej rhy hain
        },
        body: jsonEncode(data),
      );
      debugPrint("API Response: ${response.statusCode} - ${response.body}");
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // GET request with Bearer Token (Profile fetching ke liye)
  Future<dynamic> getAuthorizedResponse(String url) async {
    try {
      debugPrint("API Request (Auth): GET $url");
      String? token = await _tokenService.getAccessToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint("API Response: ${response.statusCode} - ${response.body}");
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // Simple GET request (Without Token)
  Future<dynamic> getResponse(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // PUT request with Bearer Token (Data update karne ke liye)
  Future<dynamic> putAuthorizedResponse(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint("API Request (Auth): PUT $url");
      debugPrint("Request Body: ${jsonEncode(data)}");
      String? token = await _tokenService.getAccessToken();
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      debugPrint("API Response: ${response.statusCode} - ${response.body}");
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // PATCH request with Bearer Token (Partial update karne ke liye)
  Future<dynamic> patchAuthorizedResponse(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint("API Request (Auth): PATCH $url");
      debugPrint("Request Body: ${jsonEncode(data)}");
      String? token = await _tokenService.getAccessToken();
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      debugPrint("API Response: ${response.statusCode} - ${response.body}");
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // DELETE request with Bearer Token (Account delete karne ke liye)
  Future<dynamic> deleteAuthorizedResponse(String url) async {
    try {
      debugPrint("API Request (Auth): DELETE $url");
      String? token = await _tokenService.getAccessToken();
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint("API Response: ${response.statusCode} - ${response.body}");
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // Uploading Files (Multipart Request) - Professional Way
  Future<dynamic> postMultipartResponse({
    required String url,
    required Map<String, String> fields, // e.g., {'email': 'user@example.com'}
    required List<http.MultipartFile> files, // List of files to upload
  }) async {
    try {
      debugPrint("API Request (Auth - Multipart): POST $url");
      debugPrint("Fields: $fields");
      String? token = await _tokenService.getAccessToken();

      // Multipart Request create kryn
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Headers add kryn
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      // Fields (like email) add kryn
      request.fields.addAll(fields);

      // Files add kryn
      request.files.addAll(files);

      // Request send kryn aur response ka wait kryn
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("API Response: ${response.statusCode} - ${response.body}");
      return _returnResponse(response);
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  // Server sy aaye hue response codes ko check karne ka logic
  dynamic _returnResponse(http.Response response) {
    // Koshish kryn ke server se aane wala asli message nikal skein
    String? serverMessage;
    try {
      final body = jsonDecode(response.body);
      serverMessage = body['message'] ?? body['error'] ?? body['msg'];
    } catch (e) {
      // Body parse nahi ho saki ya message nahi mila
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw ApiException(
          400,
          serverMessage ?? 'Invalid request. Please check your input details.',
        );
      case 401:
        throw ApiException(
          401,
          serverMessage ?? 'Session expired. Please login again.',
        );
      case 403:
        throw ApiException(
          403,
          serverMessage ?? 'You do not have permission to perform this action.',
        );
      case 404:
        throw ApiException(404, serverMessage ?? 'Data not found (404).');
      case 409:
        throw ApiException(
          409,
          serverMessage ?? 'Conflict: User or data already exists.',
        );
      case 413:
        throw ApiException(
          413,
          'The images are too large to upload. Please try uploading fewer images or reduce their size.',
        );
      case 500:
        throw ApiException(
          500,
          'Server error. Our team is working on it, please try again later.',
        );
      default:
        throw ApiException(
          response.statusCode,
          serverMessage ??
              'Unexpected error occurred (${response.statusCode}).',
        );
    }
  }

  // Network exceptions (Internet issue) ko user-friendly banayein
  void _handleException(dynamic e) {
    if (e is SocketException) {
      throw ApiException(001, "Check your internet connection");
    } else if (e is TimeoutException) {
      throw ApiException(002, "Request timed out. Please try again.");
    }
  }
}
