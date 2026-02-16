import 'dart:convert';
import 'package:http/http.dart' as http;

// Ye class networking calls (HTTP requests) ko handle karne ke liye banayi gayi hai
class BaseApiService {
  // POST request bheilne ka function
  Future<dynamic> postResponse(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        }, // Server ko bata rhe hain ke data JSON hai
        body: jsonEncode(
          data,
        ), // Dart Map ko JSON string mein convert kar rhe hain
      );
      return _returnResponse(
        response,
      ); // Response ka status check karne ke liye helper function call
    } catch (e) {
      rethrow; // Error ko agay pass kar dena
    }
  }

  // Server sy aaye hue response codes ko check karne ka logic
  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        // Agar status 200 ya 201 hai to data return karo
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
      case 403:
        throw Exception('Unauthorized: ${response.body}');
      case 500:
      default:
        throw Exception('Server Error: ${response.statusCode}');
    }
  }
}
