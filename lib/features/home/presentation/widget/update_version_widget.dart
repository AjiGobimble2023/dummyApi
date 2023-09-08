import 'dart:io';
import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/data_provider.dart';
import '../../model/update_version.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';

class UpdateVersionWidget extends StatelessWidget {
  const UpdateVersionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.read<DataProvider>();
    final UpdateVersion? updateVersion =
        context.read<DataProvider>().updateVersion;

    if (updateVersion == null) {
      Future.delayed(gDelayedNavigation)
          .then((value) => Navigator.pop(context));
    }

    return Stack(
      children: [
        Align(
          alignment:
              (context.isMobile) ? Alignment.bottomCenter : Alignment.center,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: (context.isMobile) ? 640 : 370,
            ),
            padding: EdgeInsets.only(
              top: min(46, context.dp(32)),
              left: min(36, context.dp(24)),
              right: min(36, context.dp(24)),
              bottom: context.dp(12) + min(20, context.bottomBarHeight),
            ),
            margin: (context.isMobile)
                ? const EdgeInsets.only(top: 90)
                : const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: (context.isMobile)
                  ? const BorderRadius.vertical(top: Radius.circular(34))
                  : BorderRadius.circular(34),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    '${updateVersion?.title}',
                    style: context.text.titleLarge,
                  ),
                ),
                Divider(height: min(32, context.dp(18))),
                Text(
                  '${updateVersion?.description}',
                  style: context.text.bodyMedium?.copyWith(
                    fontSize: (context.isMobile) ? 14 : 10,
                    color: context.onBackground.withOpacity(0.64),
                  ),
                ),
                const Spacer(),
                Divider(height: min(36, context.dp(20))),
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Versi sekarang: ${dataProvider.currentVersion}\n'
                          'Tersedia versi: ${dataProvider.versionAvailable}',
                          style: context.text.bodySmall?.copyWith(
                            fontSize: (context.isMobile) ? 12 : 9,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: min(26, max(14, context.dp(14)))),
                    if (!(updateVersion?.isWajib ?? false))
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          textStyle: (context.isMobile)
                              ? null
                              : context.text.labelSmall,
                          padding: EdgeInsets.symmetric(
                            vertical: min(14, max(12, context.dp(8))),
                            horizontal: min(22, max(16, context.dp(14))),
                          ),
                        ),
                        child: const Text('Nanti saja'),
                      ),
                    if (!(updateVersion?.isWajib ?? false))
                      SizedBox(width: min(12, max(8, context.dp(8)))),
                    ElevatedButton(
                      onPressed: () async => await _updateApp(context),
                      style: ElevatedButton.styleFrom(
                        textStyle:
                            (context.isMobile) ? null : context.text.labelSmall,
                        padding: EdgeInsets.symmetric(
                          vertical: min(14, max(12, context.dp(8))),
                          horizontal: min(22, max(16, context.dp(14))),
                        ),
                      ),
                      child: Text((updateVersion?.isWajib ?? false)
                          ? 'Update GO Kreasi'
                          : 'Update'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Align(
          alignment:
              (context.isMobile) ? Alignment.topCenter : Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: (context.isMobile) ? 640 : 540,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: CustomImageNetwork(
                'ilustrasi_min_go.png'.illustration,
                width: min(160, context.dp(140)),
                height: min(160, context.dp(140)),
                borderRadius: gDefaultShimmerBorderRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateApp(BuildContext context) async {
    try {
      final dataProvider = context.read<DataProvider>();
      if (Platform.isAndroid || Platform.isIOS) {
        final url = Uri.parse(
          Platform.isAndroid
              ? dataProvider.updateVersion!.android.url
              : dataProvider.updateVersion!.ios.url,
        );

        final altUrl = Uri.parse(
          Platform.isAndroid
              ? dataProvider.updateVersion!.android.altUrl
              : dataProvider.updateVersion!.ios.altUrl,
        );

        bool canLaunch = await canLaunchUrl(url);

        if (canLaunch) {
          launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          canLaunch = await canLaunchUrl(altUrl);

          if (canLaunch) {
            launchUrl(
              altUrl,
              mode: LaunchMode.externalApplication,
            );
          } else {
            if (kDebugMode) {
              logger.log('UPDATE_VERSION_WIDGET-UpdateApp: Cannot Launch URL');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('UPDATE_VERSION_WIDGET-UpdateApp: Error >> $e');
      }
    }
  }
}
