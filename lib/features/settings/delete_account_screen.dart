import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/features/auth/otp_screen.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart';

// User ka apna account permanently delete karne wala screen
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController =
      TextEditingController(); // Password input control karne ke liye
  bool _isLoading = false; // Button pe loading animation dikhanay ke liye

  @override
  void dispose() {
    _passwordController
        .dispose(); // Memory bachanay ke liye controller khatam karna
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
                            color: AppColors.errorRed,
                            size: 24.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Delete your account will:",
                            style: AppTextStyles.body.copyWith(
                              color: Colors.red,
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

                      SizedBox(height: 16.h),

                      // Password enter karne wala field
                      CustomTextfields(
                        controller: _passwordController,
                        hintText: "Enter your password",
                        isPassword: true,
                        prefixIconPath: AppAssets.lockIcon,
                      ),

                      SizedBox(height: 16.h),

                      // Paragraph 3 (Warning)
                      Text(
                        "To delete your account, please enter your password in the field below and confirm your decision by clicking the 'Delete My Account' button.",
                        style: AppTextStyles.bodysmall.copyWith(height: 1.5),
                        textAlign: TextAlign.justify,
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // Delete button pe click ka action: Password check aur OTP send karna
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: _isLoading
                    ? const CustomLoadingIndicator()
                    : CustomButton(
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

                          setState(() => _isLoading = true);

                          try {
                            // User ka email nikalna taake OTP bheja ja sakay
                            String? email = AuthService().getCurrentUserEmail();
                            if (email == null) {
                              throw Exception("Unable to get user email");
                            }

                            // Re-authenticate: Password check karna ke sahi hai ya nahi
                            await AuthService().reauthenticateUser(password);

                            // Send OTP to email (Tasdeeqi code bhejna)
                            bool otpSent = await AuthService().sendOtp(email);
                            if (!otpSent) {
                              throw Exception("Failed to send OTP");
                            }

                            if (!context.mounted) return;
                            setState(() => _isLoading = false);

                            SnackbarHelper.showTopSnackBar(
                              context,
                              "OTP has been sent to your email",
                              isSuccess: true,
                            );

                            await Future.delayed(const Duration(seconds: 1));
                            if (!context.mounted) return;

                            // OTP screen per jana account delete confirm karne ke liye
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtpScreen(isfromdelete: true, email: email),
                              ),
                            );
                          } catch (e) {
                            if (mounted) {
                              setState(() => _isLoading = false);
                              SnackbarHelper.showTopSnackBar(
                                context,
                                e.toString().replaceAll('Exception: ', ''),
                                isError: true,
                              );
                            }
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
