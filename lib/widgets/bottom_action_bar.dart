import 'package:flutter/material.dart';

import '../theme/sneaker_theme.dart';

/// Fixed bar with chat, "Add to Cart" and "Buy Now". The two purchase
/// buttons are disabled until [enabled] is true; tapping them while disabled
/// calls [onDisabledTap] so the screen can explain why.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.enabled,
    required this.onChat,
    required this.onAddToCart,
    required this.onBuyNow,
    this.onDisabledTap,
    this.accent = const Color(0xFF3A8F4B),
  });

  final bool enabled;
  final VoidCallback onChat;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback? onDisabledTap;
  final Color accent;

  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    final textStyle = jakarta(fontSize: 15, fontWeight: FontWeight.w600);
    const disabledColor = Color(0xFFBDBDBD);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              SizedBox.square(
                dimension: _height,
                child: OutlinedButton(
                  onPressed: onChat,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    foregroundColor: accent,
                    side: BorderSide(color: accent, width: 1.4),
                  ),
                  child: const Icon(Icons.sms_outlined, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DisabledTapCatcher(
                  enabled: enabled,
                  onDisabledTap: onDisabledTap,
                  child: SizedBox(
                    height: _height,
                    child: OutlinedButton.icon(
                      onPressed: enabled ? onAddToCart : null,
                      icon: const Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 20,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Add to Cart', style: textStyle),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: accent,
                        disabledForegroundColor: disabledColor,
                        side: BorderSide(
                          color: enabled ? accent : const Color(0xFFE0E0E0),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DisabledTapCatcher(
                  enabled: enabled,
                  onDisabledTap: onDisabledTap,
                  child: SizedBox(
                    height: _height,
                    child: FilledButton(
                      onPressed: enabled ? onBuyNow : null,
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE6E6E6),
                        disabledForegroundColor: const Color(0xFF9E9E9E),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Buy Now', style: textStyle),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A disabled button ignores taps, so the user gets no feedback. This
/// catches those taps and reports them via [onDisabledTap].
class _DisabledTapCatcher extends StatelessWidget {
  const _DisabledTapCatcher({
    required this.enabled,
    required this.onDisabledTap,
    required this.child,
  });

  final bool enabled;
  final VoidCallback? onDisabledTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (enabled || onDisabledTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDisabledTap,
      child: child,
    );
  }
}
