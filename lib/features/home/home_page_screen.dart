import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/features/home/notification_screen.dart';
import 'package:npc/features/settings/setting_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/features/home/widgets/home_header.dart';
import 'package:npc/features/home/widgets/home_questtab.dart';
import 'package:npc/features/home/widgets/quest_card.dart';
import 'package:npc/features/home/widgets/completed_quest_card.dart';
import 'package:npc/features/home/quest_detail_screen.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/view_models/profile_view_model.dart';
import 'package:npc/view_models/quest_view_model.dart';
import 'package:npc/data/models/quest_model.dart';

// App ka main Home screen jahan tamam quests aur status counters nazar aatay hain
class HomePageScreen extends StatefulWidget {
  final int initialTabIndex; // Screen khulnay pe kounsa tab active hoga
  const HomePageScreen({super.key, this.initialTabIndex = 0});
  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;

    // Profile aur ALL Quest data fetch karna API se (For accurate counters)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).getProfile();
      Provider.of<QuestViewModel>(context, listen: false).fetchAllMyQuests();
    });
  }

  void _fetchQuestsForCurrentTab() {
    final questVM = Provider.of<QuestViewModel>(context, listen: false);
    if (_currentTabIndex == 0) {
      questVM.fetchMyQuests('pending');
    } else if (_currentTabIndex == 1) {
      questVM.fetchMyQuests('in-progress');
    } else if (_currentTabIndex == 2) {
      questVM.fetchMyQuests('submitted'); // Submitted, Approved, or Rejected
    }
  }

  // Screen ko refresh karne ke liye logic
  Future<void> _refreshTasks() async {
    await Provider.of<ProfileViewModel>(context, listen: false).getProfile();
    await Provider.of<QuestViewModel>(
      context,
      listen: false,
    ).fetchAllMyQuests();

    // UX behtar karne ke liye thora delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, QuestViewModel>(
      builder: (context, profileVM, questVM, child) {
        String userName = profileVM.userProfile?.name ?? "User";

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            SystemNavigator.pop();
          },
          child: Scaffold(
            backgroundColor: AppColors.bgcolor,
            body: SafeArea(
              child: Column(
                children: [
                  // Fixed Header
                  HomeHeader(
                    name: "$userName!",
                    onNotificationTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(),
                        ),
                      );
                    },
                    onSettingTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(),
                        ),
                      );
                    },
                  ),

                  // Counters & Tabs
                  HomeQuestTabs(
                    initialIndex: _currentTabIndex,
                    pendingCount: "${questVM.pendingCount}",
                    completedCount: "${questVM.completedCount}",
                    totalCount: "${questVM.totalCount}",
                    onTabChanged: (index) {
                      setState(() {
                        _currentTabIndex = index;
                      });
                      _fetchQuestsForCurrentTab();
                    },
                  ),
                  SizedBox(height: 10.h),

                  Expanded(
                    child: questVM.isLoading
                        ? const Center(child: CustomLoadingIndicator())
                        : RefreshIndicator(
                            onRefresh: _refreshTasks,
                            color: AppColors.primary,
                            backgroundColor: AppColors.bgcolor,
                            child: _buildListContent(questVM),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListContent(QuestViewModel questVM) {
    List<QuestModel> questsToShow = [];

    if (_currentTabIndex == 0) {
      questsToShow = questVM.pendingQuests;
    } else if (_currentTabIndex == 1) {
      questsToShow = questVM.inProgressQuests;
    } else if (_currentTabIndex == 2) {
      questsToShow = questVM.completedQuests;
    }

    if (questsToShow.isEmpty) {
      return ListView(children: [_buildEmptyState()]);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: questsToShow.length,
      itemBuilder: (context, index) {
        final quest = questsToShow[index];

        if (_currentTabIndex == 2) {
          return CompletedQuestCard(quest: quest);
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestDetailScreen(quest: quest),
              ),
            );
          },
          child: QuestCard(quest: quest),
        );
      },
    );
  }

  // Widget for Empty State
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 180.h),
        Image.asset(
          AppAssets.mask,
          height: 70.h,
          width: 120.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 12.h),
        Text(
          "No Active Quest",
          style: AppTextStyles.body.copyWith(
            fontSize: 16.sp,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
