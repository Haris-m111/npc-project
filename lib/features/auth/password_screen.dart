import 'package:flutter/material.dart';
import 'package:npc/core/utils/validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/features/settings/create_profile_screen.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart';

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
  final TextEditingController _passController =
      TextEditingController(); // Password field ke liye controller
  final TextEditingController _confirmPassController =
      TextEditingController(); // Confirm password ke liye controller
  bool _isLoading = false; // Button pe loading dikhanay ke liye
  bool _emailSent = false; // Kya password reset link bhej diya gaya hai?

  @override
  void dispose() {
    // Screen band hone pe controllers ko saaf (cleanup) karne ke liye
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
                      SizedBox(height: 20.h),
                      // Agar password reset link bhej diya ho, to ye UI dikhao
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
                        // Password aur Confirm Password ke inputs
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
                child: CustomButton(
                  isLoading: _isLoading,
                  text: _emailSent ? "VERIFY & GO TO LOGIN" : widget.buttonText,
                  onPressed: () async {
                    FocusScope.of(
                      context,
                    ).unfocus(); // Keyboard band karne ke liye

                    final pass = _passController.text.trim();

                    // Agar email pehle hi bhej di gayi hai (Verification flow)
                    if (_emailSent) {
                      setState(() => _isLoading = true);
                      try {
                        // Naye password ke saath check karo kya link se update ho gaya?
                        await AuthService().login(widget.email, pass);
                        await AuthService()
                            .signOut(); // Verification ke baad logout

                        if (!context.mounted) return;
                        widget.onButtonPressed(
                          context,
                        ); // Aglay step pe bhijwao
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Verification failed. Please ensure you have opened the link in your email to update your password.",
                            isError: true,
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                      return;
                    }
                    final confirmPass = _confirmPassController.text.trim();

                    // Check kya password wali fields bhari hui hain?
                    if (pass.isEmpty || confirmPass.isEmpty) {
                      SnackbarHelper.showTopSnackBar(
                        context,
                        "Please Enter Password or Confirm Password",
                        isError: true,
                      );
                      return;
                    }

                    // Check kya dono passwords milte (match) hain?
                    if (pass != confirmPass) {
                      SnackbarHelper.showTopSnackBar(
                        context,
                        "Confirm password incorrect",
                        isError: true,
                      );
                      return;
                    }

                    // Password ki strength check karna (e.g. length, special chars)
                    String? passwordError = Validators.validatePassword(pass);
                    if (passwordError != null) {
                      SnackbarHelper.showTopSnackBar(
                        context,
                        passwordError,
                        isError: true,
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    // Slight delay for visibility as requested
                    await Future.delayed(const Duration(milliseconds: 800));

                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    if (!context.mounted) return;

                    // Case 1: Agar password update karna ho (Forgot Password flow)
                    if (widget.buttonText == "UPDATE PASSWORD") {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        // Firebase ke zariye password update karne ke liye link bhejo
                        await AuthService().updatePassword(widget.email, pass);

                        if (!context.mounted) return;

                        SnackbarHelper.showTopSnackBar(
                          context,
                          "Password reset link sent successfully",
                          isSuccess: true,
                        );

                        if (mounted) {
                          setState(() {
                            _emailSent = true;
                          });
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        String message = "Error updating password: $e";
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
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    } else {
                      // Case 2: Agar account naya banana ho (Signup flow)
                      setState(() => _isLoading = true);

                      try {
                        // User ka account (Email + Password) create karo
                        await AuthService().createAuthUser(
                          email: widget.email,
                          password: pass,
                        );

                        if (!context.mounted) return;
                        // Account banne ke baad name/profile wali screen pe bhijwao
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const CreateProfileScreen(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          String message = "Registration Failed: $e";
                          if (e.toString().toLowerCase().contains('network') ||
                              e.toString().toLowerCase().contains(
                                'connection',
                              )) {
                            message =
                                "No internet connection. Please check your network and try again";
                          }
                          SnackbarHelper.showTopSnackBar(
                            context,
                            message,
                            isError: true,
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
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
