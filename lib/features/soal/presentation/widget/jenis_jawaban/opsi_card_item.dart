import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../../core/config/theme.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/html/custom_html_widget.dart';
import '../../../../../core/shared/widget/html/widget_from_html.dart';

class OpsiCardItem extends StatelessWidget {
  final bool isEnabled;
  final bool isSelected;
  final bool isLastItem;
  final bool isKunciJawaban;
  final bool isBolehLihatKunci;
  final Widget opsiLabel;
  final String opsiText;
  final VoidCallback? onTap;

  const OpsiCardItem(
      {Key? key,
      required this.opsiLabel,
      required this.opsiText,
      this.isEnabled = true,
      this.isSelected = false,
      this.isLastItem = false,
      this.onTap,
      this.isKunciJawaban = false,
      required this.isBolehLihatKunci})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? context.primaryColor
          : isEnabled
              ? context.background
              : context.disableColor,
      surfaceTintColor: context.primaryColor,
      margin: EdgeInsets.only(
        bottom: isLastItem ? min(26, context.dp(20)) : min(20, context.dp(16)),
      ),
      elevation: isEnabled ? 5 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(min(24, context.dp(12))),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(min(24, context.dp(12))),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            right: min(18, context.dp(12)),
            left: min(14, context.dp(8)),
            top: min(12, context.dp(8)),
            bottom: min(12, context.dp(8)),
          ),
          child: Row(
            children: [
              Container(
                width: min(64, context.dp(36)),
                height: min(64, context.dp(36)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: isSelected
                          ? context.onPrimary
                          : isEnabled
                              ? context.primaryColor
                              : context.background),
                  borderRadius: BorderRadius.circular(min(16, context.dp(8))),
                ),
                child: opsiLabel,
              ),
              SizedBox(width: min(10, context.dp(8))),
              Expanded(
                child: (opsiText.contains('table'))
                    ? WidgetFromHtml(
                        htmlString: opsiText,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      )
                    : CustomHtml(
                        htmlString: opsiText,
                        replaceStyle: {
                          'body': Style(
                              color: isSelected
                                  ? context.onPrimary
                                  : isEnabled
                                      ? context.onBackground
                                      : context.background),
                          'p': Style(
                              color: isSelected
                                  ? context.onPrimary
                                  : isEnabled
                                      ? context.onBackground
                                      : context.background)
                        },
                      ),
              ),
              if (!isEnabled && isBolehLihatKunci)
                Icon(
                  (isSelected && isKunciJawaban)
                      ? Icons.check_circle_rounded
                      : (isKunciJawaban)
                          ? Icons.check_circle_outline_rounded
                          : Icons.highlight_off_rounded,
                  color: (isSelected && isKunciJawaban)
                      ? Palette.kSuccessSwatch[300]
                      : (isKunciJawaban)
                          ? Palette.kSuccessSwatch[700]
                          : isSelected
                              ? context.onPrimary
                              : context.hintColor,
                ),
              SizedBox(
                width: (context.isMobile) ? context.dp(4) : 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
