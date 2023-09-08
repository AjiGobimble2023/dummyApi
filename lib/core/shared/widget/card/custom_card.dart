import 'package:flutter/material.dart';
import '../../../config/extensions.dart';

class CustomCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final double elevation;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const CustomCard({
    Key? key,
    this.onTap,
    this.onLongPress,
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ??
            BorderRadius.circular(
                (context.isMobile) ? context.dp(12) : context.dp(8)),
      ),
      margin: margin,
      color: backgroundColor ?? context.background,
      surfaceTintColor: context.background,
      child: (onTap == null && onLongPress == null)
          ? Padding(
              padding: padding,
              child: child,
            )
          : InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: borderRadius ??
                  BorderRadius.circular(
                      (context.isMobile) ? context.dp(11) : context.dp(9)),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
    );
  }
}
