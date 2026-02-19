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

  String? _userId; // Logged in user ki ID store karne ke liye
  String? get userId => _userId;

  String? _userEmail; // Logged in user ki email store karne ke liye
  String? get userEmail => _userEmail;

  String?
  _pendingDeletionPassword; // Account delete karne ke liye temporary password save kar rhy hain
  String? get pendingDeletionPassword => _pendingDeletionPassword;

  String? _socialEmail; // Social login se mili hui email
  String? get socialEmail => _socialEmail;

  String? _socialName; // Social login se mila hua naam
  String? get socialName => _socialName;

  String? _socialPicture; // Social login se mili hui picture
  String? get socialPicture => _socialPicture;

  // Loading state change karne aur UI notify karne ka function
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // User object se ID nikalne ka helper
  void _extractAndSaveUserId(Map<String, dynamic>? userMap) {
    if (userMap != null) {
      _userId =
          userMap['id']?.toString() ??
          userMap['_id']?.toString() ??
          userMap['userId']?.toString();
      _userEmail = userMap['email']?.toString(); // Email bhi save kar rhy hain
      debugPrint(
        "DEBUG: Extracted User Data -> ID: $_userId, Email: $_userEmail",
      );
    }
  }

  // Social data clear karne ke liye
  void clearSocialData() {
    _socialEmail = null;
    _socialName = null;
    _socialPicture = null;
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
      await _authRepository.signUp(data);
      _successMessage =
          "OTP sent to email"; // User requirement: "OTP sent to email"
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
      _successMessage = "OTP Successful"; // User requirement: "OTP Successful"

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
        _errorMessage = "Invalid OTP"; // User requirement: "Invalid OTP"
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
        _extractAndSaveUserId(response.user); // ID aur Email save kr rhy hain
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
          userId, // Persistent storage me bhi save kr rhy hain
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
        debugPrint("Access Token: ${response.accessToken}");
        _extractAndSaveUserId(response.user); // ID aur Email save kr rhy hain
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
          _userId, // Local storage me persistent save kr rhy hain
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 401) {
          _errorMessage = "Incorrect password";
        } else if (e.statusCode == 403) {
          _errorMessage = e.message;
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
      // Verify OTP Forgot Password success: Status 200
      _successMessage = "OTP Successful"; // User requirement: "OTP Successful"
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 400) {
        _errorMessage = "Invalid OTP"; // User requirement: "Invalid OTP"
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
      await _tokenService.clearAll();
      _userId = null;
      _userEmail = null;
      _pendingDeletionPassword = null;
      _successMessage = "Logged out successfully";

      _setLoading(false);
      return true;
    } catch (e) {
      // Agar logout fail bhi ho jaye (e.g. token expire),
      // phir bhi hum locally logout kr dain gay
      await _tokenService.clearAll();
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // App start hotay waqt purani session/ID recover karne ke liye
  Future<void> restoreSession() async {
    final savedId = await _tokenService.getUserId();
    if (savedId != null) {
      _userId = savedId;
      debugPrint("DEBUG: Session Restored. User ID: $_userId");
      notifyListeners();
    }
  }

  // Google Sign In karne ka logic (Social Login)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      debugPrint("DEBUG: Starting Google Sign In Flow...");
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Pehle sign out kryn takay har bar account selection ka option aaye (As requested by user)
      debugPrint("DEBUG: Signing out from Google to force account picker...");
      await googleSignIn.signOut();

      debugPrint("DEBUG: Calling googleSignIn.signIn()...");
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint(
          "DEBUG: Google Sign In cancelled by user (googleUser is null).",
        );
        _setLoading(false);
        return false;
      }

      debugPrint("DEBUG: User selected: ${googleUser.email}");
      _socialEmail = googleUser.email;
      _socialName = googleUser.displayName;
      _socialPicture = googleUser.photoUrl;

      debugPrint("DEBUG: Getting authentication details...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      debugPrint(
        "DEBUG: Google Auth success. idToken: ${idToken != null}, accessToken: ${accessToken != null}",
      );

      if (idToken == null) {
        _errorMessage = "Google ID Token not found. Please try again.";
        debugPrint("DEBUG: Error -> ID Token is null");
        _setLoading(false);
        return false;
      }

      final Map<String, dynamic> data = {
        "provider": "google",
        "token": idToken, // Backend usually expects idToken for verification
        "platform": Platform.isAndroid ? "android" : "ios",
        "role": "user",
      };

      debugPrint("DEBUG: Sending Social Login Request to Backend...");
      debugPrint("DEBUG: Request Data -> $data");

      final response = await _authRepository.socialLogin(data);

      debugPrint("DEBUG: Backend Response received.");

      // Tokens save kr rhe hain
      if (response.accessToken != null && response.refreshToken != null) {
        debugPrint("DEBUG: Social Login success. Saving tokens and User ID.");
        _extractAndSaveUserId(response.user);
        await _tokenService.saveTokens(
          response.accessToken!,
          response.refreshToken!,
          _userId, // Persistent save
        );
        _successMessage = response.message ?? "Social login successful";
        _setLoading(false);
        return true;
      } else {
        _errorMessage = "Invalid response from server (Missing tokens)";
        debugPrint(
          "DEBUG: Error -> response.accessToken or refreshToken is null",
        );
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint("DEBUG: Google Sign In CRITICAL Error -> $e");
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  // Account delete karne ke liye OTP mangwane ka logic
  // Account delete karne ke liye OTP mangwana ke liye (Email + Password Verification)
  Future<bool> deleteAccount(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      await _authRepository.deleteAccount(email, password);
      _pendingDeletionPassword =
          password; // Resend ke liye password save kr rhy hain
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
      await _tokenService.clearAll();

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

  // Naya Password update karne ka logic (Authorized Flow)
  Future<bool> updateUserPassword(
    String oldPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final Map<String, dynamic> data = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    };

    try {
      final response = await _authRepository.updateUserPassword(data);
      _successMessage = response.message ?? "Password updated successfully";
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
