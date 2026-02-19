import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/features/auth/password_screen.dart';
import 'package:npc/features/settings/delete_splash_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';

// Email verify karne aur OTP enter karne wali screen
class OtpScreen extends StatefulWidget {
  final bool isfromforgot; // Kya ye forgot password se aaya hai?
  final bool isfromsignup; // Kya ye signup process se aaya hai?
  final bool isfromdelete; // Kya ye account delete karne ke liye aaya hai?
  final String email; // Jis email pe OTP bheja gaya hai
  const OtpScreen({
    super.key,
    this.isfromforgot = false,
    this.isfromsignup = false,
    this.isfromdelete = false,
    this.email = "",
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Har OTP box ke liye focus node aur controller
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  Timer? _timer; // Countdown timer ke liye
  int _start = 60; // 60 seconds se countdown shuru hoga
  bool _isResending =
      false; // "Send Again" click karne pe loading dikhanay ke liye

  // 60 seconds ka countdown shuru karne wala function
  void startTimer() {
    _timer?.cancel(); // Pehle se koi timer chal raha ho to cancel karo
    _start = 60;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel(); // 0 hone pe timer rok do
        });
      } else {
        setState(() {
          _start--; // Har second 1 kam karo
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer(); // Screen load hote hi timer shuru
    // Text select karne ka logic jab box pe focus aaye
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          _controllers[i].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[i].text.length),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // Screen band hone pe timer aur nodes ko saaf karo (Cleanup)
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED HEADER
              if (widget.isfromdelete)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
                  child: const CustomAppBar(title: "Delete Account"),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 25.h,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isfromdelete)
                        Text(
                          'Verify Your Email',
                          style: AppTextStyles.mainheading,
                        ),
                      SizedBox(height: 16.h),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo .',
                        style: AppTextStyles.bodysmall,
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 48.h,
                                height: 48.h,
                                // Keyboard se backspace dabane pe picchle box pe janay ka logic
                                child: KeyboardListener(
                                  focusNode: FocusNode(),
                                  onKeyEvent: (event) {
                                    if (event is KeyDownEvent &&
                                        event.logicalKey ==
                                            LogicalKeyboardKey.backspace) {
                                      if (_controllers[index].text.isEmpty &&
                                          index > 0) {
                                        _focusNodes[index - 1].requestFocus();
                                      }
                                    }
                                  },
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    onTap: () {
                                      _controllers[index].selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset: _controllers[index]
                                                  .text
                                                  .length,
                                            ),
                                          );
                                    },
                                    keyboardType: TextInputType.number,
                                    maxLength: 2, // Allow 2 to detect overwrite
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: AppTextStyles.headingsmall,
                                    decoration: InputDecoration(
                                      hintText: "-",
                                      hintStyle: TextStyle(
                                        color: AppColors.iconGrey,
                                        fontSize: 20.sp,
                                      ),
                                      counterText: "",
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: (48.h - 16.sp) / 2,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.white.withAlpha(100),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        if (value.length > 1) {
                                          // Box mein pehle se text ho to usey naye text se replace karo
                                          String lastChar = value.substring(
                                            value.length - 1,
                                          );
                                          _controllers[index].text = lastChar;
                                          _controllers[index].selection =
                                              TextSelection.fromPosition(
                                                const TextPosition(offset: 1),
                                              );
                                        }

                                        // Ek digit enter hone pe khud hi aglay box pe jao (Auto Advance)
                                        if (index < 5) {
                                          _focusNodes[index + 1].requestFocus();
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              if (index < 5) SizedBox(width: 16.w),
                            ],
                          );
                        }),
                      ),
                      SizedBox(height: 40.h),
                      Center(
                        child: Text(
                          "00:${_start.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Center(
                        child: Consumer<AuthViewModel>(
                          builder: (context, authVM, child) {
                            if (_isResending) {
                              return SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () async {
                                if (_start == 0) {
                                  bool success;
                                  if (widget.isfromforgot) {
                                    // Forgot Password ke liye wahi main forgot API hi resend ka kaam karegi
                                    success = await authVM.forgotPassword(
                                      widget.email,
                                    );
                                  } else if (widget.isfromdelete) {
                                    // Account delete ke liye wahi main delete account API hi resend ka kaam karegi
                                    // Iske liye humne ViewModel me password temporary save kiya tha
                                    success = await authVM.deleteAccount(
                                      widget.email,
                                      authVM.pendingDeletionPassword ?? "",
                                    );
                                  } else {
                                    // Signup flow ke liye purana resend logic
                                    success = await authVM.resendOtp(
                                      widget.email,
                                    );
                                  }

                                  setState(() => _isResending = false);

                                  if (success) {
                                    SnackbarHelper.showTopSnackBar(
                                      context,
                                      authVM.successMessage ??
                                          "OTP has been resent to your email",
                                      isSuccess: true,
                                    );
                                    for (var controller in _controllers) {
                                      controller.clear();
                                    }
                                    _focusNodes[0].requestFocus();
                                    startTimer();
                                  } else {
                                    SnackbarHelper.showTopSnackBar(
                                      context,
                                      authVM.errorMessage ?? "Failed to resend",
                                      isError: true,
                                    );
                                  }
                                }
                              },
                              child: Text(
                                "Send Again",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Nunito',
                                  color: _start == 0
                                      ? AppColors.primary
                                      : AppColors.textLightGrey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // BUTTON (Moves with keyboard)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    return CustomButton(
                      isLoading: authVM.isLoading,
                      text: widget.isfromdelete ? "DELETE ACCOUNT" : "VERIFY",
                      onPressed: () async {
                        // Saare boxes se digits jama kar ke ek OTP string banao
                        String otp = _controllers.map((e) => e.text).join();

                        // Check kya OTP khali hai?
                        if (otp.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please enter OTP",
                            isError: true,
                          );
                          return;
                        }

                        if (widget.isfromdelete) {
                          // API call using ViewModel
                          bool success = await authVM.verifyDeleteAccount(
                            widget.email,
                            otp,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.successMessage ??
                                  "Account Deleted Successfully",
                              isSuccess: true,
                            );

                            if (!context.mounted) return;

                            // Account delete ho gaya, success splash screen par bhejna
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeleteSplashScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.errorMessage ?? "Deletion failed",
                              isError: true,
                            );
                          }
                        } else if (widget.isfromsignup) {
                          // API call using ViewModel
                          bool success = await authVM.verifyOtp(
                            widget.email,
                            otp,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.successMessage ?? "OTP Successful",
                              isSuccess: true,
                            );

                            // Required delay for smooth experience
                            await Future.delayed(const Duration(seconds: 1));
                            if (!context.mounted) return;

                            // Signup flow: Password create karne wali screen pe jao
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordScreen(
                                  title: "Create Password",
                                  description:
                                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo.",
                                  firstFieldLabel: "Enter Password",
                                  secondFieldLabel: "Confirm Password",
                                  buttonText: "CREATE ACCOUNT",
                                  email: widget.email,
                                  onButtonPressed: (ctx) {},
                                ),
                              ),
                            );
                          } else {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.errorMessage ?? "Invalid OTP",
                              isError: true,
                            );
                          }
                        } else if (widget.isfromforgot) {
                          // API call for Forgot Password OTP Verification
                          bool success = await authVM.verifyOtpForgotPassword(
                            widget.email,
                            otp,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.successMessage ?? "OTP Successful",
                              isSuccess: true,
                            );
                            await Future.delayed(const Duration(seconds: 1));
                            if (!context.mounted) return;

                            // Forgot password flow: Naya password set karne wali screen pe jao
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordScreen(
                                  title: "Update Password",
                                  description:
                                      "Enter your new password below to reset your account access.",
                                  firstFieldLabel: "New Password",
                                  secondFieldLabel: "Confirm New Password",
                                  buttonText: "UPDATE PASSWORD",
                                  email: widget.email,
                                  onButtonPressed: (ctx) {},
                                ),
                              ),
                            );
                          } else {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              authVM.errorMessage ?? "Invalid OTP",
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
