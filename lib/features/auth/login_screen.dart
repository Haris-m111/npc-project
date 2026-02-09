import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/features/auth/forgot_password_screen.dart';
import 'package:npc/features/auth/signup_screen.dart';
import 'package:npc/features/settings/create_profile_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/core/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

// App mein login karne ke liye main screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(); // Email input ke liye
  final TextEditingController _passwordController =
      TextEditingController(); // Password input ke liye
  bool _isLoading = false; // Button pe loading dikhanay ke liye

  @override
  void dispose() {
    // Screen band honay pe controllers ko memory se saaf karne ke liye
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          false, // Login screen se back button daba kar app band na ho jaye (Force logout zaroori hai)
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop(); // App se bahar nikalnay ke liye
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
                  SizedBox(height: 100.h),
                  Text('Log In', style: AppTextStyles.mainheading),
                  SizedBox(height: 12.h),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo .',
                    style: AppTextStyles.bodysmall.copyWith(fontSize: 16.sp),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Email',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.black,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextfields.email(controller: _emailController),
                  SizedBox(height: 13.h),
                  Text(
                    'Password',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.black,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  CustomTextfields(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    isPassword: true,
                    prefixIconPath: AppAssets.lockIcon,
                  ),

                  SizedBox(height: 10.h),
                  // Password bhool janay ki soorat mein link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.iconGrey,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Nunito',
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 45.h),
                  Center(
                    child: CustomButton(
                      isLoading: _isLoading,
                      text: "LOGIN",
                      onPressed: () async {
                        // Login logic shuru
                        FocusScope.of(context).unfocus(); // Keyboard band karo
                        String email = _emailController.text.trim();
                        String password = _passwordController.text;

                        // Check kya fields khali hain?
                        if (email.isEmpty || password.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Email and password are required",
                            isError: true,
                          );
                          return;
                        }

                        // Email ka format check karna (e.g. @ sign)
                        final emailValidation = Validators.validateEmail(email);

                        if (emailValidation != null) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please enter a valid email",
                            isError: true,
                          );
                          return;
                        }

                        // Final Step: Proceed to Firebase Login
                        setState(() => _isLoading = true);

                        try {
                          // Firebase se login attempt
                          await AuthService().login(email, password);

                          if (!context.mounted) return;

                          // User ka data check karna (Kya profile bani hui hai?)
                          final userData = await AuthService()
                              .getCurrentUserData();

                          if (!context.mounted) return;

                          bool isProfileIncomplete =
                              userData == null ||
                              userData['name'] == null ||
                              userData['name'].toString().trim().isEmpty;

                          if (isProfileIncomplete) {
                            // Agar profile nahi bani to profile creation screen pe bhijwao
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateProfileScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            // Agar profile hai to direct Home page pe
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomePageScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          // Authentication errors handling
                          String message = "Authentication failed";

                          if (e.code == 'wrong-password') {
                            message = "Incorrect password";
                          } else if (e.code == 'user-not-found' ||
                              e.code == 'invalid-email') {
                            message = "Invalid email or password";
                          } else if (e.code == 'network-request-failed') {
                            message =
                                "No internet connection. Please check your network and try again";
                          } else if (e.code == 'invalid-credential') {
                            // Agar error clear na ho to database mein check karo
                            try {
                              bool emailExists = await AuthService()
                                  .isEmailRegistered(email.trim());
                              if (emailExists) {
                                message = "Incorrect password";
                              } else {
                                message = "Invalid email or password";
                              }
                            } catch (_) {
                              message = "Invalid email or password";
                            }
                          } else {
                            message = e.message ?? "Authentication failed";
                          }

                          if (context.mounted) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              message,
                              isError: true,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Login Failed. Please try again.",
                              isError: true,
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account ',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textHintGrey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Signup()),
                            );
                          },
                          child: Text(
                            'Register',
                            style: AppTextStyles.bodysmall.copyWith(
                              fontSize: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),
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
                          style: AppTextStyles.body.copyWith(
                            fontSize: 20.sp,
                            color: AppColors.black,
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
                  SizedBox(height: 22.h),
                  Center(
                    child: Text(
                      'Continue with',
                      style: AppTextStyles.headingsmall.copyWith(
                        color: AppColors.textMutedGrey,
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // GOOGLE
                      GestureDetector(
                        onTap: () async {
                          setState(() => _isLoading = true);
                          // Google ke zariye login ka process
                          try {
                            final result = await AuthService()
                                .signInWithGoogle();
                            if (!context.mounted) return;

                            if (result != null) {
                              final user = result['user'] as User?;
                              final isNewUser = result['isNewUser'] as bool;

                              if (user != null) {
                                if (isNewUser) {
                                  // Naye user ko profile banana lazmi hai
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
                                      userData['name']
                                          .toString()
                                          .trim()
                                          .isEmpty;

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
                          width: 80.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withAlpha(160),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAssets.googleIcon,
                              height: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
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
