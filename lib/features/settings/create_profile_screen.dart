import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_dialogue.dart';
import 'package:npc/core/utils/image_helper.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/features/auth/login_screen.dart';

// User ka profile banane ya update karne wala screen
class CreateProfileScreen extends StatefulWidget {
  final bool isUpdate; // Agar profile update karni ho to 'true' hoga
  const CreateProfileScreen({super.key, this.isUpdate = false});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  File? imageFile;
  String? _existingImageBase64;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Pehle se majood user data Firestore se load karna
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic>? userData = await AuthService().getCurrentUserData();
      if (userData != null && mounted) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _existingImageBase64 = userData['imageUrl'];
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showTopSnackBar(
          context,
          "Error loading profile: $e",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController
        .dispose(); // Memory bachanay ke liye controller khatam karna
    super.dispose();
  }

  // Jab user gallary ya camera se tasveer select kar leta hai
  void _onImagesPicked(List<File> files) {
    if (files.isNotEmpty) {
      setState(() {
        imageFile = files.first; // Pehli select ki gayi tasveer ko save karna
      });
    }
  }

  // Back jane ka action (Agar update hai to back, warna sign out)
  Future<void> _handleBackNavigation() async {
    if (widget.isUpdate) {
      if (mounted) Navigator.pop(context);
    } else {
      // Pehli dafa profile banate waqt wapis jane par user ko logout karna padega
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgcolor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 40.h, 10.w, 18.h),
                  child: CustomAppBar(
                    title: widget.isUpdate ? "Edit Profile" : "",
                    onBackTap: _handleBackNavigation,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... existing ui code structure is fine, just replacing the callback ...
                        if (!widget.isUpdate)
                          Text(
                            'Create Your Profile',
                            style: AppTextStyles.mainheading,
                          ),
                        SizedBox(height: 16.h),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo .',
                          style: AppTextStyles.bodysmall,
                        ),
                        SizedBox(height: 22.h),
                        // Profile picture dikhanay aur select karne wala hissa
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surface,
                                  border: Border.all(
                                    color: AppColors.iconGrey.withAlpha(50),
                                  ),
                                ),
                                child: ClipOval(
                                  child: imageFile != null
                                      ? Image.file(
                                          imageFile!, // Nayi tasveer select ki gayi
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        )
                                      : (_existingImageBase64 != null &&
                                                _existingImageBase64!.isNotEmpty
                                            ? (_existingImageBase64!.startsWith(
                                                    'http',
                                                  )
                                                  ? Image.network(
                                                      _existingImageBase64!, // URL wali tasveer
                                                      width: 130,
                                                      height: 130,
                                                      fit: BoxFit.cover,
                                                      filterQuality:
                                                          FilterQuality.high,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return const Center(
                                                              child:
                                                                  CustomLoadingIndicator(),
                                                            );
                                                          },
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Image.asset(
                                                              AppAssets
                                                                  .dummyProfile,
                                                              width: 130,
                                                              height: 130,
                                                              fit: BoxFit.cover,
                                                              filterQuality:
                                                                  FilterQuality
                                                                      .high,
                                                            );
                                                          },
                                                    )
                                                  : Image.memory(
                                                      base64Decode(
                                                        _existingImageBase64!, // Base64 wali tasveer
                                                      ),
                                                      width: 130,
                                                      height: 130,
                                                      fit: BoxFit.cover,
                                                      filterQuality:
                                                          FilterQuality.high,
                                                    ))
                                            : Image.asset(
                                                AppAssets
                                                    .dummyProfile, // Default tasveer
                                                width: 130,
                                                height: 130,
                                                fit: BoxFit.cover,
                                                filterQuality:
                                                    FilterQuality.high,
                                              )),
                                ),
                              ),
                              Positioned(
                                bottom: 10.h,
                                right: 4.w,
                                child: GestureDetector(
                                  onTap: () => ImageHelper.showImageSourceSheet(
                                    context,
                                    onImagesPicked:
                                        _onImagesPicked, // Gallary/Camera ka option
                                  ),
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primary,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: AppColors.white,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Name',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        CustomTextfields(
                          controller: _nameController,
                          hintText: 'Enter your name',
                          inputFormatters: [
                            // Sirf A-Z aur spaces allow karna (Numbers/Signs nahi)
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                  child: _isLoading
                      ? const CustomLoadingIndicator()
                      : CustomButton(
                          text: widget.isUpdate
                              ? "UPDATE PROFILE"
                              : "CREATE PROFILE",
                          onPressed: () async {
                            FocusScope.of(context).unfocus(); // Close keyboard
                            if (widget.isUpdate) {
                              String name = _nameController.text.trim();
                              if (name.isEmpty) {
                                SnackbarHelper.showTopSnackBar(
                                  context,
                                  "Please enter your name",
                                  isError: true,
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                // Yeh check karna ke kya yeh naam koi aur to use nahi kar raha
                                bool isTaken = await AuthService().isNameTaken(
                                  name,
                                  excludeUid: AuthService().currentUser?.uid,
                                );

                                if (isTaken) {
                                  if (!context.mounted) return;
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    "This name is already taken. Please choose another one.",
                                    isError: true,
                                  );
                                  return;
                                }

                                // Firestore mein user ki profile update karna
                                await AuthService().updateUserProfile(
                                  name: name,
                                  imageFile: imageFile,
                                );

                                if (!context.mounted) return;
                                // Success message dikhana
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const CustomDialogue(
                                    title: "Profile Updated",
                                  ),
                                );
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (context.mounted) {
                                    Navigator.pop(context); // Dialog band karna
                                    Navigator.of(
                                      context,
                                    ).pop(); // Pichli screen pe jana
                                  }
                                });
                              } catch (e) {
                                if (context.mounted) {
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    "Error: $e",
                                    isError: true,
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            } else {
                              String name = _nameController.text.trim();
                              if (name.isEmpty) {
                                SnackbarHelper.showTopSnackBar(
                                  context,
                                  "Please enter your name",
                                  isError: true,
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                // Naam ki uniqueness check karna
                                bool isTaken = await AuthService().isNameTaken(
                                  name,
                                  excludeUid: AuthService().currentUser?.uid,
                                );

                                if (isTaken) {
                                  if (!context.mounted) return;
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    "This name is already taken. Please choose another one.",
                                    isError: true,
                                  );
                                  return;
                                }

                                // Naya profile record Firestore mein save karna
                                await AuthService().saveUserProfile(
                                  name: name,
                                  imageFile: imageFile,
                                );

                                // Thoda intezar (smooth display ke liye)
                                await Future.delayed(
                                  const Duration(milliseconds: 1000),
                                );

                                if (!context.mounted) return;
                                // Home screen per navigate karna
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    "Error: $e",
                                    isError: true,
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
