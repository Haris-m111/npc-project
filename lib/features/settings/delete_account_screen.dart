import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/features/auth/otp_screen.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';

// User ka apna account permanently delete karne wala screen
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
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
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 35.h, 20.w, 10.h),
                child: const CustomAppBar(title: "Delete Account"),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      // Khatray ka nishan aur warning text
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.red,
                            size: 24.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Delete your account will:",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Paragraph 1
                      Text(
                        "We're sorry to see you go. If you're sure you want to delete your NPC's account, please be aware that this action is permanent and cannot be undone. All of your personal information, including your NPC's and settings, will be permanently deleted.",
                        style: AppTextStyles.bodysmall.copyWith(height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 10.h),
                      // Paragraph 2
                      Text(
                        "If you're having trouble with your account or have concerns, please reach out to us at [contact email or support page] before proceeding with the account deletion. We'd love to help you resolve any issues and keep you as a valued NPC's user.",
                        style: AppTextStyles.bodysmall.copyWith(height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 25.h),
                      CustomTextfields(
                        hintText: "Enter your password",
                        isPassword: true,
                        prefixIconPath: AppAssets.lockIcon,
                        controller: _passwordController,
                      ),

                      SizedBox(height: 20.h),

                      // Paragraph 3 (Warning)
                      Text(
                        "To delete your account, please confirm your decision by clicking the 'Delete My Account' button. A verification OTP will be sent to your email.",
                        style: AppTextStyles.bodysmall.copyWith(height: 1.5),
                        textAlign: TextAlign.justify,
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // Delete button pe click ka action: OTP mangwana
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return CustomButton(
                      isLoading: authVM.isLoading,
                      text: "DELETE ACCOUNT",
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        String password = _passwordController.text.trim();
                        if (password.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please enter your password",
                            isError: true,
                          );
                          return;
                        }

                        // 1. Pehle AuthViewModel se email nikalne ki koshish karain gay (Source of truth for login)
                        String? email = authVM.userEmail;

                        // 2. Fallback: Agar AuthVM me nahi hai to ProfileViewModel se check karain gay
                        if (email == null || email.isEmpty) {
                          final profileVM = Provider.of<ProfileViewModel>(
                            context,
                            listen: false,
                          );
                          email = profileVM.userProfile?.email;
                        }

                        // 3. Fallback: Agar dono me nahi hai to social email check karain gay
                        if (email == null || email.isEmpty) {
                          email = authVM.socialEmail;
                        }

                        if (email == null || email.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "User email not found. Please logout and login again.",
                            isError: true,
                          );
                          return;
                        }

                        // shadowing with non-nullable String taake niche '!' bar bar na lagana paray
                        final String finalEmail = email;

                        // API call: OTP mangnay ke liye (Email + Password Verification)
                        bool success = await authVM.deleteAccount(
                          finalEmail,
                          password,
                        );

                        if (!context.mounted) return;

                        if (success) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            authVM.successMessage ?? "OTP sent to your email",
                            isSuccess: true,
                          );

                          await Future.delayed(const Duration(seconds: 1));
                          if (!context.mounted) return;

                          // OTP screen pr bhejna account deletion confirm krnay ke liye
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(
                                isfromdelete: true,
                                email: finalEmail,
                              ),
                            ),
                          );
                        } else {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            authVM.errorMessage ?? "Failed to send OTP",
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
