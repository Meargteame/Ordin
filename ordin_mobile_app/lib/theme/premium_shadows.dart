import 'package:flutter/material.dart';

/// Premium shadow system for elevation and depth
/// Provides subtle, sophisticated shadows for premium feel
class PremiumShadows {
  // Elevation Low (Cards at rest, subtle depth)
  static List<BoxShadow> elevationLow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // Elevation Medium (Interactive cards, hover states)
  static List<BoxShadow> elevationMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Elevation High (Modals, floating elements)
  static List<BoxShadow> elevationHigh = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  // Elevation Extra High (Dialogs, overlays)
  static List<BoxShadow> elevationExtraHigh = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // Colored shadows for premium effect (used with brand colors)
  static List<BoxShadow> coloredShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  // Dark mode shadows (lighter, more subtle)
  static List<BoxShadow> darkElevationLow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> darkElevationMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> darkElevationHigh = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];

  // Inner shadows (for pressed states)
  static List<BoxShadow> innerShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
}
