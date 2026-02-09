import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';

// App mein use honay wala main button widget
class CustomButton extends StatelessWidget {
  final String text; // Button pe likha janay wala text
  final VoidCallback? onPressed; // Click karne pe kya hoga
  final bool isLoading; // Kya loading spinner dikhana hai?

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Agar loading ho rahi ho to button disabled hoga (null)
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withAlpha(200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12.h),
        minimumSize: Size(double.infinity, 50.h), // Button ki poori width
      ),
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              // Loading ke waqt ghomnay wala nishaan (spinner)
              child: CircularProgressIndicator(
                color: AppColors.bgcolor,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
              ),
            ),
    );
  }
}
