import 'package:flutter/material.dart';

/// Shared Binance Classic-inspired dark palette.
///
/// Main canvas is charcoal grey rather than pure black. Raised surfaces
/// provide readable contrast without making each tab feel like a different
/// theme. Icon artwork and coin-specific brand colors live outside this file.
abstract final class BinancePalette {
  static const Color canvas = Color(0xFF181A20);
  static const Color surface = Color(0xFF1E2329);
  static const Color raised = Color(0xFF2B3139);
  static const Color divider = Color(0xFF252A32);
  static const Color border = Color(0xFF2B3139);

  static const Color textPrimary = Color(0xFFEAECEF);
  static const Color textSecondary = Color(0xFFB7BDC6);
  static const Color textMuted = Color(0xFF848E9C);
  static const Color textDisabled = Color(0xFF5E6673);

  static const Color yellow = Color(0xFFFCD535);
  static const Color yellowPressed = Color(0xFFF0B90B);
  static const Color green = Color(0xFF0ECB81);
  static const Color red = Color(0xFFF6465D);
}
