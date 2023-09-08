import 'package:flutter/material.dart';

import '../../../config/theme.dart';

class ComparisonBar extends StatelessWidget {
  /// Label sebelah kiri
  final Widget prefixLabel;

  /// Label sebelah kanan
  final Widget suffixLabel;

  /// Value sebelah kiri
  final double prefixValue;

  /// Value sebelah kanan
  final double suffixValue;

  /// Spacing antara label dan progress bar
  final double labelSpacing;

  final double? size;

  const ComparisonBar({
    super.key,
    required this.prefixLabel,
    required this.suffixLabel,
    required this.prefixValue,
    required this.suffixValue,
    required this.labelSpacing,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = prefixValue + suffixValue;

    return LayoutBuilder(
      builder: (ctx, constraints) => Row(
        children: [
          prefixLabel,
          SizedBox(width: labelSpacing),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: SizedBox(
                height: size ?? 14,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor:
                            (maxValue == 0) ? 0.0 : prefixValue / maxValue,
                        child: Container(
                          height: size ?? 14,
                          color: Palette.kSuccessSwatch[400],
                          child: (prefixValue > 0)
                              ? FittedBox(
                                  child: Text(
                                    '${((prefixValue / maxValue) * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor:
                            (maxValue == 0) ? 0.0 : suffixValue / maxValue,
                        child: Container(
                          height: size ?? 14,
                          color: Palette.kPrimarySwatch[400],
                          child: (suffixValue > 0)
                              ? FittedBox(
                                  child: Text(
                                    '${((suffixValue / maxValue) * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: labelSpacing),
          suffixLabel
        ],
      ),
    );
  }
}
