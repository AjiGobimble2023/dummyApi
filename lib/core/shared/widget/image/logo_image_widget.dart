import 'package:flutter/material.dart';

class LogoImageWidget extends StatelessWidget {
  final double? height;
  final double? width;

  const LogoImageWidget({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/logo.webp',
      height: height,
      width: width,
    );
  }
}
