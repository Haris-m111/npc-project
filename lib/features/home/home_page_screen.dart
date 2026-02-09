import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/features/home/notification_screen.dart';
import 'package:npc/features/home/quest_detail_screen.dart';
import 'package:npc/features/settings/setting_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/features/home/widgets/home_header.dart';
import 'package:npc/features/home/widgets/home_questtab.dart';
import 'package:npc/features/home/widgets/quest_card.dart';
import 'package:npc/features/home/widgets/completed_quest_card.dart';
import 'package:npc/features/home/upload_picture_screen.dart';
import 'package:npc/features/tasks/services/task_service.dart';
import 'package:npc/features/tasks/data/task_model.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/core/services/auth_service.dart';

// App ka main Home screen jahan tamam quests aur status counters nazar aatay hain
class HomePageScreen extends StatefulWidget {
  final int initialTabIndex; // Screen khulnay pe kounsa tab active hoga
  const HomePageScreen({super.key, this.initialTabIndex = 0});
  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _currentTabIndex;
  Stream<List<TaskModel>>? _tasksStream;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
    final userId = AuthService().currentUser?.uid;
    // Database se tasks ka live stream lena
    _tasksStream = TaskService().getTasksStream(userId: userId);
  }

  // Screen ko refresh karne ke liye logic
  Future<void> _refreshTasks() async {
    setState(() {
      final userId = AuthService().currentUser?.uid;
      _tasksStream = TaskService().getTasksStream(userId: userId);
    });
    // UX behtar karne ke liye thora delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // Initialize stream if null (handles hot reload cases)
    _tasksStream ??= TaskService().getTasksStream();

    return StreamBuilder<DocumentSnapshot>(
      stream: AuthService().getUserStream(),
      builder: (context, userSnapshot) {
        String userName = "User";
        if (userSnapshot.hasData && userSnapshot.data!.data() != null) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          userName = data['name'] ?? "User";
        }

        return StreamBuilder<List<TaskModel>>(
          stream: _tasksStream,
          builder: (context, taskSnapshot) {
            // Loading State for initial fetch - only show if no data yet
            if (taskSnapshot.connectionState == ConnectionState.waiting &&
                !taskSnapshot.hasData) {
              return Scaffold(
                backgroundColor: AppColors.bgcolor,
                body: const Center(child: CustomLoadingIndicator()),
              );
            }

            // Tasks ko status ke mutabiq categorize karna
            final tasks = taskSnapshot.data ?? [];
            final totalCount = tasks.length;

            final pendingTasks = tasks
                .where((t) => t.status == 'Pending')
                .toList();
            final pendingCount = pendingTasks.length;

            final inProgressTabTasks = tasks
                .where((t) => t.status == 'InProgress')
                .toList();

            final finalizedTasks = tasks
                .where((t) => ['Approved', 'Rejected'].contains(t.status))
                .toList();

            final awaitingApprovalCount = tasks
                .where((t) => t.status == 'Completed')
                .length;

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

                      // Scrollable Content
                      HomeQuestTabs(
                        initialIndex: _currentTabIndex,
                        pendingCount: "$pendingCount",
                        completedCount: "$awaitingApprovalCount",
                        totalCount: "$totalCount",
                        onTabChanged: (index) {
                          setState(() {
                            _currentTabIndex = index;
                          });
                        },
                      ),
                      SizedBox(height: 10.h),

                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshTasks,
                          color: AppColors.primary,
                          backgroundColor: AppColors
                              .bgcolor, // Changed from White to match background
                          child: _buildListContent(
                            tasks,
                            pendingTasks,
                            inProgressTabTasks,
                            finalizedTasks,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListContent(
    List<TaskModel> allTasks,
    List<TaskModel> pendingTasks,
    List<TaskModel> inProgressTasks,
    List<TaskModel> completedTasks,
  ) {
    List<TaskModel> tasksToShow = [];

    if (_currentTabIndex == 0) {
      tasksToShow = pendingTasks;
    } else if (_currentTabIndex == 1) {
      tasksToShow = inProgressTasks;
    } else if (_currentTabIndex == 2) {
      tasksToShow = completedTasks;
    }

    if (tasksToShow.isEmpty) {
      // RefreshIndicator needs a scrollable child to work
      return ListView(children: [_buildEmptyState()]);
    }

    if (_currentTabIndex == 2) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: tasksToShow.length,
        itemBuilder: (context, index) {
          final task = tasksToShow[index];
          return CompletedQuestCard(
            task: task, // Pass full task
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: tasksToShow.length,
      itemBuilder: (context, index) {
        final task = tasksToShow[index];
        return GestureDetector(
          onTap: () {
            if (_currentTabIndex == 1) {
              // In Progress Logic
              if (task.images.isNotEmpty) {
                // If images are already uploaded, go directly to complete quest flow
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuestDetailScreen(title: task.title, task: task),
                  ),
                );
              } else {
                // Go to Upload Picture
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPictureScreen(task: task),
                  ),
                );
              }
            } else {
              // Pending (or others) -> Go to Quest Detail
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuestDetailScreen(title: task.title, task: task),
                ),
              );
            }
          },
          child: QuestCard(
            title: task.title,
            description: task.description,
            deadline: "Deadline: ${_formatDate(task.deadline)}",
          ),
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
        // Using logo as placeholder image
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
