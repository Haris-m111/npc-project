import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/constants/app_assets.dart';

// App mein use honay wala reusable input field widget
class CustomTextfields extends StatefulWidget {
  final String hintText; // Khali field mein dikhanay wala text
  final IconData? icon; // Field ka icon
  final String? prefixIconPath; // Custom image icon ka path
  final bool isPassword; // Kya ye password field hai?
  final double? height; // Field ki height
  final double? width; // Field ki width
  final double? borderRadius; // Corners ki golayi
  final TextEditingController? controller; // Text control karne ke liye
  final int? maxLines; // Kitni lines allow hain
  final TextAlignVertical? textAlignVertical;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextfields({
    super.key,
    required this.hintText,
    this.icon,
    this.prefixIconPath,
    this.isPassword = false,
    this.height,
    this.width,
    this.borderRadius,
    this.controller,
    this.maxLines,
    this.textAlignVertical,
    this.inputFormatters,
  });

  // Email ke liye pehle se bana hua (pre-defined) constructor
  const CustomTextfields.email({
    super.key,
    this.hintText = "Enter your email",
    this.icon,
    this.prefixIconPath = AppAssets.emailIcon,
    this.isPassword = false,
    this.height,
    this.width,
    this.borderRadius,
    this.controller,
    this.maxLines,
    this.textAlignVertical,
    this.inputFormatters,
  });

  @override
  State<CustomTextfields> createState() => _CustomTextfieldsState();
}

class _CustomTextfieldsState extends State<CustomTextfields> {
  bool _isObscured = true; // Password ko chhupanay ya dikhanay ke liye (Toggle)

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 50.h,
      width: widget.width,
      child: TextField(
        controller: widget.controller,
        inputFormatters: widget.inputFormatters,
        obscureText: widget.isPassword ? _isObscured : false,
        maxLines: widget.isPassword ? 1 : widget.maxLines ?? 1,
        textAlignVertical: widget.textAlignVertical,
        style: AppTextStyles.headingsmall,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: (widget.maxLines != null && widget.maxLines! > 1)
                ? 12.h
                : (widget.height ?? 50.h) / 2 - 16.sp,
            horizontal: 12.w,
          ),
          // Field ke shuru mein icon ya image dikhanay ke liye
          prefixIcon: widget.prefixIconPath != null
              ? Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Image.asset(
                    widget.prefixIconPath!,
                    width: 20.w,
                    height: 20.h,
                    color: AppColors.textLightGrey,
                  ),
                )
              : (widget.icon == null
                    ? null
                    : Icon(
                        widget.icon,
                        color: AppColors.textLightGrey,
                        size: 22.sp,
                      )),
          // Agar password field ho to aankh (eye) wala icond dikhao (Visibility Toggle)
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility,
                    color: AppColors.black.withAlpha(100),
                    size: 20.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.textLightGrey.withAlpha(255),
            fontSize: 16.sp,
            fontWeight: FontWeight.w300,
          ),
          fillColor: AppColors.white.withAlpha(80),
          filled: true,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
