import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/theme/text_styles.dart';

// App mein use honay wala Custom AppBar widget
class CustomAppBar extends StatelessWidget {
  final String title; // Screen ka title name
  final bool showBack; // Kya back button dikhana hai? (Default true)
  final VoidCallback? onBackTap; // Back button dabane pe custom kaam
  // final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBackTap,
    // this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 0, bottom: 8.h),
      // color: Colors.transparent, // ya apna color
      child: Row(
        children: [
          // Agar showBack true ho to back arrow icon dikhao
          if (showBack)
            GestureDetector(
              onTap: onBackTap ?? () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left, size: 30),
            ),

          // Screen ka title text
          Expanded(
            child: Text(
              title,
              // Agar back button hai to title center mein hoga, warna left side pe
              textAlign: showBack ? TextAlign.center : TextAlign.left,
              style: AppTextStyles.heading1medium,
            ),
          ),

          // if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
