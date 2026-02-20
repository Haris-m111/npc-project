import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/features/home/upload_picture_screen.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/data/models/quest_model.dart';
import 'package:npc/view_models/quest_view_model.dart';
import 'package:npc/core/utils/snackbar_helper.dart';

// Kisi bhi quest (Task) ki mukammal tafseel dikhanay wali screen
class QuestDetailScreen extends StatefulWidget {
  final QuestModel quest; // Quest ka data

  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  bool _isNavigating = false;
  @override
  Widget build(BuildContext context) {
    final String description =
        widget.quest.description ?? "No description provided.";
    final String deadlineText = _formatDate(widget.quest.dueDate);

    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Consumer<QuestViewModel>(
          builder: (context, questVM, child) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 35.h),
                  child: const CustomAppBar(
                    title: "Quest Detail",
                    showBack: true,
                  ),
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
                      ],
                    ),
                  ),
                ),

                // BUTTON
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                  child: CustomButton(
                    isLoading: questVM.isLoading || _isNavigating,
                    text: widget.quest.status == 'pending'
                        ? "START QUEST"
                        : "COMPLETE QUEST",
                    onPressed: () async {
                      if (widget.quest.status == 'pending') {
                        // Quest shuru karne ka logic
                        final success = await questVM.updateStatus(
                          widget.quest.id!,
                          'start',
                        );
                        if (success && context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HomePageScreen(initialTabIndex: 1),
                            ),
                            (route) => false,
                          );
                        } else if (context.mounted) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            questVM.errorMessage ?? "Failed to start quest",
                            isError: true,
                          );
                        }
                      } else {
                        // Quest mukammal karne ke liye hamesha upload screen pe bhejo
                        setState(() => _isNavigating = true);

                        // User feedback ke liye thora delay taake loader dikhayi day
                        await Future.delayed(const Duration(milliseconds: 600));

                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UploadPictureScreen(quest: widget.quest),
                          ),
                        ).then((_) {
                          if (mounted) setState(() => _isNavigating = false);
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "No Deadline";
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
