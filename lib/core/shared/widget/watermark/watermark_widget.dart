import 'package:flutter/material.dart';

import '../../../config/extensions.dart';

class WatermarkWidget extends StatelessWidget {
  final Widget child;
  final List<Widget>? floatingWidgets;

  const WatermarkWidget({Key? key, required this.child, this.floatingWidgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        IgnorePointer(
          child: (context.isMobile)
              ? _buildWaterMarked(context)
              : Center(
                  child: _buildWaterMarked(context),
                ),
        ),
        if (floatingWidgets?.isNotEmpty ?? false) ...floatingWidgets!
      ],
    );
  }

  Image _buildWaterMarked(BuildContext context) {
    return Image.asset(
      'assets/img/logo_kreasi.webp',
      color: context.background.withOpacity(0.1),
      colorBlendMode: BlendMode.modulate,
      height: (context.isMobile) ? double.infinity : context.dp(164),
      width: (context.isMobile) ? double.infinity : context.dp(164),
      fit: BoxFit.contain,
    );
  }
}
