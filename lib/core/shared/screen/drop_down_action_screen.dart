import 'package:flutter/material.dart';

import '../builder/responsive_builder.dart';
import '../widget/navbar/side_bar_menu.dart';
import '../widget/appbar/custom_app_bar.dart';
import '../widget/watermark/watermark_widget.dart';
import '../../../core/config/extensions.dart';
import '../../../features/menu/entity/menu.dart';

class DropDownActionScreen extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget? body;
  final Menu selectedItem;
  final List<Menu> dropDownItems;
  final ValueChanged<Menu?> onChanged;
  final bool isWatermarked;
  final Widget? floatingActionButton;

  const DropDownActionScreen({
    Key? key,
    required this.title,
    this.subTitle,
    this.body,
    required this.dropDownItems,
    required this.onChanged,
    required this.selectedItem,
    this.isWatermarked = true,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          (context.isMobile) ? context.primaryColor : context.background,
      appBar: (context.isMobile) ? _buildAppBar(context) : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: ResponsiveBuilder(
        mobile: Container(
          width: context.dw,
          height: double.infinity,
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: _buildBodyWidget(context),
          ),
        ),
        tablet: Row(
          children: [
            Container(
              width: context.dp(132),
              color: context.primaryColor,
              padding: EdgeInsets.only(
                  top: context.h(24),
                  left: context.h(24),
                  right: context.h(24),
                  bottom: context.h(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: context.onPrimary,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      _buildTitleAppBar(context)
                    ],
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: context.dp(6),
                        vertical: context.h(14),
                      ),
                      decoration: BoxDecoration(
                        color: context.background,
                        borderRadius: BorderRadius.circular(context.dp(12)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.dp(12)),
                        child: SideBarMenu(
                          onIndexChange: onChanged,
                          selectedMenu: selectedItem,
                          listMenu: dropDownItems,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildBodyWidget(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyWidget(BuildContext context) {
    return isWatermarked
        ? WatermarkWidget(
            child: body ??
                Center(
                  child: Text(selectedItem.toString()),
                ),
          )
        : body ??
            Center(
              child: Text(selectedItem.toString()),
            );
  }

  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      context,
      toolbarHeight: context.dp(72),
      actions: [_buildDropDown(context)],
      centerTitle: false,
      title: _buildTitleAppBar(context),
    );
  }

  Widget _buildTitleAppBar(BuildContext context) {
    Widget titleWidget = Text(
      '$title\n',
      style: context.text.titleMedium?.copyWith(color: context.onPrimary),
      maxLines: 1,
      overflow: TextOverflow.fade,
    );
    return (subTitle == null)
        ? titleWidget
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              Text(
                subTitle!,
                style:
                    context.text.labelSmall?.copyWith(color: context.onPrimary),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ],
          );
  }

  Container _buildDropDown(BuildContext context) {
    return Container(
      width: context.dp(140),
      margin: EdgeInsets.only(
        top: context.dp(16),
        bottom: context.dp(16),
        right: context.dp(24),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: (context.isMobile)
            ? BorderRadius.circular(10)
            : BorderRadius.circular(20),
      ),
      child: DropdownButton<Menu>(
        value: selectedItem,
        items: dropDownItems.map<DropdownMenuItem<Menu>>((items) {
          return DropdownMenuItem<Menu>(
            value: items,
            child: Text(items.label),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        borderRadius: BorderRadius.circular(12),
        style: context.text.bodyMedium?.copyWith(overflow: TextOverflow.fade),
      ),
    );
  }
}
