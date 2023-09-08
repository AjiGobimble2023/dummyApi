import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';

enum PusatBantuan {
  kebijakanPrivasi,
  faq,
  syaratKetentuan,
  refundPolicy,
  hubungiKami
}

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<PusatBantuan, String> menuBantuan = {
      PusatBantuan.kebijakanPrivasi: 'Kebijakan Privasi',
      PusatBantuan.faq: 'Frequently Asked Question',
      PusatBantuan.syaratKetentuan: 'Syarat dan Ketentuan',
      PusatBantuan.refundPolicy: 'Refund Policy',
      PusatBantuan.hubungiKami: 'Hubungi Kami',
    };

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: context.textScale11),
      child: Scaffold(
        backgroundColor: context.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            Theme(
              data: context.themeData.copyWith(
                colorScheme: context.colorScheme.copyWith(
                  onSurface: context.onBackground,
                  onSurfaceVariant: context.onBackground,
                  onPrimary: context.onBackground,
                  surface: context.background,
                  primary: context.background,
                  // surfaceTint: context.background,
                  // surfaceVariant: context.background
                ),
              ),
              child: SliverAppBar.medium(
                stretch: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: const Text('Pusat Bantuan'),
                leading: IconButton(
                  padding: EdgeInsets.only(
                    left: min(28, context.dp(24)),
                    right: min(16, context.dp(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: context.onBackground,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(menuBantuan.entries
                  .map<Widget>(
                    (menu) => ListTile(
                      dense: true,
                      title: Text(menu.value),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          _navigateToWebView(context, menu.key, menu.value),
                    ),
                  )
                  .toList()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToWebView(
      BuildContext context, PusatBantuan menu, String title) {
    String url = 'https://ganeshaoperation.com';

    switch (menu) {
      case PusatBantuan.hubungiKami:
        url += '/kontak.html';
        break;
      case PusatBantuan.refundPolicy:
        url += '/refund1.html';
        break;
      case PusatBantuan.syaratKetentuan:
        url += '/term1.html';
        break;
      case PusatBantuan.kebijakanPrivasi:
        url += '/privacy1.html';
        break;
      default:
        url += '/faq.html';
        break;
    }

    Navigator.pushNamed(context, Constant.kRouteBantuanWebViewScreen,
        arguments: {'title': title, 'url': url});
  }
}
