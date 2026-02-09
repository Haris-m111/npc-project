import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';

class AppTextStyles {
  // Bari heading ke liye (e.g. Splash screen ya main titles)
  static final TextStyle headinglarge = TextStyle(
    fontFamily: "Nunito",
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  // Darmiyane size ki black heading ke liye
  static final TextStyle heading1medium = TextStyle(
    fontFamily: "Nunito",
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // Main body text ke liye (white grey color mein)
  static final TextStyle body = TextStyle(
    fontFamily: "Nunito",
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteGrey,
  );

  // Choti details ya description ke liye
  static final TextStyle bodysmall = TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Nunito',
    color: AppColors.textGrey,
  );

  // Halay grey color wali choti heading
  static final TextStyle headingsmall = TextStyle(
    fontFamily: "Nunito",
    fontWeight: FontWeight.w300,
    fontSize: 16.sp,
    color: AppColors.textLightGrey,
  );

  // Screen ke main title/heading ke liye
  static final TextStyle mainheading = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    fontFamily: 'Nunito',
    color: AppColors.black,
  );

  // Button text ya card titles ke liye (Mulish font)
  static final TextStyle headingmedium = TextStyle(
    fontFamily: "Mulish",
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}
