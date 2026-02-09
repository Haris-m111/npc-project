import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/constants/app_colors.dart';

// Home screen ka oopar wala hissa (Header) jahan Welcome message aur icons hain
class HomeHeader extends StatelessWidget {
  final String name; // User ka naam dikhanay ke liye
  final VoidCallback onNotificationTap; // Notification icon pe click ka action
  final VoidCallback onSettingTap; // Settings icon pe click ka action

  const HomeHeader({
    super.key,
    required this.name,
    required this.onNotificationTap,
    required this.onSettingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 30.h,
        bottom: 18.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message aur user ka naam
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome",
                style: AppTextStyles.headinglarge.copyWith(
                  fontSize: 24.sp,
                  color: AppColors.black,
                ),
              ),
              Text(
                name,
                style: AppTextStyles.headinglarge.copyWith(
                  fontSize: 24.sp,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          // Notification aur Settings ke icons
          Row(
            children: [
              GestureDetector(
                onTap: onNotificationTap,
                child: Image.asset(
                  AppAssets.notificationIcon,
                  width: 24.w,
                  height: 24.h,
                ),
              ),
              SizedBox(width: 14.w),
              GestureDetector(
                onTap: onSettingTap,
                child: Image.asset(
                  AppAssets.settingIcon,
                  width: 24.w,
                  height: 24.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
