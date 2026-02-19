import 'package:npc/core/api/api_constants.dart';
import 'package:npc/core/api/base_api_service.dart';
import 'package:npc/data/models/signup_response_model.dart';

// Repository class APIs aur app kay baki hisson kay darmiyan ek bridge ka kaam karti ha
class AuthRepository {
  final BaseApiService _apiService = BaseApiService();

  // Signup API ko call karne wala function
  Future<SignUpResponseModel> signUp(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.signUpEndpoint,
        data,
      );
      // Raw JSON data ko SignUpResponseModel object mein convert kar rhe hain
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // OTP verify karne wala function
  Future<SignUpResponseModel> verifyOtp(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.verifyOtpEndpoint,
        data,
      );
      // Data parse kar ke return kar rhe hain
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Password create karne wala function
  Future<SignUpResponseModel> createPassword(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.createPasswordEndpoint,
        data,
      );
      // Data parse kar ke return kar rhe hain
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // OTP dobara bhejne wala function
  Future<SignUpResponseModel> resendSignupOtp(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.resendSignupOtpEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Sign In karne wala function
  Future<SignUpResponseModel> signIn(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.signInEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Forgot Password wala function
  Future<SignUpResponseModel> forgotPassword(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.forgotPasswordEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP Forgot Password wala function
  Future<SignUpResponseModel> verifyOtpForgotPassword(
    Map<String, dynamic> data,
  ) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.verifyOtpForgotPasswordEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password wala function
  Future<SignUpResponseModel> resetPassword(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.resetPasswordEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Refresh Token wala function
  Future<SignUpResponseModel> refreshToken(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.refreshTokenEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Logout karne wala function
  Future<SignUpResponseModel> logout(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.logoutEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Social Login karne wala function
  Future<SignUpResponseModel> socialLogin(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.postResponse(
        ApiConstants.baseUrl + ApiConstants.socialLoginEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Account delete karne ke liye OTP mangwana
  Future<Map<String, dynamic>> deleteAccount(
    String email,
    String password,
  ) async {
    try {
      final Map<String, dynamic> data = {"email": email, "password": password};
      dynamic response = await _apiService.postAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.deleteAccountEndpoint,
        data,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Account delete verification (OTP match karna)
  Future<Map<String, dynamic>> verifyDeleteAccount(
    String email,
    String otp,
  ) async {
    try {
      final Map<String, dynamic> data = {"email": email, "otp": otp};
      dynamic response = await _apiService.postAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.verifyDeleteAccountEndpoint,
        data,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Password update karne wala function (Authorized)
  Future<SignUpResponseModel> updateUserPassword(
    Map<String, dynamic> data,
  ) async {
    try {
      dynamic response = await _apiService.patchAuthorizedResponse(
        ApiConstants.baseUrl + ApiConstants.updateUserPasswordEndpoint,
        data,
      );
      return SignUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
