import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  // Gallery ya Camera se images pick karne ka main function
  static Future<void> _pickImage(
    ImageSource source, {
    required Function(List<File>) onImagesPicked,
  }) async {
    if (source == ImageSource.gallery) {
      // Gallery se ek se zyada images select karne ke liye
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 40,
      );
      if (pickedFiles.isNotEmpty) {
        onImagesPicked(pickedFiles.map((f) => File(f.path)).toList());
      }
    } else {
      // Camera se ek image lene ke liye
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 40,
      );
      if (pickedFile != null) {
        onImagesPicked([File(pickedFile.path)]);
      }
    }
  }

  // Screen par option sheet dikhata hai (Gallery ya Camera select karne ke liye)
  static void showImageSourceSheet(
    BuildContext context, {
    required Function(List<File>) onImagesPicked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgcolor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Gallery',
                  style: AppTextStyles.body.copyWith(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(
                    ImageSource.gallery,
                    onImagesPicked: onImagesPicked,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(
                  'Camera',
                  style: AppTextStyles.body.copyWith(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(
                    ImageSource.camera,
                    onImagesPicked: onImagesPicked,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
