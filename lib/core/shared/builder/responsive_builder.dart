import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    required this.tablet,
    this.desktop,
  }) : super(key: key);

  // Di pindahkan ke extension
  // static bool isMobile(BuildContext context) => context.dw < 650;
  // static bool isTablet(BuildContext context) => context.dw >= 650;
  // static bool isDesktop(BuildContext context) => context.dw >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        if (constraint.maxWidth >= 1100) {
          return desktop ?? tablet;
        }
        if (constraint.maxWidth >= 600) {
          return tablet;
        }
        return mobile;
      },
    );
  }
}
