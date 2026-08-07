import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool obscureText;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final EdgeInsets? contentPadding;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enableSuggestions;
  final bool autocorrect;
  final Iterable<String>? autofillHints;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscureText = false,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.contentPadding,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.enableSuggestions = false,
    this.autocorrect = false,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      enableIMEPersonalizedLearning: false,
      autofillHints: autofillHints,
      onChanged: onChanged,
      style: AppTextStyles.regular(
        fontSize: 15.sp,
        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.regular(
          fontSize: 14.sp,
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        ),
        hintStyle: AppTextStyles.light(
          fontSize: 14.sp,
          color: isDark ? AppColors.darkSecondaryText.withAlpha(120) : AppColors.lightSecondaryText.withAlpha(120),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            width: 1.8,
          ),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        prefixIcon: Icon(
          icon,
          size: 20.r,
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        ),
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: maxLines > 1 ? 16.h : 14.h,
            ),
      ),
    );
  }
}
