import 'package:flutter/material.dart';

import '../widget/appbar/custom_app_bar.dart';
import '../../../core/config/extensions.dart';

class BasicScreenFlat extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget? body;
  final int jumlahBarisTitle;

  const BasicScreenFlat({
    Key? key,
    required this.title,
    this.subTitle,
    this.body,
    this.jumlahBarisTitle = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryColor,
      appBar: _buildAppBar(context),
      body: Container(
        width: context.dw,
        height: double.infinity,
        color: context.onPrimary,
        child: body,
      ),
    );
  }

  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      context,
      title: (jumlahBarisTitle == 1)
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.fade,
            )
          : RichText(
              textScaleFactor: context.textScale12,
              text: TextSpan(
                  text: '$title\n',
                  style: context.text.titleMedium
                      ?.copyWith(color: context.onPrimary),
                  children: [
                    TextSpan(
                        text: subTitle,
                        style: context.text.labelSmall
                            ?.copyWith(color: context.onPrimary)),
                  ]),
            ),
    );
  }
}
