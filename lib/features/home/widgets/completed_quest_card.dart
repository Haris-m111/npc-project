import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/features/home/completed_quest_detail_screen.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/features/tasks/data/task_model.dart';

// Khatam shuda (Completed/Submitted) tasks ko list mein dikhanay wala card
class CompletedQuestCard extends StatelessWidget {
  final TaskModel task;

  const CompletedQuestCard({super.key, required this.task});

  // Date ko asan format mein badalnay ke liye function (e.g. Jan 10, 2024)
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final status = task.status;
    String displayStatus = status;
    Color statusColor;
    Color statusTextColor;

    // Task ke status ke mutabiq colors aur text set karna
    if (status == 'Submitted' || status == 'Completed') {
      displayStatus = 'Completed';
      statusColor = AppColors.primary.withValues(alpha: 0.1);
      statusTextColor = AppColors.primary;
    } else if (status == 'Approved') {
      displayStatus = 'Approved';
      statusColor = AppColors.primary.withValues(alpha: 0.6);
      statusTextColor = Colors.white;
    } else if (status == 'Rejected') {
      displayStatus = 'Rejected';
      statusColor = AppColors.errorRed.withValues(alpha: 0.1);
      statusTextColor = AppColors.errorRed;
    } else {
      statusColor = Colors.grey.withValues(alpha: 0.5);
      statusTextColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        // Card pe click karne se task ki detail screen khulegi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletedQuestDetailScreen(task: task),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.heading1medium.copyWith(fontSize: 18.sp),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    displayStatus,
                    style: AppTextStyles.bodysmall.copyWith(
                      color: statusTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Quest khatam karne ki aakhri tareekh (Deadline)
            Row(
              children: [
                Image.asset(AppAssets.calendarIcon, width: 18.w, height: 18.h),
                SizedBox(width: 8.w),
                Text(
                  "Deadline: ${_formatDate(task.deadline)}",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDarkGrey,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),

            // Jis tareekh ko task jama (Submit) kiya gaya
            Row(
              children: [
                Image.asset(AppAssets.doneIcon, width: 18.w, height: 18.h),
                SizedBox(width: 8.w),
                Text(
                  "Submitted On: ${_formatDate(task.createdAt)}",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDarkGrey,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Task ki description (Sirf pehli 50 characters dikhayi jayengi)
            Text(
              task.description.isNotEmpty
                  ? (task.description.length > 50
                        ? "${task.description.substring(0, 50)}..."
                        : task.description)
                  : "No description provided.",
              style: AppTextStyles.body.copyWith(
                fontSize: 16.sp,
                color: AppColors.textDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
