import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Geometry of the orbit ellipse, shared by the painter and by widgets
/// that need to sit on the line (e.g. the drag-hint pill).
class OrbitGeometry {
  const OrbitGeometry._(this.rect);

  factory OrbitGeometry.of(Size size) {
    final width = size.width * 0.86;
    final height = (size.height * 0.11).clamp(28.0, 56.0);
    final center = Offset(size.width / 2, size.height * 0.80);
    return OrbitGeometry._(
      Rect.fromCenter(center: center, width: width, height: height),
    );
  }

  final Rect rect;

  Offset get bottomCenter => rect.bottomCenter;
}

/// Thin elliptical "turntable" line under the product, darker at the front
/// and fading towards the back, plus an optional soft contact shadow.
class OrbitPainter extends CustomPainter {
  const OrbitPainter({
    this.color = const Color(0xFF1C1C1E),
    this.strokeWidth = 1.2,
    this.drawShadow = false,
  });

  final Color color;
  final double strokeWidth;

  /// The 3D viewer renders its own shadow; the 2D fallback asks for this one.
  final bool drawShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = OrbitGeometry.of(size).rect;

    if (drawShadow) {
      final shadowRect = Rect.fromCenter(
        center: rect.center.translate(0, -rect.height * 0.15),
        width: rect.width * 0.55,
        height: rect.height * 0.55,
      );
      canvas.drawOval(
        shadowRect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // Back half: faint. Front half: stronger, so the ring reads as 3D.
    final back = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: 0.22);
    final front = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.85),
          color.withValues(alpha: 0.25),
        ],
      ).createShader(rect);

    canvas.drawArc(rect, math.pi, math.pi, false, back);
    canvas.drawArc(rect, 0, math.pi, false, front);
  }

  @override
  bool shouldRepaint(OrbitPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.drawShadow != drawShadow;
}
