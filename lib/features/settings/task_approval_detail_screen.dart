import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/data/models/quest_model.dart';
import 'package:npc/view_models/quest_view_model.dart';
import 'package:npc/core/widgets/image_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

// Admin ke liye task (Quest) ki details dekhnay aur usay Approve/Reject karne wala screen
class TaskApprovalDetailScreen extends StatefulWidget {
  final QuestModel quest;
  const TaskApprovalDetailScreen({super.key, required this.quest});

  @override
  State<TaskApprovalDetailScreen> createState() =>
      _TaskApprovalDetailScreenState();
}

class _TaskApprovalDetailScreenState extends State<TaskApprovalDetailScreen> {
  String?
  _selectedStatus; // Admin jo status select karega (Approved ya Rejected)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 35.h),
              child: const CustomAppBar(title: "Approve Quest", showBack: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quest Details",
                          style: AppTextStyles.mainheading.copyWith(
                            fontSize: 18.sp,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: AppColors.primary),
                          ),
                          // Status select karne wala dropdown (Approved/Rejected)
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isDense: true,
                              hint: Text(
                                "Select Status",
                                style: AppTextStyles.bodysmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.primary,
                                size: 24.sp,
                              ),
                              style: AppTextStyles.bodysmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              dropdownColor: AppColors.bgcolor,
                              items: ['Approved', 'Rejected'].map((
                                String status,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedStatus = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      widget.quest.description ?? "No description",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.textDarkGrey,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16.h),
                    // Task ki deadline date dikhana
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.calendarIcon,
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Deadline: ${widget.quest.dueDate != null ? _formatDate(widget.quest.dueDate!) : 'No Deadline'}",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textDarkGrey,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Task Images (Visible for Admin to Approve)
                    if (widget.quest.images != null &&
                        widget.quest.images!.isNotEmpty) ...[
                      Text(
                        "Task Images",
                        style: AppTextStyles.mainheading.copyWith(
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // User ki taraf se submit ki gayi images ki gallery
                      SizedBox(
                        height: 170.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.quest.images!.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 16.w),
                          itemBuilder: (context, index) {
                            final String imgData = widget.quest.images![index];
                            final bool isUrl = imgData.startsWith('http');

                            return GestureDetector(
                              onTap: () {
                                // Tasveer ko full screen per dekhne ke liye navigation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerScreen(
                                      base64Image: !isUrl ? imgData : null,
                                      imageUrl: isUrl ? imgData : null,
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
                                  child: isUrl
                                      ? Image.network(
                                          imgData,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                  child:
                                                      CustomLoadingIndicator(),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                  ),
                                        )
                                      : Image.memory(
                                          base64Decode(imgData),
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
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

            // Approve/Reject Button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: Consumer<QuestViewModel>(
                builder: (context, questVM, child) {
                  return questVM.isLoading
                      ? const CustomLoadingIndicator()
                      : CustomButton(
                          text: _selectedStatus == null
                              ? "SELECT STATUS"
                              : _selectedStatus == 'Approved'
                              ? "APPROVE QUEST"
                              : "REJECT QUEST",
                          onPressed: _selectedStatus == null
                              ? null // Disable button if no status selected
                              : () async {
                                  // Action name set karna (API expects 'approve' or 'reject')
                                  final action = _selectedStatus == 'Approved'
                                      ? 'approve'
                                      : 'reject';

                                  final success = await questVM.updateStatus(
                                    widget.quest.id!,
                                    action,
                                  );

                                  if (!context.mounted) return;

                                  if (success) {
                                    Navigator.pop(
                                      context,
                                    ); // List screen per wapis jana
                                    SnackbarHelper.showTopSnackBar(
                                      context,
                                      _selectedStatus == 'Approved'
                                          ? "Quest approved successfully"
                                          : "Quest rejected",
                                      isSuccess: _selectedStatus == 'Approved',
                                      isError: _selectedStatus == 'Rejected',
                                    );
                                  } else {
                                    SnackbarHelper.showTopSnackBar(
                                      context,
                                      questVM.errorMessage ??
                                          "Failed to update status",
                                      isError: true,
                                    );
                                  }
                                },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Date ko "Jan 01, 2024" format mein dikhanay wala helper function
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
