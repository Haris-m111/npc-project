import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/utils/image_helper.dart';
import 'package:npc/core/widgets/custom_textfields.dart';
import 'package:npc/core/utils/snackbar_helper.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/view_models/profile_view_model.dart';
import 'package:npc/core/services/auth_service.dart';
import 'package:npc/features/auth/login_screen.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Agar hum update karny aaye hain, to purana data load kryn gay
    if (widget.isUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProfileData();
      });
    }
  }

  Future<void> _loadProfileData() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    bool success = await profileVM.getProfile();

    if (success && mounted) {
      final user = profileVM.userProfile;
      if (user != null) {
        setState(() {
          _nameController.text = user.name ?? "";
          _existingImageBase64 = user.profilePicture;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Jab user gallary ya camera se tasveer select kar leta hai
  void _onImagesPicked(List<File> files) {
    if (files.isNotEmpty) {
      setState(() {
        imageFile = files.first;
      });
    }
  }

  // Back jane ka action
  Future<void> _handleBackNavigation() async {
    if (!mounted) return;
    if (widget.isUpdate) {
      Navigator.pop(context);
    } else {
      // Agar onboarding flow (Signup/Login) se aaye hain, to wapis Login screen pr jao
      // Bajaye iske ke app band ho jaye ya black screen aaye
      await AuthService()
          .signOut(); // Optional: User ko logout kr dena behtar hai
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
                                                            return Container(
                                                              width: 130,
                                                              height: 130,
                                                              color: AppColors
                                                                  .surface,
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 80,
                                                                color: AppColors
                                                                    .iconGrey
                                                                    .withAlpha(
                                                                      100,
                                                                    ),
                                                              ),
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
                                            : Container(
                                                width: 130,
                                                height: 130,
                                                color: AppColors.surface,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 80,
                                                  color: AppColors.iconGrey
                                                      .withAlpha(100),
                                                ),
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
                  child: Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      return profileVM.isLoading
                          ? const CustomLoadingIndicator()
                          : CustomButton(
                              text: widget.isUpdate
                                  ? "UPDATE PROFILE"
                                  : "CREATE PROFILE",
                              onPressed: () async {
                                FocusScope.of(
                                  context,
                                ).unfocus(); // Close keyboard

                                String name = _nameController.text.trim();
                                if (name.isEmpty) {
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    "Please enter your name",
                                    isError: true,
                                  );
                                  return;
                                }

                                // Image ko handle krna (Base64 format me convert krty hain)
                                String? profilePic;
                                if (imageFile != null) {
                                  try {
                                    final bytes = await imageFile!
                                        .readAsBytes();
                                    profilePic = base64Encode(bytes);
                                  } catch (e) {
                                    debugPrint("Image processing error: $e");
                                  }
                                } else if (_existingImageBase64 != null) {
                                  // Agar nayi image nahi li to puraani wali use kro
                                  profilePic = _existingImageBase64;
                                }

                                bool success;
                                if (widget.isUpdate) {
                                  success = await profileVM.updateProfile(
                                    name,
                                    profilePic,
                                  );
                                } else {
                                  success = await profileVM.createProfile(
                                    name,
                                    profilePic,
                                  );
                                }

                                if (!context.mounted) return;

                                if (success) {
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    profileVM.successMessage ??
                                        (widget.isUpdate
                                            ? "Profile updated successfully!"
                                            : "Profile created successfully!"),
                                    isSuccess: true,
                                  );

                                  if (widget.isUpdate) {
                                    Navigator.of(context).pop();
                                  } else {
                                    // Home screen per navigate karna
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePageScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                } else {
                                  SnackbarHelper.showTopSnackBar(
                                    context,
                                    profileVM.errorMessage ??
                                        "Failed to create profile",
                                    isError: true,
                                  );
                                }
                              },
                            );
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
