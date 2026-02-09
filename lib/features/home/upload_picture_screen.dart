import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/utils/image_helper.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_button.dart';
import 'package:npc/core/widgets/custom_dialogue.dart';

import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/features/tasks/services/task_service.dart';
import 'package:npc/core/utils/snackbar_helper.dart'; // Added
import 'package:npc/core/widgets/image_viewer_screen.dart'; // Added
import 'dart:convert'; // Added for base64Encode

import 'package:npc/features/tasks/data/task_model.dart';
import 'package:npc/features/home/quest_detail_screen.dart';

// Quest mukammal karne ke liye tasaveer upload karne wali screen
class UploadPictureScreen extends StatefulWidget {
  final TaskModel task;
  const UploadPictureScreen({super.key, required this.task});

  @override
  State<UploadPictureScreen> createState() => _UploadPictureScreenState();
}

class _UploadPictureScreenState extends State<UploadPictureScreen> {
  final List<File> _uploadedImages = [];
  bool _isLoading = false;

  void _onImagesPicked(List<File> files) {
    setState(() {
      _uploadedImages.addAll(files);
    });
  }

  // Tasaveer ko Base64 format mein tabdeel karna (Storage ke liye)
  Future<List<String>> _convertImagesToBase64() async {
    List<String> base64Images = [];
    for (var file in _uploadedImages) {
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }
    return base64Images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0),
              child: const CustomAppBar(title: "Upload Picture"),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 35.h),
                          Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget pharetra arcu. Phasellus leo .",
                            style: AppTextStyles.bodysmall.copyWith(
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 170.h,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: _uploadedImages.length + 1,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 16.w),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Pehla dabba: Nayi tasveer select karne ke liye
                            return GestureDetector(
                              onTap: () => ImageHelper.showImageSourceSheet(
                                context,
                                onImagesPicked: _onImagesPicked,
                              ),
                              child: Container(
                                width: 119.w,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(
                                    color: AppColors.iconGrey.withAlpha(50),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 30.sp,
                                      color: AppColors.iconGrey,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      "Add Pictures",
                                      style: AppTextStyles.bodysmall.copyWith(
                                        fontSize: 14.sp,
                                        color: AppColors.iconGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // Baqi dabbe: Select ki gayi tasaveer dikhanay (Preview) ke liye
                            final image = _uploadedImages[index - 1];
                            return Stack(
                              children: [
                                Container(
                                  width: 119.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.r),
                                    border: Border.all(
                                      color: AppColors.iconGrey.withAlpha(50),
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Tasveer ko full screen per dekhnay ke liye
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ImageViewerScreen(
                                                imageFile: image,
                                              ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.r),
                                      child: Image.file(
                                        image,
                                        width: 119.w,
                                        height: 170.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                // Tasveer hatanay (Delete) ka option
                                Positioned(
                                  right: 10.w,
                                  top: 10.h,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _uploadedImages.removeAt(index - 1);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4.r),
                                      decoration: BoxDecoration(
                                        color: AppColors.iconGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14.sp,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Quest ki tasaveer upload karne ka button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: _isLoading
                  ? const CustomLoadingIndicator()
                  : CustomButton(
                      text: "UPLOAD PICTURE",
                      onPressed: () async {
                        // Agar koi tasveer select nahi ki to error dikhao
                        if (_uploadedImages.isEmpty) {
                          SnackbarHelper.showTopSnackBar(
                            context,
                            "Please upload the image",
                          );
                          return;
                        }

                        setState(() => _isLoading = true);

                        try {
                          // Tasaveer convert aur upload karne ka process
                          final images = await _convertImagesToBase64();
                          await TaskService().uploadTaskImages(
                            widget.task.id,
                            images,
                          );

                          if (!context.mounted) return;
                          setState(() => _isLoading = false);

                          // Upload honey ke baad success dialog dikhao
                          final dialogTitle = images.length > 1
                              ? "Pictures Uploaded"
                              : "Picture Uploaded";

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) =>
                                CustomDialogue(title: dialogTitle),
                          );

                          // Dialog ke baad wapas quest detail page per bhejo
                          Future.delayed(const Duration(seconds: 2), () async {
                            if (!context.mounted) return;
                            Navigator.of(context).pop();

                            final updatedTask = widget.task.copyWith(
                              images: images,
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestDetailScreen(
                                  title: updatedTask.title,
                                  task: updatedTask,
                                ),
                              ),
                            );
                          });
                        } catch (e) {
                          // Upload ke dauran honey walay error handle karna
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
