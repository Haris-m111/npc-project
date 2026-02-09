import 'package:flutter/material.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';

// Success ya koi message dikhanay ke liye custom dialog
class CustomDialogue extends StatelessWidget {
  final String title; // Dialog ka heading text
  const CustomDialogue({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: AppColors.bgcolor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle ke andar tick icon dikhanay ke liye stack
            Stack(
              alignment: Alignment.center,
              children: [
                // Bahar wala bara circle
                CircleAvatar(
                  radius: 65,
                  backgroundColor: AppColors.primary, // outer circle color
                ),

                // Andar wala chota box (square)
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surface, // square color
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    // Check (Tick) ka nishaan
                    child: Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            // Dialog ka title (e.g. Success!)
            Text(
              title,
              style: AppTextStyles.headinglarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            // Dialog ka description text
            Text(
              "Sed dignissim nisl a vehicula fringilla. Nulla faucibus dui tellus.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodysmall.copyWith(
                fontSize: 16,
                color: AppColors.textDarkGrey,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
