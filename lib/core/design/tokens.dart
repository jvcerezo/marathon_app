import 'package:flutter/material.dart';

/// Design tokens for the marathon app. Hand-tuned for a runner-focused
/// dark-first interface inspired by Strava and Whoop.
///
/// Keep this file the single source of truth for spacing, radii, motion,
/// and brand-specific colors. Don't sprinkle magic numbers across widgets.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Bottom padding for scrollable content on shell tabs, accounting
  /// for the floating "Start run" button so it doesn't cover anything.
  static const double fabSafe = 120;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;
}

class AppMotion {
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 240);
  static const Duration medium = Duration(milliseconds: 380);
  static const Duration long = Duration(milliseconds: 600);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
}

/// Brand palette. Used directly when the ColorScheme can't capture intent
/// (e.g. the always-dark recording surface, energy/race accents).
class AppColors {
  // Backgrounds (dark-first)
  static const Color ink = Color(0xFF0A0E14); // deepest surface
  static const Color shade = Color(0xFF11161F); // raised surface
  static const Color slate = Color(0xFF1A212C); // card surface
  static const Color iron = Color(0xFF252D3A); // input/border surface

  // Foregrounds (dark)
  static const Color bone = Color(0xFFF5F7FA);
  static const Color mist = Color(0xFFB7C0CC);
  static const Color fog = Color(0xFF7C8696);
  static const Color smoke = Color(0xFF4A5160);

  // Accents
  static const Color pulse = Color(0xFF00E5A0); // signature green, motion
  static const Color ember = Color(0xFFFF7548); // race day, urgency
  static const Color signal = Color(0xFF4D9CFF); // info, links
  static const Color warn = Color(0xFFFFC857); // partial / caution
  static const Color miss = Color(0xFFFF4D6D); // missed / failure
}
