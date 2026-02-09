import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';

// App mein kahin bhi confirmation lene ke liye (jaise Logout) is dialog ka istemal hota hai
class ConfirmationDialog extends StatelessWidget {
  final String title; // Dialog ka heading
  final String message; // Dialog ka main msg
  final VoidCallback onConfirm; // YES dabane pe kya hoga
  final VoidCallback? onCancel; // NO dabane pe kya hoga

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgcolor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning ya notification icon dikhanay ke liye
            Container(
              height: 80.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.primary,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 20.h),

            // Dialog ka title (e.g. Logout?)
            Text(
              title,
              style: AppTextStyles.headinglarge.copyWith(
                color: AppColors.primary,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: 12.h),

            // Dialog ka detailed message
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodysmall.copyWith(
                fontSize: 15.sp,
                color: AppColors.textDarkGrey,
              ),
            ),
            SizedBox(height: 24.h),

            // Action buttons (YES aur NO)
            Row(
              children: [
                // Inkar (NO) karne wala button
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.textGrey, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'NO',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Haan (YES) karne wala button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'YES',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
