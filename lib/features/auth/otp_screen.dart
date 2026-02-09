import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/features/auth/login_screen.dart';
import 'package:npc/features/auth/password_screen.dart';
import 'package:npc/features/settings/delete_splash_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart';

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
  bool _isLoading = false; // Verify button pe loading dikhanay ke liye

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
                        child: _isResending
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            // OTP dobara bhaijne (Resend) ka logic
                            : GestureDetector(
                                onTap: () async {
                                  if (_start == 0) {
                                    setState(() => _isResending = true);
                                    try {
                                      bool success = await AuthService()
                                          .sendOtp(widget.email);
                                      if (!context.mounted) return;
                                      setState(() => _isResending = false);

                                      if (success) {
                                        SnackbarHelper.showTopSnackBar(
                                          context,
                                          "OTP has been resent to your email",
                                          isSuccess: true,
                                        );
                                        // Saare boxes khali kar do
                                        for (var controller in _controllers) {
                                          controller.clear();
                                        }
                                        // Pehle box pe focus le jao
                                        _focusNodes[0].requestFocus();
                                        startTimer(); // Timer phirse shuru
                                      } else {
                                        SnackbarHelper.showTopSnackBar(
                                          context,
                                          "Failed to resend OTP. Try again.",
                                          isError: true,
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() => _isResending = false);
                                      }
                                      SnackbarHelper.showTopSnackBar(
                                        context,
                                        "Error sending OTP",
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
                child: CustomButton(
                  isLoading: _isLoading,
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

                    setState(() {
                      _isLoading = true;
                    });

                    // Internet check karna
                    bool hasNet = await AuthService.hasInternet();
                    if (!hasNet) {
                      setState(() => _isLoading = false);
                      if (context.mounted) {
                        SnackbarHelper.showTopSnackBar(
                          context,
                          "No internet connection. Please check your network and try again",
                          isError: true,
                        );
                      }
                      return;
                    }

                    if (widget.isfromdelete) {
                      // Account delete verification (agar alag se karni ho)
                    } else {
                      // OTP sahi hai ya nahi check karo
                      bool verified = AuthService().verifyOTP(otp);
                      if (!verified) {
                        setState(() {
                          _isLoading = false;
                        });
                        if (context.mounted) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Invalid OTP",
                            isError: true,
                          );
                        }
                        return;
                      }
                    }

                    // 3. Required 2-second delay for smooth experience
                    await Future.delayed(const Duration(seconds: 2));

                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    if (!context.mounted) return;

                    if (widget.isfromforgot) {
                      // Forgot password flow: Password update screen pe jao
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PasswordScreen(
                            title: "Update Password",
                            description:
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo.",
                            firstFieldLabel: "Create Password",
                            secondFieldLabel: "Confirm Password",
                            buttonText: "UPDATE PASSWORD",
                            email: widget.email,
                            onButtonPressed: (ctx) {
                              if (ctx.mounted) {
                                Navigator.of(ctx).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ),
                      );
                    } else if (widget.isfromsignup) {
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
                    } else if (widget.isfromdelete) {
                      // Delete flow: Account permanently khatam karo
                      try {
                        await AuthService().deleteAccount();

                        if (!context.mounted) return;

                        // Splash screen pe jao jo deletion confirm kare
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const DeleteSplashScreen(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Failed to delete account: ${e.toString().replaceAll('Exception: ', '')}",
                            isError: true,
                          );
                        }
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
