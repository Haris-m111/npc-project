import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/features/tasks/data/task_model.dart';
import 'package:npc/features/tasks/services/task_service.dart';
import 'package:npc/features/settings/task_approval_detail_screen.dart';
import 'package:npc/features/settings/widgets/task_approval_card.dart';

// Admin ke liye tamam users ke submitted tasks ki list dikhanay wala screen
class TaskApprovalScreen extends StatefulWidget {
  const TaskApprovalScreen({super.key});

  @override
  State<TaskApprovalScreen> createState() => _TaskApprovalScreenState();
}

class _TaskApprovalScreenState extends State<TaskApprovalScreen> {
  Stream<List<TaskModel>>? _tasksStream;

  @override
  @override
  void initState() {
    super.initState();
    // Tamam users ke tasks load karna (viewAll: true)
    _tasksStream = TaskService().getTasksStream(viewAll: true);
  }

  // List ko tazah (Refresh) karne wala function
  Future<void> _refreshTasks() async {
    setState(() {
      // Dubara stream load karna tamam tasks ke liye
      _tasksStream = TaskService().getTasksStream(viewAll: true);
    });
    // Behtar UX ke liye thoda intezar
    await Future.delayed(const Duration(milliseconds: 500));
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
              child: StreamBuilder<List<TaskModel>>(
                stream: _tasksStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingIndicator());
                  }

                  // Agar koi data nahi hai to empty state dikhana (Refresh option ke saath)
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshTasks,
                      color: AppColors.primary,
                      backgroundColor: AppColors.bgcolor,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 200.h),
                          _buildEmptyState(), // Khali hone ka message
                        ],
                      ),
                    );
                  }

                  // Show All Tasks (filtered by user ID in service)
                  final tasks = snapshot.data!;

                  if (tasks.isEmpty) {
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

                  // Tasks ki list ko builder ke zariye dikhana
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
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        // Status ke mutabiq UI label set karna
                        String displayStatus;
                        String? submittedOn;

                        // Status ki checking logic
                        if (task.status == 'Completed') {
                          displayStatus = 'Completed';
                          submittedOn = _formatDate(task.createdAt);
                        } else if (task.status == 'Approved') {
                          displayStatus = 'Approved';
                          submittedOn = _formatDate(task.createdAt);
                        } else if (task.status == 'Rejected') {
                          displayStatus = 'Rejected';
                          submittedOn = _formatDate(task.createdAt);
                        } else if (task.status == 'InProgress') {
                          displayStatus = 'In Progress';
                        } else {
                          displayStatus = 'Pending';
                        }

                        return GestureDetector(
                          onTap: () {
                            // Status 'Completed' hone par Admin review karsakta hai
                            if (task.status == 'Completed') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskApprovalDetailScreen(task: task),
                                ),
                              );
                            }
                          },
                          // Individual task card
                          child: TaskApprovalCard(
                            title: task.title,
                            description: task.description,
                            deadline: _formatDate(task.deadline),
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
        "No tasks found",
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
