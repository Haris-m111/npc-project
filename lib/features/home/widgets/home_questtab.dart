import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/constants/app_colors.dart';

// Home screen pe counters aur tabs (New, In Progress, Completed) wala section
class HomeQuestTabs extends StatefulWidget {
  final int initialIndex; // Pehle se select kiya gaya tab index
  final Function(int)?
  onTabChanged; // Tab change hone pe call hone wala function
  final String pendingCount; // Pending tasks ki tadad
  final String completedCount; // Completed tasks ki tadad
  final String totalCount; // Total assigned tasks ki tadad

  const HomeQuestTabs({
    super.key,
    this.initialIndex = 0,
    this.onTabChanged,
    required this.pendingCount,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  State<HomeQuestTabs> createState() => _HomeQuestTabsState();
}

class _HomeQuestTabsState extends State<HomeQuestTabs> {
  // variable
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          // COUNTERS
          // Oopar walay teeno counters (Pending, Completed, Total)
          Row(
            children: [
              Expanded(child: _counterItem(widget.pendingCount, "Pending")),
              Expanded(child: _counterItem(widget.completedCount, "Completed")),
              Expanded(child: _counterItem(widget.totalCount, "Total Quest")),
            ],
          ),

          SizedBox(height: 15.h),

          // TABS
          // Task filtering ke liye buttons (Tabs)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tabButton("New Quest", 0),
              _tabButton("In Progress", 1),
              _tabButton("Completed", 2),
            ],
          ),
        ],
      ),
    );
  }

  // Single Counter
  // Ek counter item (Number aur uske neeche title) banane ke liye
  Widget _counterItem(String count, String title) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.body.copyWith(
            fontSize: 18.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: AppTextStyles.bodysmall.copyWith(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  // Tab Button
  // Tab button banane ka function (Jo active tab ko highlight karta hai)
  Widget _tabButton(String title, int index) {
    final bool isActive = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index; // Naya tab select karo
          });
          widget.onTabChanged?.call(
            index,
          ); // Parent ko batao ke tab badal gaya hai
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.surface, // Active tab ka background color
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontSize: 16.sp,
                color: isActive
                    ? AppColors.white
                    : AppColors.textGrey, // Active tab ka text color
              ),
            ),
          ),
        ),
      ),
    );
  }
}
