import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/features/auth/forgot_password_screen.dart';
import 'package:npc/features/auth/signup_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/core/utils/validators.dart';
import 'package:npc/features/settings/create_profile_screen.dart';
import 'package:npc/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';

// App mein login karne ke liye main screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgcolor,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100.h),
                  Text('Log In', style: AppTextStyles.mainheading),
                  SizedBox(height: 12.h),
                  Text(
                    'Welcome back! Enter your details to continue.',
                    style: AppTextStyles.bodysmall.copyWith(fontSize: 16.sp),
                  ),
                  SizedBox(height: 30.h),
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
                    child: Consumer<AuthViewModel>(
                      builder: (context, authVM, child) {
                        return CustomButton(
                          isLoading: authVM.isLoading,
                          text: "LOGIN",
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            String email = _emailController.text.trim();
                            String password = _passwordController.text;

                            if (email.isEmpty || password.isEmpty) {
                              SnackbarHelper.showTopSnackBar(
                                context,
                                "Email and password are required",
                                isError: true,
                              );
                              return;
                            }

                            final emailValidation = Validators.validateEmail(
                              email,
                            );
                            if (emailValidation != null) {
                              SnackbarHelper.showTopSnackBar(
                                context,
                                "Please enter a valid email",
                                isError: true,
                              );
                              return;
                            }

                            // API Login call
                            bool success = await authVM.signIn(email, password);

                            if (!context.mounted) return;

                            if (success) {
                              // Profile check karne ke liye ProfileViewModel use kar rhe hain
                              final profileVM = Provider.of<ProfileViewModel>(
                                context,
                                listen: false,
                              );
                              bool profileSuccess = await profileVM
                                  .getProfile();

                              if (!context.mounted) return;

                              if (!profileSuccess) {
                                SnackbarHelper.showTopSnackBar(
                                  context,
                                  profileVM.errorMessage ??
                                      "Failed to fetch profile.",
                                  isError: true,
                                );
                                return;
                              }

                              SnackbarHelper.showTopSnackBar(
                                context,
                                authVM.successMessage ?? "Login Successful!",
                                isSuccess: true,
                              );

                              // Delay for snackbar
                              await Future.delayed(const Duration(seconds: 1));
                              if (!context.mounted) return;

                              // Agar profile ka 'name' khali hai, to Create Profile pr bhejo
                              if (profileVM.userProfile?.name == null ||
                                  profileVM.userProfile!.name!.isEmpty) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateProfileScreen(
                                          isUpdate: false,
                                        ),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                // Agar profile complete hai, to seedha Home page pr
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              SnackbarHelper.showTopSnackBar(
                                context,
                                authVM.errorMessage ??
                                    "Invalid or unverified user.",
                                isError: true,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 25.h),
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
                        final authVM = Provider.of<AuthViewModel>(
                          context,
                          listen: false,
                        );
                        bool success = await authVM.signInWithGoogle();

                        if (!context.mounted) return;

                        if (success) {
                          // Profile check kar rhe hain
                          final profileVM = Provider.of<ProfileViewModel>(
                            context,
                            listen: false,
                          );
                          bool profileSuccess = await profileVM.getProfile();

                          if (!context.mounted) return;

                          if (!profileSuccess) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              profileVM.errorMessage ??
                                  "Failed to fetch profile.",
                              isError: true,
                            );
                            return;
                          }

                          SnackbarHelper.showTopSnackBar(
                            context,
                            authVM.successMessage ?? "Social Login Successful!",
                            isSuccess: true,
                          );

                          // Profile complete check
                          if (profileVM.userProfile?.name == null ||
                              profileVM.userProfile!.name!.isEmpty) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateProfileScreen(isUpdate: false),
                              ),
                              (route) => false,
                            );
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomePageScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } else if (authVM.errorMessage != null) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            authVM.errorMessage!,
                            isError: true,
                          );
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
