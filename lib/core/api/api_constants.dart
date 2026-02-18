// App mein use hone wale saare API URLs aur endpoints yahan store honge
class ApiConstants {
  // Base URL jahan saari APIs host hain
  static const String baseUrl = 'https://api.npc.txdynamics.io/api/v1';

  // Signup karne ka specific endpoint
  static const String signUpEndpoint = '/auth/signup';

  // OTP verify karne ka endpoint
  static const String verifyOtpEndpoint = '/auth/verify-otp-signup';

  // Password create karne ka endpoint
  static const String createPasswordEndpoint = '/auth/create-password';

  // Resend OTP ka endpoint
  static const String resendSignupOtpEndpoint = '/auth/resend-signup-otp';

  // Sign In ka endpoint
  static const String signInEndpoint = '/auth/signin';

  // Forgot Password ka endpoint
  static const String forgotPasswordEndpoint = '/auth/forgot-password';

  // Verify OTP Forgot Password ka endpoint
  static const String verifyOtpForgotPasswordEndpoint =
      '/auth/verify-otp-forgot-password';

  // Reset Password ka endpoint
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // Refresh Token ka endpoint
  static const String refreshTokenEndpoint = '/auth/refresh-token';

  // Logout ka endpoint
  static const String logoutEndpoint = '/auth/logout';
  static const String deleteAccountEndpoint = '/auth/delete-account';
  static const String verifyDeleteAccountEndpoint =
      '/auth/verify-delete-account';

  // Social Login ka endpoint
  static const String socialLoginEndpoint = '/auth/social-login';

  // Profile endpoints (User ki information handle karne ke liye)
  static const String createProfileEndpoint =
      '/profile/create'; // Profile banane ke liye
  static const String getProfileEndpoint =
      '/profile/get'; // Profile mangwane ke liye
  static const String updateProfileEndpoint =
      '/profile/update'; // Profile badalne ke liye
  static const String deleteProfileEndpoint =
      '/profile/delete'; // Profile khatam karne ke liye

  // Quest endpoints (Tasks aur activities handle karne ke liye)
  static const String allQuestsEndpoint = '/quests/all-quests';
  static const String myQuestsEndpoint = '/quests/my-quests';
  static const String createQuestEndpoint = '/quests';
  static const String updateQuestStatusEndpoint =
      '/quests'; // /quests/{id}/{action} ke liye base
  static const String userCoinsEndpoint = '/user/coins';
  static const String teamQuestsByUserIdEndpoint = '/quests/user';
}
