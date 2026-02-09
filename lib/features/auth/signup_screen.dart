import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/features/auth/login_screen.dart';
import 'package:npc/features/auth/otp_screen.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/core/utils/validators.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/features/settings/create_profile_screen.dart';

// Naya account banane (Registration) ke liye screen
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController =
      TextEditingController(); // Email input field ke liye
  bool _isLoading = false; // Button pe loading state dikhanay ke liye

  @override
  void dispose() {
    // Screen band hone pe controller ko memory se saaf karne ke liye
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Back button daba kar app direct band na ho jaye
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop(); // App exit karne ke liye
      },
      child: Scaffold(
        backgroundColor: AppColors.bgcolor,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 110.h),
                  Text('Sign Up', style: AppTextStyles.mainheading),
                  SizedBox(height: 16.h),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo .',
                    style: AppTextStyles.bodysmall,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Email',
                    style: AppTextStyles.body.copyWith(color: AppColors.black),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextfields.email(controller: _emailController),

                  SizedBox(height: 50.h),
                  Center(
                    child: CustomButton(
                      isLoading: _isLoading,
                      text: "SIGN UP",
                      onPressed: () async {
                        FocusScope.of(context).unfocus(); // Keyboard band karo
                        String email = _emailController.text.trim();

                        // Check kya email field khali hai?
                        if (email.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please enter email",
                            isError: true,
                          );
                          return;
                        }

                        // Email ka sahi format (e.g. @) check karna
                        String? emailError = Validators.validateEmail(email);
                        if (emailError != null) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            emailError,
                            isError: true,
                          );
                          return;
                        }

                        setState(() => _isLoading = true);

                        try {
                          // Check kya ye email pehle se register to nahi?
                          bool isRegistered = await AuthService()
                              .isEmailRegistered(email);

                          if (isRegistered) {
                            if (!context.mounted) return;
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Email is already registered. Please login.",
                              isError: true,
                            );
                            setState(() => _isLoading = false);
                            return;
                          }

                          // OTP bhejne ka process shuru
                          bool success = await AuthService().sendOtp(email);
                          if (!context.mounted) return;

                          if (success) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "OTP has been sent to your email",
                              isSuccess: true,
                            );
                            // Thora intezar taake message nazar aa jaye
                            await Future.delayed(const Duration(seconds: 1));
                            if (!context.mounted) return;

                            // OTP verify karne wali screen pe bhijwao
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtpScreen(isfromsignup: true, email: email),
                              ),
                            );
                          } else {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Failed to send OTP. Try again.",
                              isError: true,
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String message = "Sign up failed";
                          if (e.code == 'network-request-failed') {
                            message =
                                "No internet connection. Please check your network and try again";
                          } else {
                            message = e.message ?? "Sign up failed";
                          }

                          if (context.mounted) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              message,
                              isError: true,
                            );
                          }
                        } catch (e) {
                          String message =
                              "Registration error. Please try again.";
                          if (e.toString().toLowerCase().contains('network') ||
                              e.toString().toLowerCase().contains(
                                'connection',
                              )) {
                            message =
                                "No internet connection. Please check your network and try again";
                          }
                          if (context.mounted) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              message,
                              isError: true,
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account ',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textHintGrey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Agar account hai to Login screen pe jao
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Login',
                            style: AppTextStyles.bodysmall.copyWith(
                              fontSize: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          AppAssets.leftLine,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          ' or ',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Image.asset(
                          AppAssets.rightLine,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35.h),
                  Center(
                    child: Text(
                      'Continue with',
                      style: AppTextStyles.headingsmall.copyWith(
                        color: AppColors.textMutedGrey,
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        setState(() => _isLoading = true);
                        // Google account se direct register/login flow shuru
                        try {
                          final result = await AuthService().signInWithGoogle();
                          if (!context.mounted) return;

                          if (result != null) {
                            final user = result['user'] as User?;
                            final isNewUser = result['isNewUser'] as bool;

                            if (user != null) {
                              if (isNewUser) {
                                // Agar naya user hai to profile creation pe jao
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateProfileScreen(),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                // Existing user -> Check if profile is actually complete (Safety)
                                final userData = await AuthService()
                                    .getCurrentUserData();
                                if (!context.mounted) return;

                                bool isProfileIncomplete =
                                    userData == null ||
                                    userData['name'] == null ||
                                    userData['name'].toString().trim().isEmpty;

                                if (isProfileIncomplete) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateProfileScreen(),
                                    ),
                                    (route) => false,
                                  );
                                } else {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomePageScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            }
                          }
                        } catch (e) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Google Sign In Failed",
                            isError: true,
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: Container(
                        width: 75.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withAlpha(160),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Image.asset(AppAssets.googleIcon, height: 22),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
