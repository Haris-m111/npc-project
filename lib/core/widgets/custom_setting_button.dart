import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/constants/app_colors.dart';

// Settings screen ki ek row (tile) banane ke liye widget
class SettingsTile extends StatelessWidget {
  final IconData? icon; // Tile ka icon (agar image na ho)
  final String? imagePath; // Tile ki custom image ka path
  final double? iconWidth;
  final double? iconHeight;
  final String title; // Tile ka naam
  final VoidCallback onTap; // Click karne pe kya hoga
  final Color? iconColor;
  final Color? textColor;
  final bool isNotification; // Kya ye notification switch wali tile hai?
  final bool switchValue; // Switch ki value (On/Off)
  final Function(bool)? onSwitchChanged; // Switch toggle karne pe function

  const SettingsTile({
    super.key,
    this.icon,
    this.imagePath,
    this.iconWidth,
    this.iconHeight,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.isNotification = false, // Baaki tiles ke liye default false
    this.switchValue = false,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h),
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        // Tile ka background aur rounded corners
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Agar path hai to image dikhao, warna default icon
            imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: iconWidth ?? 20.w,
                    height: iconHeight ?? 20.h,
                  )
                : Icon(
                    icon ?? Icons.error,
                    color: iconColor ?? AppColors.textDarkGrey,
                    size: 20.sp,
                  ),

            SizedBox(width: 8.w),

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodysmall.copyWith(
                  fontSize: 18.sp,
                  color: textColor ?? AppColors.textDarkGrey,
                ),
              ),
            ),
            // Agar isNotification true hai to switch dikhao, warna arrow icon
            isNotification
                ? customSwitch()
                : Icon(Icons.chevron_right, color: AppColors.textDarkGrey),
          ],
        ),
      ),
    );
  }

  // Custom design wala On/Off switch
  Widget customSwitch() {
    return GestureDetector(
      onTap: () {
        if (onSwitchChanged != null) {
          onSwitchChanged!(!switchValue); // On/Off toggle karta hai
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 70.w, // Width pic ke mutabiq
        height: 27.h,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.switchBg, // Background color from your pic
        ),
        child: Row(
          // On hai toh circle right par, Off hai toh left par
          mainAxisAlignment: switchValue
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (switchValue)
              Text(
                "On ",
                style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
              ),

            // Brown Circle
            Container(
              width: 16.w,
              height: 16.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary, // Dark brown from your pic
              ),
            ),

            if (!switchValue)
              Text(
                " Off",
                style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
              ),
          ],
        ),
      ),
    );
  }
}
