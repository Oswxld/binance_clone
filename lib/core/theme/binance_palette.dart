import 'package:flutter/material.dart';

/// Shared blue-charcoal theme sampled from the provided reference screenshot.
/// Canvas, surfaces, controls and dividers are shared across every tab.
abstract final class BinancePalette {
  static const Color canvas = Color(0xFF1F2630);
  static const Color surface = Color(0xFF272F3A);
  static const Color raised = Color(0xFF333B48);
  static const Color divider = Color(0xFF303847);
  static const Color border = Color(0xFF303847);

  static const Color textPrimary = Color(0xFFEAECEF);
  static const Color textSecondary = Color(0xFFB7BDC6);
  static const Color textMuted = Color(0xFF848E9C);
  static const Color textDisabled = Color(0xFF5E6673);

  static const Color yellow = Color(0xFFFCD535);
  static const Color yellowPressed = Color(0xFFF0B90B);
  static const Color green = Color(0xFF0ECB81);
  static const Color red = Color(0xFFF6465D);
}
