import 'package:flutter/material.dart';
import 'package:npc/core/utils/validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/features/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';
import 'package:npc/features/settings/create_profile_screen.dart';

// Naya password banane ya purana update karne wali screen
class PasswordScreen extends StatefulWidget {
  final String title; // Screen ka heading (e.g. Create Password)
  final String description;
  final String firstFieldLabel; // Pehle input box ka label
  final String secondFieldLabel; // Doosre input box ka label
  final String buttonText; // Button ka text
  final Function(BuildContext)
  onButtonPressed; // Button click pe hone wala action
  final String email; // User ka email jo authentication mein use hoga

  const PasswordScreen({
    super.key,
    required this.title,
    required this.description,
    required this.firstFieldLabel,
    required this.secondFieldLabel,
    required this.buttonText,
    required this.onButtonPressed,
    this.email = "",
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isLoading = false; // Firebase operations ke liye (Forgot Password)
  bool _emailSent = false; // Password reset link status

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
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
                      Text(widget.title, style: AppTextStyles.mainheading),
                      SizedBox(height: 16.h),
                      Text(widget.description, style: AppTextStyles.bodysmall),
                      SizedBox(height: 20.h),
                      if (_emailSent) ...[
                        Center(
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            size: 80.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          "We've sent a password reset link to your email. Please check your inbox and follow the link to update your password.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Once you have updated it, you can proceed to the Login screen.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodysmall.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Text(
                          widget.firstFieldLabel,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        CustomTextfields(
                          controller: _passController,
                          hintText: "Enter your password",
                          isPassword: true,
                          prefixIconPath: AppAssets.lockIcon,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          widget.secondFieldLabel,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        CustomTextfields(
                          controller: _confirmPassController,
                          hintText: "Confirm your password",
                          isPassword: true,
                          prefixIconPath: AppAssets.lockIcon,
                        ),
                      ],
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return CustomButton(
                      isLoading: authVM.isLoading || _isLoading,
                      text: _emailSent
                          ? "VERIFY & GO TO LOGIN"
                          : widget.buttonText,
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        final pass = _passController.text.trim();

                        if (_emailSent) {
                          setState(() => _isLoading = true);
                          try {
                            // Firebase verification flow
                            await AuthService().login(widget.email, pass);
                            await AuthService().signOut();
                            if (!context.mounted) return;
                            widget.onButtonPressed(context);
                          } catch (e) {
                            if (context.mounted) {
                              SnackbarHelper.showTopSnackBar(
                                context,
                                "Verification failed. Link check kryn.",
                                isError: true,
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                          return;
                        }

                        final confirmPass = _confirmPassController.text.trim();

                        // Validations
                        if (pass.isEmpty || confirmPass.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please Enter Password or Confirm Password",
                            isError: true,
                          );
                          return;
                        }

                        if (pass != confirmPass) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Confirm password incorrect",
                            isError: true,
                          );
                          return;
                        }

                        String? passwordError = Validators.validatePassword(
                          pass,
                        );
                        if (passwordError != null) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            passwordError,
                            isError: true,
                          );
                          return;
                        }

                        if (widget.buttonText == "UPDATE PASSWORD") {
                          // API Integration for Reset Password (Forgot Pass)
                          bool success = await authVM.resetPassword(
                            widget.email,
                            pass,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.successMessage ??
                                  "Password updated successfully!",
                              isSuccess: true,
                            );
                            await Future.delayed(const Duration(seconds: 1));
                            if (!context.mounted) return;

                            // Success kay baad Login screen par bhej rhy hain
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.errorMessage ??
                                  "Failed to update password",
                              isError: true,
                            );
                          }
                        } else {
                          // API Integration for Create Password
                          bool success = await authVM.createPassword(
                            widget.email,
                            pass,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.successMessage ?? "Password created!",
                              isSuccess: true,
                            );
                            await Future.delayed(const Duration(seconds: 1));
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateProfileScreen(email: widget.email),
                              ),
                              (route) => false,
                            );
                          } else {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.errorMessage ??
                                  "Failed to create password",
                              isError: true,
                            );
                          }
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
