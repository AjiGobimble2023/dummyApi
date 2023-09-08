import 'package:flutter/material.dart';

import '../../config/extensions.dart';
import '../widget/image/custom_image_network.dart';

class PageNotFound extends StatelessWidget {
  final String route;
  const PageNotFound({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imgWidth =
        (context.dh.round() <= 683) ? context.dp(200) : context.dp(296.0);
    final imgHeight =
        (context.dh.round() <= 683) ? context.dp(250) : context.dp(369);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: context.dp(30)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryColor,
              context.secondaryColor,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.36, 0.8],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            CustomImageNetwork(
              'ilustrasi_sosial_leaderboard_not_found.png'.illustration,
              width: imgWidth,
              height: imgHeight,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: EdgeInsets.only(top: context.dp(24)),
              child: Text(
                '404',
                style: context.text.displayLarge?.copyWith(
                    color: context.onPrimary, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: context.dp(12)),
              child: FittedBox(
                fit: BoxFit.contain,
                child: RichText(
                  text: TextSpan(
                      text: 'Oops! Sepertinya kamu tersesat Sobat\n',
                      style: context.text.titleMedium
                          ?.copyWith(color: context.onPrimary),
                      children: [
                        TextSpan(
                            text: 'Route \'$route\' tidak terdaftar',
                            style: context.text.bodyMedium?.copyWith(
                                color: context.onPrimary.withOpacity(0.54))),
                      ]),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  textScaleFactor: context.textScale12,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '< Kembali Ke GO Kreasi',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.onPrimary.withOpacity(0.54)),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
