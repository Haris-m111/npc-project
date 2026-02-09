import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';

// Poori app mein use honay wala standard loading spinner
class CustomLoadingIndicator extends StatelessWidget {
  final double? size; // Spinner ka size
  final double strokeWidth; // Spinner ki line ki motai
  final Color? color; // Spinner ka rang

  const CustomLoadingIndicator({
    super.key,
    this.size,
    this.strokeWidth = 3,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        // Agar size na diya ho to default 30 use karein
        width: size ?? 30.w,
        height: size ?? 30.h,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: color ?? AppColors.primary, // Default primary rang
        ),
      ),
    );
  }
}
