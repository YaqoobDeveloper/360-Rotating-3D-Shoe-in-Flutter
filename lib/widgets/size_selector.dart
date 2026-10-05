import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/sneaker_theme.dart';

/// Horizontally scrollable size pills. Selected = solid green, white text.
class SizeSelector extends StatelessWidget {
  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selected,
    required this.onSelected,
    this.accent = const Color(0xFF3A8F4B),
    this.padding = EdgeInsets.zero,
  });

  final List<String> sizes;
  final String? selected;
  final ValueChanged<String> onSelected;
  final Color accent;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return SizedBox(
      height: textScaler.scale(14) + 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: sizes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final size = sizes[index];
          return _SizeChip(
            label: size,
            selected: size == selected,
            accent: accent,
            onTap: () => onSelected(size),
          );
        },
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(100);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.96,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minWidth: 72),
          decoration: BoxDecoration(
            color: selected ? accent : Colors.white,
            borderRadius: radius,
            border: Border.all(
              color: selected ? accent : const Color(0xFFE6E6E6),
              width: 1.2,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  widthFactor: 1,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 240),
                    style: jakarta(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.white : const Color(0xFF9A9A9A),
                    ),
                    child: Text(label),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with a simple US / UK / EU / CM conversion table.
Future<void> showSizeChartSheet(
  BuildContext context, {
  Color accent = const Color(0xFF3A8F4B),
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final header = kSizeChart.first;
      final rows = kSizeChart.skip(1).toList();
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Size chart',
                style: jakarta(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Men's sizes. Measure your foot from heel to longest toe.",
                style: jakarta(fontSize: 12, color: kTextMuted),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: Color(0xFFEDEDED)),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                      ),
                      children: [
                        for (final cell in header)
                          _cell(
                            cell,
                            jakarta(
                              fontSize: 14,
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    for (var i = 0; i < rows.length; i++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: i.isOdd
                              ? const Color(0xFFF7F7F7)
                              : Colors.white,
                        ),
                        children: [
                          for (final cell in rows[i])
                            _cell(
                              cell,
                              jakarta(fontSize: 14, color: kTextDark),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _cell(String text, TextStyle style) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  child: Text(text, textAlign: TextAlign.center, style: style),
);
