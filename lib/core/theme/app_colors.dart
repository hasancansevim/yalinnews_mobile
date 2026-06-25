import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF3A7BD5); // Electric Blue Accent

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0A0E17);
  static const Color surfaceDark = Color(0xFF131B2B);
  
  static const Color textPrimary = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF475569); // Slate 600
  static const Color divider = Color(0xFF1E293B); // Slate 800
  static const Color bottomNavBg = Color(0xFF0F172A); // Slate 900

  // Light Theme Colors (kept for completeness if needed)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Category Colors
  static const Color techBlue = Color(0xFF2196F3);
  static const Color economyGreen = Color(0xFF4CAF50);
  static const Color worldRed = Color(0xFFF44336);
  static const Color aiPurple = Color(0xFFCE93D8); // border color, bg is 9C27B0 for some cases
  static const Color gameOrange = Color(0xFFFF9800);
  static const Color scienceCyan = Color(0xFF00BCD4);
  
  static Color getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'teknoloji': return techBlue;
      case 'ekonomi': return economyGreen;
      case 'dünya':
      case 'dunya': return worldRed;
      case 'yapay zeka': return aiPurple;
      case 'oyun': return gameOrange;
      case 'bilim': return scienceCyan;
      default: return primary;
    }
  }
}
