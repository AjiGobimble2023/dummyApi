import 'package:flutter/material.dart';

import '../widget/appbar/custom_app_bar.dart';
import '../../../core/config/extensions.dart';

class BasicScreenProfile extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final Widget? leading;
  final Widget? trailing;

  const BasicScreenProfile(
      {Key? key,
      required this.title,
      this.subTitle,
      this.body,
      this.floatingActionButton,
      this.bottomSheet,
      this.leading,
      this.trailing})
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
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
    );
  }

  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      context,
      toolbarHeight: context.isMobile ? context.dp(72) : context.dp(24),
      title: ListTile(
        title: Text(
          '$title\n',
          style: context.text.titleMedium?.copyWith(color: context.onPrimary),
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        subtitle: (subTitle != null)
            ? Text(
                subTitle!,
                style:
                    context.text.labelSmall?.copyWith(color: context.onPrimary),
                maxLines: 1,
                overflow: TextOverflow.fade,
              )
            : Container(),
        leading: leading,
        minLeadingWidth: 0,
        trailing: trailing,
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: 5,
      ),
    );
  }
}
