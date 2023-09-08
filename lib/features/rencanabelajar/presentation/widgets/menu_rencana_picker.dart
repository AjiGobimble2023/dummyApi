import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../model/rencana_menu.dart';
import '../../../../core/config/extensions.dart';

class MenuRencanaPicker extends StatelessWidget {
  final int selectedIndex;
  final List<RencanaMenu> daftarMenuRencana;

  const MenuRencanaPicker({
    super.key,
    required this.selectedIndex,
    required this.daftarMenuRencana,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: context.dh * 0.5,
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: ScrollablePositionedList.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  initialScrollIndex: selectedIndex,
                  itemCount: daftarMenuRencana.length,
                  initialAlignment: 0.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  itemBuilder: (context, index) => (index == selectedIndex)
                      ? Hero(
                          tag: 'selected_menu_label',
                          transitionOnUserGestures: true,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: context.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildButtonMenu(context, index),
                          ),
                        )
                      : _buildButtonMenu(context, index),
                  separatorBuilder: (_, __) => const Divider(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSelectedIndex(BuildContext context, int selectedIndex) {
    if (kDebugMode) {
      logger.log('MENU_RENCANA_PICKER: Pop '
          'selected menu index >> $selectedIndex');
    }
    Navigator.of(context).pop(selectedIndex);
  }

  Widget _buildButtonMenu(BuildContext context, int index) => Material(
        elevation: 0,
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _onSelectedIndex(context, index),
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                daftarMenuRencana[index].label.toUpperCase(),
                style: context.text.bodyMedium,
              ),
            ),
          ),
        ),
      );

  Row _buildHeader(BuildContext context) {
    return Row(
      children: [
        Hero(
          tag: 'icon_rencana_menu',
          transitionOnUserGestures: true,
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: EdgeInsets.only(
              top: context.dp(14),
              left: context.dp(14),
              right: context.dp(12),
              bottom: context.dp(8),
            ),
            decoration: BoxDecoration(
              color: context.secondaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(-1, -1),
                    blurRadius: 4,
                    spreadRadius: 1,
                    color: context.secondaryColor.withOpacity(0.42)),
                BoxShadow(
                    offset: const Offset(1, 1),
                    blurRadius: 4,
                    spreadRadius: 1,
                    color: context.secondaryColor.withOpacity(0.42))
              ],
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 26,
              color: context.onSecondary,
              semanticLabel: 'ic_date_range_rencana',
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Hero(
                tag: 'rencana_belajar_menu_title',
                transitionOnUserGestures: true,
                child: Text(
                  'Mau belajar apa Sobat?',
                  style: context.text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 12, endIndent: 24),
            ],
          ),
        ),
      ],
    );
  }
}
