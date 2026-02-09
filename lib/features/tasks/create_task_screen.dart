import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/features/tasks/data/task_model.dart';
import 'package:npc/features/tasks/services/task_service.dart';
import 'package:npc/core/widgets/custom_dialogue.dart';
import 'package:npc/features/home/home_page_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // Input fields ke liye controllers (Title aur Description)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDeadline; // Muntakhib karda deadline date
  List<String> _selectedAssigneeIds = []; // Jin users ko task dena hai unki IDs
  List<String> _selectedAssigneeNames =
      []; // Un users ke naam (display ke liye)

  bool _isLoading = false; // Task create karte waqt loading
  bool _isUsersLoading = false; // Users ki list fetch karte waqt loading
  List<Map<String, dynamic>> _users = []; // App ke tamam users ki list

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // App ke tamam users ko Firestore se nikalna taake task assign kiya ja sakay
  Future<void> _fetchUsers() async {
    setState(() => _isUsersLoading = true);
    final users = await AuthService().getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isUsersLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Calendar se deadline date select karne wala function
  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.bgcolor,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked; // Date update karna
      });
    }
  }

  // Users ko select karne ke liye multi-choice dialog dikhana
  void _showMultiSelectDialog() async {
    List<String> tempSelectedIds = List.from(_selectedAssigneeIds);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                "Select Assignees",
                style: AppTextStyles.heading1medium,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: _isUsersLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: const CustomLoadingIndicator(),
                      )
                    : SingleChildScrollView(
                        child: ListBody(
                          children: _users.map((user) {
                            final bool isUnknown =
                                user['name'] == null ||
                                user['name'].toString().trim().isEmpty;
                            final isSelected = tempSelectedIds.contains(
                              user['uid'],
                            );
                            return CheckboxListTile(
                              enabled: !isUnknown,
                              value: isSelected,
                              title: Text(
                                isUnknown ? 'Unknown User' : user['name'],
                                style: AppTextStyles.body.copyWith(
                                  color: isUnknown
                                      ? AppColors.textGrey
                                      : AppColors.black,
                                ),
                              ),
                              activeColor: AppColors.primary,
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool? checked) {
                                setStateDialog(() {
                                  if (checked == true) {
                                    tempSelectedIds.add(user['uid']);
                                  } else {
                                    tempSelectedIds.remove(user['uid']);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    "CANCEL",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAssigneeIds = tempSelectedIds;
                      _selectedAssigneeNames = _users
                          .where((u) => _selectedAssigneeIds.contains(u['uid']))
                          .map((u) => (u['name'] ?? 'Unknown User').toString())
                          .toList();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed AppBar
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 10.h),
                child: const CustomAppBar(title: "Create Task"),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // Title Field
                      _label("Title"),
                      SizedBox(height: 10.h),
                      CustomTextfields(
                        controller: _titleController,
                        hintText: "Enter task title",
                      ),
                      SizedBox(height: 16.h),

                      // Description Field
                      _label("Description"),
                      SizedBox(height: 10.h),
                      CustomTextfields(
                        controller: _descriptionController,
                        hintText: "Enter task description",
                        height: 140.h,
                        maxLines: 5,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                      SizedBox(height: 16.h),

                      // Deadline Field
                      _label("Deadline"),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus(); // Dismiss keyboard
                          _selectDeadline();
                        },
                        child: Container(
                          height: 50.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: AppColors.white.withAlpha(80),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.textLightGrey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                _selectedDeadline == null
                                    ? "Select deadline date"
                                    : _formatDate(_selectedDeadline!),
                                style: TextStyle(
                                  color: _selectedDeadline == null
                                      ? AppColors.textLightGrey.withAlpha(255)
                                      : AppColors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Assign To Multi-Select
                      _label("Assign To"),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: _showMultiSelectDialog,
                        child: Container(
                          height: 50.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: AppColors.white.withAlpha(80),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedAssigneeNames.isEmpty
                                      ? "Select assignees"
                                      : _selectedAssigneeNames.join(", "),
                                  style: AppTextStyles.headingsmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.textLightGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              // Button (Fixed at bottom)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: _isLoading
                    ? const CustomLoadingIndicator()
                    : CustomButton(
                        text: "CREATE TASK",
                        onPressed: () async {
                          // Forcefully dismiss keyboard at the very beginning
                          FocusManager.instance.primaryFocus?.unfocus();
                          FocusScope.of(context).unfocus();

                          // Validation
                          if (_titleController.text.trim().isEmpty) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Please enter task title",
                              isError: true,
                            );
                            return;
                          }

                          if (_descriptionController.text.trim().isEmpty) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Please enter task description",
                              isError: true,
                            );
                            return;
                          }

                          if (_selectedDeadline == null) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Please select deadline date",
                              isError: true,
                            );
                            return;
                          }

                          if (_selectedAssigneeIds.isEmpty) {
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Please select at least one assignee",
                              isError: true,
                            );
                            return;
                          }

                          setState(() => _isLoading = true);
                          // Delay to ensure keyboard is fully dismissed
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );

                          try {
                            // Task banane wala (Current Admin) nikalna
                            final currentUser = await AuthService()
                                .getCurrentUserData();
                            final creatorId = currentUser?['uid'] ?? '';

                            // Naya Task object taiyar karna
                            final newTask = TaskModel(
                              id: '', // Firestore khud ID banayega
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                              deadline: _selectedDeadline!,
                              assigneeIds: _selectedAssigneeIds,
                              creatorId: creatorId,
                              createdAt: DateTime.now(),
                            );

                            // Database mein save karna
                            await TaskService().createTask(newTask);

                            if (!context.mounted) return;
                            setState(() => _isLoading = false);

                            // Kamyabi ka dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  const CustomDialogue(title: "Task Created"),
                            );

                            // 2 second baad Home Page pe wapis jana
                            Future.delayed(const Duration(seconds: 2), () {
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                ).pop(); // Dialog band karein
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen(),
                                  ),
                                  (route) =>
                                      false, // Purane raste khatam karein
                                );
                              }
                            });
                          } catch (e) {
                            if (!context.mounted) return;
                            setState(() => _isLoading = false);
                            SnackbarHelper.showTopSnackBar(
                              context,
                              "Failed to create task",
                              isError: true,
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(color: AppColors.black),
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
