import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product.dart';

/// Row of square angle thumbnails. The selected one gets a green border.
class ThumbnailRow extends StatelessWidget {
  const ThumbnailRow({
    super.key,
    required this.angles,
    required this.selected,
    required this.image,
    required this.onSelected,
    this.accent = const Color(0xFF3A8F4B),
  });

  final List<ProductAngle> angles;
  final ProductAngle selected;

  /// Product image used to render the placeholder previews.
  final String image;
  final ValueChanged<ProductAngle> onSelected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < angles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _Thumbnail(
                angle: angles[i],
                image: image,
                selected: angles[i] == selected,
                accent: accent,
                onTap: () => onSelected(angles[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.angle,
    required this.image,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final ProductAngle angle;
  final String image;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      button: true,
      selected: selected,
      label: '${angle.label} view',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFEFEFEF),
          borderRadius: radius,
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: _ThumbnailArt(angle: angle, image: image),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder previews built from the single product image, transformed to
/// suggest each camera angle (no extra assets needed).
class _ThumbnailArt extends StatelessWidget {
  const _ThumbnailArt({required this.angle, required this.image});

  final ProductAngle angle;
  final String image;

  Widget _shoe({BoxFit fit = BoxFit.contain}) => Image.asset(
    image,
    fit: fit,
    filterQuality: FilterQuality.medium,
    errorBuilder: (context, error, stack) =>
        const Icon(Icons.image_outlined, color: Color(0xFFBDBDBD)),
  );

  Matrix4 _perspective({double x = 0, double y = 0, double z = 0}) =>
      Matrix4.identity()
        ..setEntry(3, 2, 0.004)
        ..rotateX(x)
        ..rotateY(y)
        ..rotateZ(z);

  /// Two copies of [shoe] side by side, each laid out in a box [size] times
  /// the tile so the transforms keep them readable.
  Widget _pair(Widget Function(double dir) shoe, {required double size}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final dir in [-1.0, 1.0])
          Align(
            alignment: Alignment(dir, 0),
            child: FractionallySizedBox(
              widthFactor: size,
              heightFactor: size,
              child: shoe(dir),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (angle) {
      case ProductAngle.side:
        return Transform.rotate(angle: 0.45, child: _shoe());
      case ProductAngle.frontAngle:
        return Transform(
          alignment: Alignment.center,
          transform: _perspective(y: 0.6, z: -0.05),
          child: _shoe(),
        );
      case ProductAngle.back:
        // A pair seen from behind: each shoe turned almost edge-on.
        return _pair(
          (dir) => Transform(
            alignment: Alignment.center,
            transform: _perspective(y: dir * 1.2),
            child: _shoe(),
          ),
          size: 0.75,
        );
      case ProductAngle.top:
        // A pair seen from above, toes pointing up.
        return _pair(
          (dir) => Transform.rotate(
            angle: -math.pi / 2,
            child: Transform.scale(scaleY: 0.75, child: _shoe()),
          ),
          size: 0.6,
        );
      case ProductAngle.sole:
        return const CustomPaint(painter: _SolePainter());
    }
  }
}

/// Gum outsole outline with tread lines.
class _SolePainter extends CustomPainter {
  const _SolePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final sole = Path()
      ..moveTo(w * 0.06, h * 0.52)
      ..cubicTo(w * 0.06, h * 0.36, w * 0.3, h * 0.36, w * 0.5, h * 0.40)
      ..cubicTo(w * 0.7, h * 0.43, w * 0.96, h * 0.38, w * 0.95, h * 0.52)
      ..cubicTo(w * 0.94, h * 0.64, w * 0.7, h * 0.62, w * 0.5, h * 0.60)
      ..cubicTo(w * 0.3, h * 0.58, w * 0.06, h * 0.68, w * 0.06, h * 0.52)
      ..close();
    canvas.drawShadow(sole, Colors.black, 2, false);
    canvas.drawPath(sole, Paint()..color = const Color(0xFFC68B4E));
    canvas.save();
    canvas.clipPath(sole);
    final tread = Paint()
      ..color = const Color(0xFFA9703A)
      ..strokeWidth = 1;
    for (var x = 0.0; x < w; x += w * 0.06) {
      canvas.drawLine(Offset(x, h * 0.3), Offset(x + w * 0.04, h * 0.7), tread);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SolePainter oldDelegate) => false;
}
