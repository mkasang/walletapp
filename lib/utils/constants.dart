import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFF1976D2);
  static const accent = Color(0xFF03A9F4);
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA000);
}

class AppStyles {
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static final cardShadow = BoxShadow(
    color: AppColors.primary.withOpacity(0.3),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}

class AppConstants {
  static const animationDuration = Duration(milliseconds: 300);
  static const transactionPageSize = 20;
}
