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
  // Controllers to get text from email and password fields
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
    // This block prevents the user from going back to the previous screen (Splash)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Closes the app if back button is pressed
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
                  // Email Input Field
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
                  // Password Input Field
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
                        // Close keyboard
                        FocusScope.of(context).unfocus();
                        // Go to Forgot Password Screen
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

                            // 1. Basic Validation: Check if fields are empty
                            if (email.isEmpty || password.isEmpty) {
                              SnackbarHelper.showTopSnackBar(
                                context,
                                "Email and password are required",
                                isError: true,
                              );
                              return;
                            }

                            // 2. Email Format Validation
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
                              // Login successful, now check Profile logic
                              final profileVM = Provider.of<ProfileViewModel>(
                                context,
                                listen: false,
                              );

                              // Naya: Login se mili hui ID ProfileVM ko dena
                              if (authVM.userId != null) {
                                profileVM.setUserId(authVM.userId!);
                              }

                              bool profileSuccess = await profileVM
                                  .getProfile();

                              if (!context.mounted) return;

                              // Check if profile exists (404 means new user)
                              bool isNewUser =
                                  !profileSuccess &&
                                  profileVM.errorMessage == "Profile not found";

                              // If API failed for other reasons, show error
                              if (!profileSuccess && !isNewUser) {
                                SnackbarHelper.showTopSnackBar(
                                  context,
                                  profileVM.errorMessage ??
                                      "Failed to fetch profile.",
                                  isError: true,
                                );
                                return;
                              }

                              if (profileSuccess) {
                                SnackbarHelper.showTopSnackBar(
                                  context,
                                  authVM.successMessage ?? "Login Successful!",
                                  isSuccess: true,
                                );
                              }

                              if (!context.mounted) return;

                              // If New User OR Profile Name is missing -> Go to Create Profile
                              if (isNewUser ||
                                  profileVM.userProfile?.name == null ||
                                  profileVM.userProfile!.name!.isEmpty) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => CreateProfileScreen(
                                      isUpdate: false,
                                      email: email, // Pass email to next screen
                                    ),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                // Profile is complete -> Go to Home Screen
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              // Login Failed (Wrong email or password)
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
                            // Navigate to Sign Up Screen
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
                        // Google Sign In Logic
                        final authVM = Provider.of<AuthViewModel>(
                          context,
                          listen: false,
                        );
                        bool success = await authVM.signInWithGoogle();

                        if (!context.mounted) return;

                        if (success) {
                          // Get Profile details
                          final profileVM = Provider.of<ProfileViewModel>(
                            context,
                            listen: false,
                          );

                          // Naya: Login se mili hui ID ProfileVM ko dena
                          if (authVM.userId != null) {
                            profileVM.setUserId(authVM.userId!);
                          }

                          bool profileSuccess = await profileVM.getProfile();

                          if (!context.mounted) return;

                          // 404 handle kr rhy hain naye users ke liye
                          bool isNewUser =
                              !profileSuccess &&
                              profileVM.errorMessage == "Profile not found";

                          if (!profileSuccess && !isNewUser) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              profileVM.errorMessage ??
                                  "Failed to fetch profile.",
                              isError: true,
                            );
                            return;
                          }

                          if (profileSuccess) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.successMessage ??
                                  "Social Login Successful!",
                              isSuccess: true,
                            );
                          }

                          // Profile complete check (Name or Picture missing?)
                          bool needsSetup =
                              isNewUser ||
                              profileVM.userProfile?.name == null ||
                              profileVM.userProfile!.name!.isEmpty ||
                              profileVM.userProfile?.profilePicture == null ||
                              profileVM.userProfile!.profilePicture!.isEmpty;

                          if (needsSetup) {
                            // Social login ke liye automatic profile create/update kryn gay
                            debugPrint(
                              "DEBUG: Automating profile setup for Google user (isNew: $isNewUser)...",
                            );
                            if (isNewUser) {
                              await profileVM.createProfile(
                                authVM.socialName ?? "Google User",
                                authVM.socialPicture,
                              );
                            } else {
                              // Agar profile bani hui hai par picture ya naam missing hai
                              await profileVM.updateProfile(
                                profileVM.userProfile?.name ??
                                    authVM.socialName ??
                                    "Google User",
                                profileVM.userProfile?.profilePicture ??
                                    authVM.socialPicture,
                              );
                            }
                          }

                          if (!context.mounted) return;

                          // Success snackbar for social login
                          SnackbarHelper.showTopSnackBar(
                            context,
                            authVM.successMessage ?? "Social Login Successful!",
                            isSuccess: true,
                          );

                          // Hamesha Home page par bheje ga (Social login ke liye)
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const HomePageScreen(),
                            ),
                            (route) => false,
                          );
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
