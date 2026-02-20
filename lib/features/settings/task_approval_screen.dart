import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/view_models/quest_view_model.dart';
import 'package:npc/features/settings/task_approval_detail_screen.dart';
import 'package:npc/features/settings/widgets/task_approval_card.dart';
import 'package:provider/provider.dart';

// Admin ke liye tamam users ke submitted (completed) tasks ki list dikhanay wala screen
class TaskApprovalScreen extends StatefulWidget {
  const TaskApprovalScreen({super.key});

  @override
  State<TaskApprovalScreen> createState() => _TaskApprovalScreenState();
}

class _TaskApprovalScreenState extends State<TaskApprovalScreen> {
  @override
  void initState() {
    super.initState();
    // Tamam users ke submitted (completed) tasks load karna
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestViewModel>(context, listen: false).fetchQuests(
        'completed',
      ); // 'completed' status wale tasks review ke liye hotay hain
    });
  }

  // List ko tazah (Refresh) karne wala function
  Future<void> _refreshTasks() async {
    await Provider.of<QuestViewModel>(
      context,
      listen: false,
    ).fetchQuests('completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 35.h),
              child: const CustomAppBar(title: "Task Approval", showBack: true),
            ),
            Expanded(
              child: Consumer<QuestViewModel>(
                builder: (context, questVM, child) {
                  if (questVM.isLoading) {
                    return const Center(child: CustomLoadingIndicator());
                  }

                  final quests = questVM.completedQuests;

                  // Agar koi data nahi hai to empty state dikhana
                  if (quests.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshTasks,
                      color: AppColors.primary,
                      backgroundColor: AppColors.bgcolor,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 200.h),
                          _buildEmptyState(),
                        ],
                      ),
                    );
                  }

                  // Quests ki list ko builder ke zariye dikhana
                  return RefreshIndicator(
                    onRefresh: _refreshTasks,
                    color: AppColors.primary,
                    backgroundColor: AppColors.bgcolor,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      itemCount: quests.length,
                      itemBuilder: (context, index) {
                        final quest = quests[index];
                        // Status ke mutabiq UI label set karna
                        String displayStatus;
                        String? submittedOn;

                        // Status ki checking logic (API lowercase underscores use karti hai)
                        if (quest.status == 'completed') {
                          displayStatus = 'Completed';
                          submittedOn = quest.createdAt != null
                              ? _formatDate(quest.createdAt!)
                              : null;
                        } else if (quest.status == 'approved') {
                          displayStatus = 'Approved';
                        } else if (quest.status == 'rejected') {
                          displayStatus = 'Rejected';
                        } else if (quest.status == 'in_progress') {
                          displayStatus = 'In Progress';
                        } else {
                          displayStatus = 'Pending';
                        }

                        return GestureDetector(
                          onTap: () {
                            // Review detail screen par bhej rhy hain
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskApprovalDetailScreen(quest: quest),
                              ),
                            );
                          },
                          // Individual task card
                          child: TaskApprovalCard(
                            title: quest.title ?? "",
                            description: quest.description ?? "",
                            deadline: quest.dueDate != null
                                ? _formatDate(quest.dueDate!)
                                : "No deadline",
                            submittedOn: submittedOn,
                            status: displayStatus,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Agar koi task na mile to yeh widget show hoga
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "No tasks found for approval",
        style: AppTextStyles.body.copyWith(
          color: AppColors.textGrey,
          fontSize: 16.sp,
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
