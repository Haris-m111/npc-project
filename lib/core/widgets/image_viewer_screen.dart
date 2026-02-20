import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:npc/core/constants/app_colors.dart';

import 'dart:io';

// Poori screen pe image dekhne ke liye widget
class ImageViewerScreen extends StatelessWidget {
  final String? base64Image; // Image ka data (Base64 format mein)
  final String? imageUrl; // Image ka URL (network image)
  final File? imageFile; // Image ki file (agar local storage mein ho)

  const ImageViewerScreen({
    super.key,
    this.base64Image,
    this.imageUrl,
    this.imageFile,
  });

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
              // Check kar rhy hain k konsi type ki image dikhani ha
              child: imageFile != null
                  ? Image.file(imageFile!, fit: BoxFit.contain)
                  : (imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) => const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 50,
                            ),
                          )
                        : Image.memory(
                            base64Decode(base64Image!),
                            fit: BoxFit.contain,
                          )),
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
