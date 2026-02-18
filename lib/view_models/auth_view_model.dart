import 'package:flutter/material.dart';
import 'package:npc/data/repositories/auth_repository.dart';
import 'package:npc/core/api/base_api_service.dart';
import 'package:npc/core/services/token_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

// ViewModel UI ki state manage karti ha aur business logic handle karti ha
class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final TokenService _tokenService = TokenService();

  bool _isLoading = false; // Loading state (True jab API hit ho rahi ho)
  bool get isLoading => _isLoading;

  String? _errorMessage; // Error message dikhane ke liye
  String? get errorMessage => _errorMessage;

  String? _successMessage; // Success message (e.g. Signup ho gya)
  String? get successMessage => _successMessage;

  // Loading state change karne aur UI notify karne ka function
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Signup karne ka logic jo Repository ko call karta hai
  Future<bool> signUp(String email, String referralToken) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {
      "email": email,
      "role": "user",
      "referralToken": referralToken,
    };

    try {
      // Repository call
      final response = await _authRepository.signUp(data);
      _successMessage = response.message; // Success response save kar rhe hain
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString(); // Error message save kar rhe hain
      _setLoading(false);
      return false;
    }
  }

  // OTP verify karne ka logic
  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"email": email, "otp": otp};

    try {
      final response = await _authRepository.verifyOtp(data);
      // Verify OTP Signup success: Status 200
      _successMessage = "Signup verified successfully";

      // Agar API tokens deti hai (Signup flow), to save kryn
      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 400) {
        _errorMessage = "Invalid or expired OTP or already verified";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // OTP doobara bhejne ka logic
  Future<bool> resendOtp(String email) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"email": email};

    try {
      await _authRepository.resendSignupOtp(data);
      // Resend OTP success: Status 200
      _successMessage = "OTP resent successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 400) {
        _errorMessage = "Invalid request (e.g., already verified)";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Password create karne ka logic
  Future<bool> createPassword(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"email": email, "newPassword": password};

    try {
      final response = await _authRepository.createPassword(data);
      // Create Password success: Status 200
      _successMessage = "Password set successfully";

      // Password creation ke baad aksar tokens milte hain taake user login ho jaye
      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 403) {
        _errorMessage = "OTP not verified or user not found";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Sign In karne ka logic
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"email": email, "password": password};

    try {
      final response = await _authRepository.signIn(data);
      // SignIn success: Status 200
      _successMessage = "Login successful";

      // Tokens save kr rhe hain
      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );
        // DEBUG: Swagger ke liye token print karwa rhe hain
        print("DEBUG_TOKEN (Copy this for Swagger): ${response.accessToken}");
      }

      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 401) {
          _errorMessage = "Incorrect password";
        } else if (e.statusCode == 403) {
          _errorMessage = "Invalid or unverified user";
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Forgot Password ka logic
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"email": email};

    try {
      await _authRepository.forgotPassword(data);
      // Forgot Password success: Status 200
      _successMessage = "OTP sent for password reset";
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP Forgot Password ka logic
  Future<bool> verifyOtpForgotPassword(String email, String otp) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"email": email, "otp": otp};

    try {
      await _authRepository.verifyOtpForgotPassword(data);
      // Verify OTP Forgot success: Status 200
      _successMessage = "OTP verified";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 400) {
        _errorMessage = "Invalid or expired OTP";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Reset Password ka logic
  Future<bool> resetPassword(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"email": email, "newPassword": password};

    try {
      await _authRepository.resetPassword(data);
      // Reset Password success: Status 200
      _successMessage = "Password reset successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 403) {
        _errorMessage = "Reset not allowed";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Refresh Token ka logic
  Future<bool> refreshToken(String refreshToken) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {"refreshToken": refreshToken};

    try {
      final response = await _authRepository.refreshToken(data);
      // Refresh Token success: Status 200
      _successMessage = "New tokens issued";

      // Naye tokens save kr rhe hain
      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 403) {
        _errorMessage = "Invalid or expired refresh token";
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Logout karne ka logic
  Future<bool> logout() async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        final Map<String, dynamic> data = {"refreshToken": refreshToken};
        await _authRepository.logout(data);
      }

      // Tokens locally clear kr rhe hain
      await _tokenService.clearTokens();
      _successMessage = "Logged out successfully";

      _setLoading(false);
      return true;
    } catch (e) {
      // Agar logout fail bhi ho jaye (e.g. token expire),
      // phir bhi hum locally logout kr dain gay
      await _tokenService.clearTokens();
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Google Sign In karne ka logic (Social Login)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _setLoading(false);
        return false; // User ne cancel kr diya
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _errorMessage = "Google ID Token not found.";
        _setLoading(false);
        return false;
      }

      final Map<String, dynamic> data = {
        "provider": "google",
        "token": idToken,
        "platform": Platform.isAndroid ? "android" : "ios",
        "role": "user",
      };

      final response = await _authRepository.socialLogin(data);

      // Tokens save kr rhe hain
      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );
      }

      _successMessage = "Social login successful";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 400) {
          _errorMessage = "Missing or unsupported provider or token";
        } else if (e.statusCode == 500) {
          _errorMessage = "Social login failed due to server error";
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Account delete karne ke liye OTP mangwane ka logic
  Future<bool> deleteAccount(String email) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      await _authRepository.deleteAccount(email);
      _successMessage = "OTP sent for account deletion";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 404) {
          _errorMessage = "User not found";
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Account delete verification ka logic
  Future<bool> verifyDeleteAccount(String email, String otp) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      await _authRepository.verifyDeleteAccount(email, otp);

      // Account delete ho gaya, tokens clear kr dain gay
      await _tokenService.clearTokens();

      _successMessage = "Account deleted";
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 400) {
          _errorMessage = "Invalid or expired OTP";
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }
}
