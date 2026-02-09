import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/features/auth/otp_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart';

// Password bhool janay ki soorat mein recovery screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController =
      TextEditingController(); // Email field ke liye controller
  bool _isLoading = false; // Loading status batane ke liye

  @override
  void dispose() {
    // Screen khatam honay pe controller ko memory se saaf (cleanup) karne ke liye
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen ka header (Custom AppBar)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 10.h),
                child: const CustomAppBar(title: ""),
              ),

              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        'Forgot Password',
                        style: AppTextStyles.mainheading,
                      ), // Main heading
                      SizedBox(height: 16.h),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo .',
                        style: AppTextStyles.bodysmall,
                      ),
                      SizedBox(height: 15.h),

                      Text(
                        'Email',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      CustomTextfields.email(controller: _emailController),
                    ],
                  ),
                ),
              ),

              // BUTTON (Outside Scroll, moves with keyboard)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: CustomButton(
                  isLoading: _isLoading,
                  text: "NEXT",
                  onPressed: () async {
                    FocusScope.of(
                      context,
                    ).unfocus(); // Keyboard band karne ke liye
                    String email = _emailController.text.trim();
                    // Check kya email khali to nahi?
                    if (email.isEmpty) {
                      SnackbarHelper.showTopSnackBar(
                        context,
                        "Please enter email",
                        isError: true,
                      );
                      return;
                    }
                    // Check kya email ka format sahi hai?
                    if (!email.toLowerCase().endsWith("mail.com")) {
                      SnackbarHelper.showTopSnackBar(
                        context,
                        "Invalid email",
                        isError: true,
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    try {
                      // Check kya ye email system mein mojood hai?
                      bool emailExists = await AuthService().isEmailRegistered(
                        email,
                      );

                      if (!emailExists) {
                        if (!context.mounted) return;
                        setState(() => _isLoading = false);
                        SnackbarHelper.showTopSnackBar(
                          context,
                          "Email not found. Please enter a registered email.",
                          isError: true,
                        );
                        return;
                      }

                      // OTP bhaijne ka process shuru
                      bool success = await AuthService().sendOtp(email);

                      if (!context.mounted) return;
                      setState(() => _isLoading = false);

                      if (success) {
                        SnackbarHelper.showTopSnackBar(
                          context,
                          "OTP has been sent to your email",
                          isSuccess: true,
                        );
                        await Future.delayed(const Duration(seconds: 1));
                        if (!context.mounted) return;
                        // OTP enter karne wali screen pe bhijwao
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                OtpScreen(isfromforgot: true, email: email),
                          ),
                        );
                      } else {
                        SnackbarHelper.showTopSnackBar(
                          context,
                          "Failed to send OTP. Try again.",
                          isError: true,
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isLoading = false);
                      String message = "Error: $e";
                      // Internet ka masla check karne ke liye
                      if (e.toString().toLowerCase().contains('network') ||
                          e.toString().toLowerCase().contains('connection')) {
                        message =
                            "No internet connection. Please check your network and try again";
                      }
                      SnackbarHelper.showTopSnackBar(
                        context,
                        message,
                        isError: true,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
