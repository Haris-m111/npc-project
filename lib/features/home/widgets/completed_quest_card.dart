import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/data/models/quest_model.dart';
import 'package:npc/core/utils/snackbar_helper.dart';

// Khatam shuda (Completed/Submitted) tasks ko list mein dikhanay wala card
class CompletedQuestCard extends StatelessWidget {
  final QuestModel quest;

  const CompletedQuestCard({super.key, required this.quest});

  // Date ko asan format mein badalnay ke liye function (e.g. Jan 10, 2024)
  String _formatDate(DateTime? date) {
    if (date == null) return "No Date";
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
    final status = quest.status ?? "Completed";
    String displayStatus = status;
    Color statusColor;
    Color statusTextColor;

    // Task ke status ke mutabiq colors aur text set karna (API statuses)
    if (status == 'submitted' || status == 'completed' || status == 'pending') {
      displayStatus = status[0].toUpperCase() + status.substring(1);
      statusColor = AppColors.primary.withValues(alpha: 0.1);
      statusTextColor = AppColors.primary;
    } else if (status == 'approved') {
      displayStatus = 'Approved';
      statusColor = AppColors.primary.withValues(alpha: 0.6);
      statusTextColor = Colors.white;
    } else if (status == 'rejected') {
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
        SnackbarHelper.showTopSnackBar(context, "Quest Details coming soon!");
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
                Expanded(
                  child: Text(
                    quest.title ?? "No Title",
                    style: AppTextStyles.heading1medium.copyWith(
                      fontSize: 18.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  "Deadline: ${_formatDate(quest.dueDate)}",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDarkGrey,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),

            // Jis tareekh ko task bana (Created On)
            Row(
              children: [
                Image.asset(AppAssets.doneIcon, width: 18.w, height: 18.h),
                SizedBox(width: 8.w),
                Text(
                  "Created On: ${_formatDate(quest.createdAt)}",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDarkGrey,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Task ki description
            Text(
              (quest.description != null && quest.description!.isNotEmpty)
                  ? (quest.description!.length > 50
                        ? "${quest.description!.substring(0, 50)}..."
                        : quest.description!)
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
