import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ColorUtils {
  static Color getColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      case 'accent':
        return AppColors.accent;
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  static Color parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

