import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/features/settings/create_profile_screen.dart';
import 'package:npc/features/auth/login_screen.dart';
import 'package:npc/features/settings/about_privacy_screen.dart';
import 'package:npc/features/settings/delete_account_screen.dart';
import 'package:npc/features/settings/update_pass_screen.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/widgets/custom_setting_button.dart';
import 'package:npc/core/widgets/confirmation_dialog.dart';
import 'package:npc/features/tasks/create_task_screen.dart';
import 'package:npc/features/settings/task_approval_screen.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';

// App ki tamama settings ka main screen jahan different options hain
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isNotifOn = false; // Notification switch ki mojooda halat (On/Off)
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference(); // App khulnay per purani setting load karna
  }

  // Mobile storage (SharedPreferences) se notification ki setting nikalna
  Future<void> _loadNotificationPreference() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        isNotifOn = prefs.getBool('notif_enabled_${user.uid}') ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 35.h),
                    CustomAppBar(title: "Settings"),
                    SizedBox(height: 30.h),
                    // Notification on/off karne wala option
                    SettingsTile(
                      onTap: () {},
                      imagePath: AppAssets.iconNotify,
                      title: "Notifications",
                      isNotification: true, // Isse switch show hoga
                      switchValue: isNotifOn, // Current state
                      onSwitchChanged: (val) async {
                        setState(() {
                          isNotifOn = val; // Switch update karega
                        });
                        final user = AuthService().currentUser;
                        if (user != null) {
                          final prefs = await SharedPreferences.getInstance();
                          // Setting ko mobile mein save karna
                          await prefs.setBool('notif_enabled_${user.uid}', val);
                        }
                      },
                    ),
                    // Profile Edit karne wala option
                    SettingsTile(
                      imagePath: AppAssets.profileIcon,
                      title: "Edit Profile",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateProfileScreen(isUpdate: true),
                          ),
                        );
                      },
                    ),

                    // Password change karne wala option
                    SettingsTile(
                      imagePath: AppAssets.passIcon,
                      title: "Change Password",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UpdatePassScreen(),
                          ),
                        );
                      },
                    ),

                    // Naya Task banane wala option (Admin/Special users ke liye)
                    SettingsTile(
                      imagePath: AppAssets.passIcon,
                      title: "Create Task",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateTaskScreen(),
                          ),
                        );
                      },
                    ),
                    // Tasks review (Approve/Reject) karne wala option
                    SettingsTile(
                      imagePath: AppAssets.iconNotify,
                      title: "Task Approval",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TaskApprovalScreen(),
                          ),
                        );
                      },
                    ),
                    // App ke baaray mein maloomat
                    SettingsTile(
                      imagePath: AppAssets.aboutIcon,
                      title: "About App",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutPrivacyScreen(
                              title: "About App",
                              description:
                                  "This app helps users manage quests easily and efficiently.",
                            ),
                          ),
                        );
                      },
                    ),
                    // Privacy Policy wala option
                    SettingsTile(
                      imagePath: AppAssets.privacyIcon,
                      title: "Privacy Policy",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutPrivacyScreen(
                              title: "Privacy Policy",
                              description:
                                  "This app helps users manage quests easily and efficiently.",
                            ),
                          ),
                        );
                      },
                    ),
                    // Logout karne wala option
                    SettingsTile(
                      imagePath: AppAssets.logoutIcon,
                      title: "Logout",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            title: "Logout",
                            message: "Are you sure you want to logout?",
                            onConfirm: () async {
                              // Navigator ko pehle store karna async gap se bachnay ke liye
                              final navigator = Navigator.of(
                                context,
                                rootNavigator: true,
                              );

                              navigator.pop(); // Confirmation dialog band karna
                              setState(() => _isLoggingOut = true);

                              try {
                                // 2 seconds ka intezar smooth UX ke liye
                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );

                                // Sign out karna (Custom API integration)
                                final authVM = Provider.of<AuthViewModel>(
                                  context,
                                  listen: false,
                                );
                                await authVM.logout();

                                // Login screen per wapis bhejna
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                debugPrint("Logout error: $e");
                                navigator.pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                    // Account permanently delete karne wala option
                    SettingsTile(
                      imagePath: AppAssets.deleteIcon,
                      title: "Delete Account",
                      textColor: AppColors.red,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DeleteAccountScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoggingOut)
              // Jab logout ho raha ho to screens ke oopar loading dikhana
              Positioned.fill(
                child: Container(
                  color: AppColors.bgcolor.withAlpha(200),
                  child: const Center(child: CustomLoadingIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
