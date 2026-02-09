import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/features/tasks/data/task_model.dart';
import 'package:npc/core/widgets/image_viewer_screen.dart';
import 'dart:convert';

class CompletedQuestDetailScreen extends StatelessWidget {
  final TaskModel task; // Task ka saara data is model mein hota hai

  const CompletedQuestDetailScreen({super.key, required this.task});

  // Date ko readable format (Jan 01, 2024) mein tabdeel karne ke liye helper function
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
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            // Screen ka header aur back button ( app bar )
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 35.h),
              child: const CustomAppBar(title: "Quest Detail", showBack: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 32.h),
                          // Task ki description dikhanay ka section
                          Text(
                            task.description.isNotEmpty
                                ? task.description
                                : "No description provided.",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textDarkGrey,
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 24.h),

                          // Task khatam karne ki aakhri tareekh (Deadline)
                          Row(
                            children: [
                              Image.asset(
                                AppAssets.calendarIcon,
                                width: 20.w,
                                height: 20.h,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Deadline: ${_formatDate(task.deadline)}",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textDarkGrey,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Kab task submit kiya gaya, wo tareekh dikhata hai
                          Row(
                            children: [
                              Image.asset(
                                AppAssets.doneIcon,
                                width: 20.w,
                                height: 20.h,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Submitted On: ${_formatDate(task.createdAt)}",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textDarkGrey,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),

                          // User ne jo images upload ki hain, unka gallery view
                          if (task.images.isNotEmpty) ...[
                            Text(
                              "Task Images",
                              style: AppTextStyles.mainheading.copyWith(
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 170.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: task.images.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 16.w),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Image par click karne se image full screen par dikhayi degi
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ImageViewerScreen(
                                                base64Image: task.images[index],
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 119.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                        border: Border.all(
                                          color: AppColors.iconGrey.withAlpha(
                                            50,
                                          ),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                        child: Image.memory(
                                          base64Decode(task.images[index]),
                                          width: 119.w,
                                          height: 170.h,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                    SizedBox(height: 35.h), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
