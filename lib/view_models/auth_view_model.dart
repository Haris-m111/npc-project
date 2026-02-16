import 'package:flutter/material.dart';
import 'package:npc/data/repositories/auth_repository.dart';
import 'package:npc/core/services/token_service.dart';

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
      _successMessage = response.message;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      final response = await _authRepository.resendSignupOtp(data);
      _successMessage = response.message;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      _successMessage = response.message;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      _successMessage = response.message;

      // Tokens save kr rhe hain
      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      final response = await _authRepository.forgotPassword(data);
      _successMessage = response.message;
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
      final response = await _authRepository.verifyOtpForgotPassword(data);
      _successMessage = response.message;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      final response = await _authRepository.resetPassword(data);
      _successMessage = response.message;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      _successMessage = response.message;

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
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
