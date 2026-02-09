import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/features/home/upload_picture_screen.dart';
import 'package:npc/core/widgets/image_viewer_screen.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/features/tasks/data/task_model.dart';
import 'package:npc/features/tasks/services/task_service.dart';

// Kisi bhi quest (Task) ki mukammal tafseel dikhanay wali screen
class QuestDetailScreen extends StatefulWidget {
  final String title; // Quest ka unwan
  final bool isStarted; // Kya quest shuru ho chuki hai?
  final TaskModel? task; // Quest ka sara data

  const QuestDetailScreen({
    super.key,
    required this.title,
    this.isStarted = false,
    this.task,
  });

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // If task is provided, use its data, otherwise use dummy/title
    final String description =
        widget.task?.description ??
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.";
    final String deadlineText = widget.task != null
        ? _formatDate(widget.task!.deadline)
        : "Mar 5, 2025";

    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 35.h),
              child: const CustomAppBar(title: "Quest Detail", showBack: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
                    Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.textDarkGrey,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Image.asset(
                          AppAssets.calendarIcon,
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Deadline: $deadlineText",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textDarkGrey,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Task Images - Hidden as per request
                    // Agar task ki images pehle se upload hain to gallery dikhao
                    if (widget.task != null &&
                        widget.task!.images.isNotEmpty) ...[
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
                          itemCount: widget.task!.images.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 16.w),

                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Image ko full screen per dekhnay ke liye
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerScreen(
                                      base64Image: widget.task!.images[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 119.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(
                                    color: AppColors.iconGrey.withAlpha(50),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: Image.memory(
                                    base64Decode(widget.task!.images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ],
                ),
              ),
            ),

            // BUTTON (Outside Scroll, moves with keyboard)
            // Quest shuru (Start) ya khatam (Complete) karne wala button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: CustomButton(
                isLoading: _isLoading,
                text: widget.task?.status == 'Pending'
                    ? "START QUEST"
                    : "COMPLETE QUEST",
                onPressed: () {
                  setState(() => _isLoading = true);

                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (!context.mounted) return;

                    if (widget.task?.status == 'Pending') {
                      // Case 1: Quest shuru karne ka process
                      TaskService()
                          .updateTaskStatus(widget.task!.id, 'InProgress')
                          .then((_) {
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HomePageScreen(initialTabIndex: 1),
                                ),
                                (route) => false,
                              );
                            }
                          })
                          .catchError((e) {
                            // Error handle karna agar status update na ho
                          })
                          .whenComplete(() {
                            if (context.mounted)
                              setState(() => _isLoading = false);
                          });
                    } else {
                      // Case 2: Quest mukammal karne ka process
                      if (widget.task != null &&
                          widget.task!.images.isNotEmpty) {
                        // Agar images pehle se hain to status update karo
                        TaskService()
                            .updateTaskStatus(widget.task!.id, 'Completed')
                            .then((_) {
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const HomePageScreen(
                                      initialTabIndex: 1,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              }
                            });
                      } else {
                        // Agar images nahi hain to pehle upload screen pe bhejo
                        setState(() => _isLoading = false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UploadPictureScreen(task: widget.task!),
                          ),
                        );
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
