import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/constants/app_assets.dart';

// Admin side per individual task (Quest) ki summary dikhanay wala card
class TaskApprovalCard extends StatelessWidget {
  final String title;
  final String description;
  final String deadline;
  final String? submittedOn;
  final String
  status; // 'Pending', 'In Progress', 'Approved', 'Rejected', 'Completed'

  const TaskApprovalCard({
    super.key,
    required this.title,
    required this.description,
    required this.deadline,
    this.submittedOn,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusTextColor;

    // Task ke status ke mutabiq colors aur text set karna
    switch (status) {
      case 'Approved':
        statusColor = AppColors.primary.withValues(alpha: 0.6);
        statusTextColor = Colors.white;
        break;
      case 'Rejected':
        statusColor = AppColors.errorRed.withValues(alpha: 0.1);
        statusTextColor = AppColors.errorRed;
        break;
      case 'Completed': // User ne task submit kar diya hai
        statusColor = AppColors.primary.withValues(alpha: 0.1);
        statusTextColor = AppColors.primary;
        break;
      case 'In Progress':
        statusColor = Colors.orange.withValues(alpha: 0.1);
        statusTextColor = Colors.orange;
        break;
      default: // Intezar (Pending)
        statusColor = Colors.grey.withValues(alpha: 0.1);
        statusTextColor = AppColors.textDarkGrey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.heading1medium.copyWith(fontSize: 18.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.bodysmall.copyWith(
                    color: statusTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Image.asset(AppAssets.calendarIcon, width: 20.w, height: 20.h),
              SizedBox(width: 5.w),
              Text(
                "Deadline: $deadline",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textDarkGrey,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          if (submittedOn != null) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Image.asset(AppAssets.doneIcon, width: 20.w, height: 20.h),
                SizedBox(width: 5.w),
                Text(
                  "Submitted: $submittedOn",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDarkGrey,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            description,
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
