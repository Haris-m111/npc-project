import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/features/auth/otp_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/core/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';

// Password bhool janay ki soorat mein recovery screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 10.h),
                child: const CustomAppBar(title: ""),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Text('Forgot Password', style: AppTextStyles.mainheading),
                      SizedBox(height: 16.h),
                      Text(
                        'Don\'t worry! Enter your registered email to receive an OTP for password reset.',
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
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return CustomButton(
                      isLoading: authVM.isLoading,
                      text: "NEXT",
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        String email = _emailController.text.trim();

                        if (email.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please enter your email",
                            isError: true,
                          );
                          return;
                        }

                        final emailValidation = Validators.validateEmail(email);
                        if (emailValidation != null) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please enter a valid email",
                            isError: true,
                          );
                          return;
                        }

                        // API Forgot Password call
                        bool success = await authVM.forgotPassword(email);

                        if (!context.mounted) return;

                        if (success) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            authVM.successMessage ??
                                "OTP sent for password reset.",
                            isSuccess: true,
                          );
                          await Future.delayed(const Duration(seconds: 1));
                          if (!context.mounted) return;

                          // OTP Screen par bhej rhe hain reset flow ke liye
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtpScreen(isfromforgot: true, email: email),
                            ),
                          );
                        } else {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            authVM.errorMessage ?? "Failed to send reset OTP",
                            isError: true,
                          );
                        }
                      },
                    );
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
