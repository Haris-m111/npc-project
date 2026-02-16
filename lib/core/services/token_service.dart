import 'package:shared_preferences/shared_preferences.dart';

// Ye service sirf Auth Tokens (Access aur Refresh) ko handle krti ha
class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Tokens save krne ke liye
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Access Token hasil krne ke liye
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Refresh Token hasil krne ke liye
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Logout ke waqt tokens delete krne ke liye
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
