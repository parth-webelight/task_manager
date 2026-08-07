import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';

class CustomFillableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool isDark;
  final Color fillColor;
  final bool obscureText;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? iconSize;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enableSuggestions;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final List<dynamic>? inputFormatters;

  const CustomFillableTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    required this.isDark,
    required this.fillColor,
    this.obscureText = false,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.height,
    this.width,
    this.fontSize,
    this.iconSize,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.enableSuggestions = false,
    this.autocorrect = false,
    this.autofillHints,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        maxLength: maxLength,
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
        inputFormatters: inputFormatters?.cast<TextInputFormatter>(),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        enableSuggestions: enableSuggestions,
        autocorrect: autocorrect,
        enableIMEPersonalizedLearning: false,
        autofillHints: autofillHints,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyles.regular(
          fontSize: fontSize ?? 15.sp,
          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: AppTextStyles.light(
            fontSize: fontSize ?? 14.sp,
            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
          ),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              width: 1.8,
            ),
          ),
          prefixIcon: icon != null
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                  ),
                  child: Icon(
                    icon!,
                    size: iconSize ?? 20.r,
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}
