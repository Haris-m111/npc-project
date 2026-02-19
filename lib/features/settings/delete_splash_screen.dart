import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/features/onboarding/splash_screen.dart';

// Account delete hone ke baad dikhanay wala kamyabi ka screen
class DeleteSplashScreen extends StatefulWidget {
  const DeleteSplashScreen({super.key});

  @override
  State<DeleteSplashScreen> createState() => _DeleteSplashScreenState();
}

class _DeleteSplashScreenState extends State<DeleteSplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2 seconds ke baad main splash screen per wapis jana (Login ke liye)
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SplashScreen()),
          (route) => false, // Puray routes khatam karna
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              AppAssets.deleteIllustration,
              width: 150.w,
              height: 150.h,
            ),
            SizedBox(height: 10.h),
            Text(
              "Account Deleted!",
              style: AppTextStyles.mainheading.copyWith(
                fontSize: 24.sp,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your account and all associated data have been permanently removed. We hope to see you again soon!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodysmall.copyWith(
                fontSize: 15,
                color: AppColors.offWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
