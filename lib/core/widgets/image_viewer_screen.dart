import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:npc/core/constants/app_colors.dart';

import 'dart:io';

// Poori screen pe image dekhne ke liye widget
class ImageViewerScreen extends StatelessWidget {
  final String? base64Image; // Image ka data (Base64 format mein)
  final File? imageFile; // Image ki file (agar local storage mein ho)

  const ImageViewerScreen({super.key, this.base64Image, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            // Image ko zoom aur pan (pinch) karne ke liye viewer
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              // Agar file mojood hai to file dikhao, warna base64 decode kar ke memory se dikhao
              child: imageFile != null
                  ? Image.file(imageFile!, fit: BoxFit.contain)
                  : Image.memory(
                      base64Decode(base64Image!),
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          // Screen ko band (close) karne ke liye top-right button
          Positioned(
            top: 40.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: AppColors.white, size: 24.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
