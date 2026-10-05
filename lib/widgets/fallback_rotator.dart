import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// 2D stand-in for the 3D viewer. Shows a local image and fakes a turntable
/// rotation on horizontal drag using a perspective [Matrix4]. The rotation is
/// clamped to ±[maxYaw] and springs back to [targetYaw] on release.
class FallbackRotator extends StatefulWidget {
  const FallbackRotator({
    super.key,
    required this.image,
    this.targetYaw = 0,
    this.targetPitch = 0,
    this.tilt = 0.2,
    this.maxYaw = 35 * math.pi / 180,
    this.onDragStart,
  });

  /// Asset path of the placeholder product image.
  final String image;

  /// Resting rotation around the Y axis (radians). Changing it animates.
  final double targetYaw;

  /// Resting rotation around the X axis (radians). Changing it animates.
  final double targetPitch;

  /// Constant in-plane tilt (radians) so the product looks like it floats.
  final double tilt;

  /// Maximum absolute yaw reachable by dragging (radians).
  final double maxYaw;

  final VoidCallback? onDragStart;

  @override
  State<FallbackRotator> createState() => _FallbackRotatorState();
}

class _FallbackRotatorState extends State<FallbackRotator>
    with TickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 14,
  );

  late final AnimationController _yaw = AnimationController.unbounded(
    vsync: this,
    value: widget.targetYaw,
  );
  late final AnimationController _pitch = AnimationController.unbounded(
    vsync: this,
    value: widget.targetPitch,
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void didUpdateWidget(FallbackRotator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetYaw != widget.targetYaw) {
      _springTo(_yaw, widget.targetYaw);
    }
    if (oldWidget.targetPitch != widget.targetPitch) {
      _springTo(_pitch, widget.targetPitch);
    }
  }

  @override
  void dispose() {
    _yaw.dispose();
    _pitch.dispose();
    _float.dispose();
    super.dispose();
  }

  void _springTo(AnimationController c, double target, [double velocity = 0]) {
    c.animateWith(SpringSimulation(_spring, c.value, target, velocity));
  }

  void _onDragStart(DragStartDetails _) {
    _yaw.stop();
    widget.onDragStart?.call();
  }

  void _onDragUpdate(DragUpdateDetails d, double width) {
    // A full-width drag is roughly 90° of rotation.
    final delta = d.delta.dx / width * (math.pi / 2);
    _yaw.value = (_yaw.value + delta).clamp(-widget.maxYaw, widget.maxYaw);
  }

  void _onDragEnd(DragEndDetails d, double width) {
    final velocity = d.velocity.pixelsPerSecond.dx / width * (math.pi / 2);
    _springTo(_yaw, widget.targetYaw, velocity);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, 1.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
          onHorizontalDragEnd: (d) => _onDragEnd(d, width),
          child: AnimatedBuilder(
            animation: Listenable.merge([_yaw, _pitch, _float]),
            builder: (context, child) {
              final bob = Curves.easeInOut.transform(_float.value) * 8 - 4;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.0012) // perspective
                ..translateByDouble(0, bob, 0, 1)
                ..rotateX(_pitch.value)
                ..rotateY(_yaw.value)
                ..rotateZ(widget.tilt);
              return Transform(
                alignment: Alignment.center,
                transform: transform,
                child: child,
              );
            },
            child: Image.asset(
              widget.image,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stack) => const Center(
                child: Icon(
                  Icons.directions_run_rounded,
                  size: 96,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
