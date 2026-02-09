import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/constants/app_assets.dart';

// List mein individual quest (Task) ki mukhtasir maloomat dikhanay wala card
class QuestCard extends StatelessWidget {
  final String title; // Quest ka unwan (Title)
  final String? description; // Quest ki tafseel (Optional)
  final String? deadline; // Khatam karne ki tareekh (Optional)

  const QuestCard({
    super.key,
    required this.title,
    this.description,
    this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h, left: 4.w, right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest ka title (Sirf ek line mein dikhaya jayega)
          Text(
            "$title ",
            style: AppTextStyles.heading1medium.copyWith(fontSize: 18.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          // Quest ki aakhri tareekh (Deadline)
          Row(
            children: [
              Image.asset(AppAssets.calendarIcon, width: 20.w, height: 20.h),
              SizedBox(width: 5.w),
              Text(
                deadline ?? "Deadline: Mar 5, 2025",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textDarkGrey,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Quest ki tafseel (Sirf do lines dikhayi jayengi)
          Text(
            description ??
                "Lorem ipsum dolor sit amet, consectetur \nadipiscing elit...",
            style: AppTextStyles.body.copyWith(
              fontSize: 16.sp,
              color: AppColors.textDarkGrey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
