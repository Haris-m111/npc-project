import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';

// Tamam notifications ki list dikhanay wali screen
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  CustomAppBar(title: "Notifications"),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: 10,
                separatorBuilder: (context, index) => SizedBox(height: 24.h),
                itemBuilder: (context, index) {
                  // Individual notification item ka design
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Row: Icon, Header Info
                      Row(
                        children: [
                          // Notification icon (Check mark circle ke andar)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Bahir wala daira (Big Circle)
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                              ),

                              // Ander wala box (Tick icon ke saath)
                              Container(
                                width: 30.w,
                                height: 30.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 12.w),

                          // Header Text Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Project Update",
                                style: AppTextStyles.heading1medium.copyWith(
                                  fontSize: 16.sp,
                                  // fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "2 days ago | 09:24 AM",
                                style: AppTextStyles.bodysmall.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Second Row: Description Text
                      Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.",
                        style: AppTextStyles.bodysmall.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.black,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
