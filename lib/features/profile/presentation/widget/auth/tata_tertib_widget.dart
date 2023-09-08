import 'dart:async';
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../../../../core/shared/widget/html/custom_html_widget.dart';
import '../../provider/profile_provider.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/html/widget_from_html.dart';

class TataTertibWidget extends StatelessWidget {
  final String noRegistrasi;
  final String tipeUser;

  const TataTertibWidget({
    Key? key,
    required this.noRegistrasi,
    required this.tipeUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final navigator = Navigator.of(context);
    final ScrollController scrollController = ScrollController();

    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaleFactor: context.textScale11),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8,
        radius: const Radius.circular(14),
        child: ListView(
          shrinkWrap: true,
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: min(28, context.dp(24))),
          children: [
            Selector<ProfileProvider, String?>(
              selector: (_, data) => data.aturanHtml,
              shouldRebuild: (prev, next) => prev != next,
              builder: (_, aturanSiswa, __) =>
                  (aturanSiswa ?? Constant.defaultAturan).contains('table')
                      ? WidgetFromHtml(
                          htmlString: aturanSiswa ?? Constant.defaultAturan,
                        )
                      : CustomHtml(
                          htmlString: aturanSiswa ?? Constant.defaultAturan,
                          replaceStyle: {
                            'body': Style(
                              padding: HtmlPaddings.only(
                                left: min(18, context.dp(14)),
                                right: min(32, context.dp(28)),
                              ),
                            ),
                            'li': Style(
                                textAlign: TextAlign.justify,
                                lineHeight: const LineHeight(1.8)),
                          },
                        ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: min(28, context.dp(24)),
                  right: min(28, context.dp(24)),
                  bottom: min(28, context.dp(24))),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    var completer = Completer();
                    context.showBlockDialog(dismissCompleter: completer);

                    bool isSudahMenyetujui = await context
                        .read<ProfileProvider>()
                        .simpanAturanSiswa(
                            noRegistrasi: noRegistrasi, tipeUser: tipeUser);

                    if (isSudahMenyetujui) {
                      completer.complete();
                      await Future.delayed(const Duration(milliseconds: 300));
                      navigator.pop(isSudahMenyetujui);
                    }
                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24)),
                  child: const Text(
                    'Saya Setuju\ndengan peraturan ini',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
