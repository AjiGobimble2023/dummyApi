import 'package:flutter/material.dart';

import '../widget/appbar/custom_app_bar.dart';
import '../../../core/config/extensions.dart';

class BasicScreen extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget? body;
  final int jumlahBarisTitle;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final Widget? bottomNavigationBar;
  final bool? logo;
  final List<Widget>? actions;
  final VoidCallback? onWillPop;

  const BasicScreen(
      {Key? key,
      required this.title,
      this.subTitle,
      this.body,
      this.jumlahBarisTitle = 1,
      this.floatingActionButton,
      this.logo,
      this.bottomSheet,
      this.bottomNavigationBar,
      this.onWillPop,
      this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryColor,
      appBar: _buildAppBar(context),
      body: Container(
        width: context.dw,
        height: double.infinity,
        decoration: BoxDecoration(
            color: context.background,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24))),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: body,
        ),
      ),
      extendBody: true,
      bottomSheet: bottomSheet,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      context,
      onWillPop: onWillPop,
      actions: actions,
      centerTitle: !context.isMobile && context.isLandscape,
      title: (logo ?? false)
          ? Container(
              alignment: Alignment.center,
              child: Image.asset('assets/img/logo_inverse.webp',
                  height: context.dp(48), fit: BoxFit.fitHeight),
            )
          : (jumlahBarisTitle == 1)
              ? Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: (context.isMobile)
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: context.text.titleMedium
                          ?.copyWith(color: context.onPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    if (subTitle != null)
                      Text(
                        subTitle!,
                        style: context.text.labelSmall
                            ?.copyWith(color: context.onPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                  ],
                ),
    );
  }
}
