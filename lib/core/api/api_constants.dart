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
}
