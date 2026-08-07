import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';

class FontFamily {
  static const poppins = "Poppins";
}

class AppTextStyles {
  // ==================== POPPINS TEXT STYLES ====================
  static TextStyle light({
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? decorationThickness,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColor.blackColor,
      fontWeight: fontWeight ?? FontWeight.w300,
      fontFamily: FontFamily.poppins,
      height: height ?? 1.1,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle regular({
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? decorationThickness,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColor.blackColor,
      fontWeight: fontWeight ?? FontWeight.w400,
      fontFamily: FontFamily.poppins,
      height: height ?? 1.1,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle medium({
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? decorationThickness,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColor.blackColor,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontFamily: FontFamily.poppins,
      height: height ?? 1.1,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle semiBold({
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? decorationThickness,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColor.blackColor,
      fontWeight: fontWeight ?? FontWeight.w600,
      fontFamily: FontFamily.poppins,
      height: height ?? 1.1,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle bold({
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? decorationThickness,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColor.blackColor,
      fontWeight: fontWeight ?? FontWeight.w700,
      fontFamily: FontFamily.poppins,
      height: height ?? 1.1,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle extraBold({
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? decorationThickness,
    double? height,
    double? letterSpacing,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColor.blackColor,
      fontWeight: fontWeight ?? FontWeight.w800,
      fontFamily: FontFamily.poppins,
      height: height ?? 1.1,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
