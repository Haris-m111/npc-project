import 'package:flutter/material.dart';
import 'package:npc/core/utils/validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_dialogue.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';

// User ka existing password update (Change) karne wala screen
class UpdatePassScreen extends StatefulWidget {
  const UpdatePassScreen({super.key});

  @override
  State<UpdatePassScreen> createState() => _UpdatePassScreenState();
}

class _UpdatePassScreenState extends State<UpdatePassScreen> {
  // Input fields ke liye controllers (Old, New aur Confirm passwords)
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false; // Button par loading dikhanay ke liye

  @override
  void dispose() {
    // Memory bachanay ke liye controllers ko khatam karna
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
              //  STUCK APP BAR
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 10.h),
                child: const CustomAppBar(title: "Change Password"),
              ),

              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 26.h),
                      Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In in nulla rutrum, ultrices nulla at,",
                        style: AppTextStyles.bodysmall,
                      ),
                      SizedBox(height: 20.h),

                      // Old Password
                      _label("Enter Old Password"),
                      SizedBox(height: 12.h),
                      CustomTextfields(
                        controller: _oldPasswordController,
                        hintText: "Enter your old password",
                        isPassword: true,
                        prefixIconPath: AppAssets.lockIcon,
                      ),

                      SizedBox(height: 16.h),

                      // New Password
                      _label("Enter New Password"),
                      SizedBox(height: 12.h),
                      CustomTextfields(
                        controller: _newPasswordController,
                        hintText: "Enter your new password",
                        isPassword: true,
                        prefixIconPath: AppAssets.lockIcon,
                      ),

                      SizedBox(height: 16.h),

                      // Confirm Password
                      _label("Confirm New Password"),
                      SizedBox(height: 12.h),
                      CustomTextfields(
                        controller: _confirmPasswordController,
                        hintText: "Confirm your new password",
                        isPassword: true,
                        prefixIconPath: AppAssets.lockIcon,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // Update button pe click ka action
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: _isLoading
                    ? const CustomLoadingIndicator()
                    : CustomButton(
                        text: "UPDATE PASSWORD",
                        onPressed: () async {
                          FocusScope.of(context).unfocus();

                          String oldPassword = _oldPasswordController.text
                              .trim();
                          String newPassword = _newPasswordController.text
                              .trim();
                          String confirmPassword = _confirmPasswordController
                              .text
                              .trim();

                          // 1. Khali fields ki checking
                          if (oldPassword.isEmpty ||
                              newPassword.isEmpty ||
                              confirmPassword.isEmpty) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Please fill all fields",
                              isError: true,
                            );
                            return;
                          }

                          // 2. Dono naye passwords ka aik jaisa hona zaroori hai
                          if (newPassword != confirmPassword) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "New passwords do not match",
                              isError: true,
                            );
                            return;
                          }

                          // 3. Password ki quality/strength check karna
                          String? passwordError = Validators.validatePassword(
                            newPassword,
                          );
                          if (passwordError != null) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              passwordError,
                              isError: true,
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            // Backend API ke zariye password tabdeel karna
                            final authVM = Provider.of<AuthViewModel>(
                              context,
                              listen: false,
                            );
                            bool success = await authVM.updateUserPassword(
                              oldPassword,
                              newPassword,
                            );

                            if (!context.mounted) return;
                            setState(() => _isLoading = false);

                            if (success) {
                              // Kamyabi ka message dikhana
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const CustomDialogue(
                                  title: "Password Updated",
                                ),
                              );

                              Future.delayed(const Duration(seconds: 2), () {
                                if (context.mounted) {
                                  Navigator.pop(context); // Dialog band karna
                                  Navigator.pop(
                                    context,
                                  ); // Setting screen pe wapis jana
                                }
                              });
                            } else {
                              SnackbarHelper.showTopSnackBar(
                                context,
                                authVM.errorMessage ??
                                    "Failed to update password",
                                isError: true,
                              );
                            }
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

  Widget _label(String text) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(color: AppColors.black),
    );
  }
}
