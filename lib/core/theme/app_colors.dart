import 'package:flutter/material.dart';

/// Pinoy-inspired color palette for "Anong Ulam Today?"
/// Warm, appetizing tones: adobo browns, banana-leaf greens, calamansi yellow.
class AppColors {
  AppColors._();

  // Primary — warm "toyo/adobo" amber-brown
  static const Color primary = Color(0xFFE8772E); // calamansi-orange
  static const Color primaryDark = Color(0xFFB85A1A);
  static const Color primaryLight = Color(0xFFFFB066);

  // Secondary — banana-leaf green
  static const Color secondary = Color(0xFF2E7D52);
  static const Color secondaryLight = Color(0xFF5BA67E);

  // Accent — calamansi yellow
  static const Color accent = Color(0xFFF4C430);

  // Neutrals
  static const Color background = Color(0xFFFFF8F0); // warm rice-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2B2118);
  static const Color textSecondary = Color(0xFF7A6E62);

  // Dark mode
  static const Color darkBackground = Color(0xFF1A1410);
  static const Color darkSurface = Color(0xFF261E17);
  static const Color darkTextPrimary = Color(0xFFF5EDE3);
  static const Color darkTextSecondary = Color(0xFFB8A99A);

  // Status
  static const Color success = Color(0xFF2E7D52);
  static const Color warning = Color(0xFFE0A800);
  static const Color error = Color(0xFFD64545);

  // Meal-type tile colors
  static const Color breakfast = Color(0xFFF4A340);
  static const Color lunch = Color(0xFFE8772E);
  static const Color dinner = Color(0xFF7B4B94);
  static const Color random = Color(0xFF2E7D52);
}
