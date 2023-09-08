import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';

class PromoHomeWidget extends StatelessWidget {
  const PromoHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 342 / 176,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(18)) : context.dp(12)),
        child: CustomImageNetwork(
          'https://ganeshaoperation.com/img/tumbnail5.png',
          width: double.infinity,
          borderRadius: BorderRadius.circular(
              (context.isMobile) ? max(12, context.dp(18)) : context.dp(12)),
        ),
      ),
    );
  }
}
