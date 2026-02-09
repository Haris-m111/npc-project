import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/features/tasks/data/task_model.dart';
import 'package:npc/features/tasks/services/task_service.dart';
import 'package:npc/core/widgets/image_viewer_screen.dart';
import 'dart:convert';
import 'dart:typed_data';

// Admin ke liye task ki details dekhnay aur usay Approve/Reject karne wala screen
class TaskApprovalDetailScreen extends StatefulWidget {
  final TaskModel task;
  const TaskApprovalDetailScreen({super.key, required this.task});

  @override
  State<TaskApprovalDetailScreen> createState() =>
      _TaskApprovalDetailScreenState();
}

class _TaskApprovalDetailScreenState extends State<TaskApprovalDetailScreen> {
  bool _isLoading = false; // Screen per loading dikhanay ke liye
  String?
  _selectedStatus; // Admin jo status select karega (Approved ya Rejected)
  List<Uint8List>? _decodedImages; // Base64 se convert ki gayi images ki list

  @override
  Widget build(BuildContext context) {
    // Base64 images ko decode karke display ke liye taiyar karna
    if (_decodedImages == null) {
      _decodedImages = [];
      for (String img in widget.task.images) {
        try {
          _decodedImages!.add(base64Decode(img));
        } catch (e) {
          debugPrint("Error decoding image: $e");
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 35.h),
              child: const CustomAppBar(title: "Approve Task", showBack: true),
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
                          "Task Details",
                          style: AppTextStyles.mainheading.copyWith(
                            fontSize: 18.sp,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            // vertical: 0.h, // Reduced vertical padding for dropdown
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
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
                      widget.task.description,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.textDarkGrey,
                      ),
                      textAlign: TextAlign.justify,
                    ),
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
                          "Deadline: ${_formatDate(widget.task.deadline)}",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textDarkGrey,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Task Images (Visible for Admin to Approve)
                    if (widget.task.images.isNotEmpty) ...[
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
                          itemCount: _decodedImages!.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 16.w),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Tasveer ko fulll screen per dekhne ke liye navigation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerScreen(
                                      base64Image: widget.task.images[index],
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
                                    _decodedImages![index],
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
              child: _isLoading
                  ? const CustomLoadingIndicator()
                  : CustomButton(
                      text: _selectedStatus == null
                          ? "SELECT STATUS"
                          : _selectedStatus == 'Approved'
                          ? "APPROVE QUEST"
                          : "REJECT QUEST",
                      onPressed: _selectedStatus == null
                          ? null // Disable button if no status selected
                          : () {
                              void handlePress() async {
                                setState(() => _isLoading = true);

                                // Select kiya gaya status set karna
                                final newStatus = _selectedStatus == 'Approved'
                                    ? 'Approved'
                                    : 'Rejected';
                                final successMessage =
                                    _selectedStatus == 'Approved'
                                    ? "Task has been Approved"
                                    : "Task has been Rejected";

                                try {
                                  // Firestore mein status update karna
                                  await TaskService().updateTaskStatus(
                                    widget.task.id,
                                    newStatus,
                                  );

                                  if (!context.mounted) return;
                                  Navigator.pop(
                                    context,
                                  ); // List screen per wapis jana
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    successMessage,
                                    isSuccess: _selectedStatus == 'Approved',
                                    isError: _selectedStatus == 'Rejected',
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  setState(() => _isLoading = false);
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    "Error updating task status",
                                    isError: true,
                                  );
                                }
                              }

                              handlePress();
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
