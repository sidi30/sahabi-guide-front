import 'package:flutter/material.dart';

class AppColors {
  // Colors
  static const Color primaryColor = Color(0xFF1D3557);
  static const Color secondaryColor = Color(0xFF2A9D8F);
  static const Color accentColor = Color(0xFFE63946);
  static const Color backgroundColor = Color(0xFFF1FAEE);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE63946);

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);

  // Primary Colors
  static const Color primary = Color(0xFF1D3557);
  static const Color primaryLight = Color(0x4D1D3557); // 30% opacity
  static const Color primaryDark = Color(0xFF14213D);

  // Secondary Colors
  static const Color secondary = Color(0xFF2A9D8F);
  static const Color secondaryLight = Color(0x4D2A9D8F); // 30% opacity

  // Accent Colors
  static const Color accent = Color(0xFFE63946);
  static const Color accentLight = Color(0x4DE63946); // 30% opacity

  // Background & Surface Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF1D3557);
  static const Color textSecondary = Color(0xFF457B9D);
  static const Color textLight = Color(0xFF6C757D);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;
  static const Color textOnAccent = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF0288D1);

  // Common Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);

  // Additional UI Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x66000000);

  // Ritual Type Colors
  static const Color prayer = primary;
  static const Color dua = secondary;
  static const Color dhikr = accent;
  static const Color reading = Color(0xFF7B1FA2); // Purple
  static const Color charity = Color(0xFF2E7D32); // Green
  static const Color fasting = Color(0xFFFF6D00); // Orange

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1D3557),
    Color(0xFF457B9D),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF2A9D8F),
    Color(0xFF83C5BE),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFE63946),
    Color(0xFFFF9A8B),
  ];

  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonAccent = accent;
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonText = Colors.white;

  // Input Fields
  static const Color inputBackground = Colors.white;
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusedBorder = primary;
  static const Color inputErrorBorder = error;
  static const Color inputHint = Color(0xFF9E9E9E);

  // Icons
  static const Color iconPrimary = primary;
  static const Color iconSecondary = secondary;
  static const Color iconAccent = accent;
  static const Color iconInactive = Color(0xFF9E9E9E);

  // Tab Bar
  static const Color tabBarBackground = Colors.white;
  static const Color tabBarSelected = primary;
  static const Color tabBarUnselected = Color(0xFF757575);
  static const Color tabBarIndicator = primary;

  // App Bar
  static const Color appBarBackground = Colors.white;
  static const Color appBarText = primary;
  static const Color appBarIcon = primary;

  // Bottom Navigation Bar
  static const Color bottomNavBackground = Colors.white;
  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = Color(0xFF757575);

  // Status Bar
  static const Color statusBarLight = Colors.transparent;
  static const Color statusBarDark = Colors.black;

  // For dark theme
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
  static const Color darkTextLight = Color(0xFF9E9E9E);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkInputBackground = Color(0xFF2D2D2D);
  static const Color darkInputBorder = Color(0xFF424242);
}
