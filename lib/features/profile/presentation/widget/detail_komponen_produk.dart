import 'dart:math';

import 'package:flutter/material.dart';

import '../../../auth/model/produk_dibeli_model.dart';
import '../../../../core/config/extensions.dart';

class DetailKomponenProduk extends StatelessWidget {
  final String jenisProduk;
  final String namaBundling;
  final List<ProdukDibeli> daftarKomponenProduk;

  const DetailKomponenProduk({
    Key? key,
    required this.jenisProduk,
    required this.namaBundling,
    required this.daftarKomponenProduk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    // daftarKomponenProduk.sort((a, b) => a.namaProduk.compareTo(b.namaProduk));

    return Padding(
      padding: EdgeInsets.only(
        bottom: min(22, context.dp(16)),
        left: min(20, context.dp(14)),
        right: min(26, context.dp(18)),
      ),
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
          children: [
            Container(
              width: double.infinity,
              height: 6,
              margin: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: context.dw * 0.34,
              ),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(32)),
            ),
            SizedBox(height: min(16, context.dp(8))),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.graphic_eq_rounded,
                  color: context.tertiaryColor,
                  size: min(32, context.dp(32)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    textScaleFactor: context.textScale12,
                    text: TextSpan(
                        text: '$jenisProduk\n',
                        style: context.text.titleMedium,
                        children: [
                          TextSpan(
                              text: '~$namaBundling',
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.hintColor))
                        ]),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black54, height: 20),
            ...List<Widget>.generate(
              daftarKomponenProduk.length,
              (index) => Container(
                constraints: BoxConstraints(
                    minWidth: double.infinity,
                    maxWidth: double.infinity,
                    minHeight: min(42, context.dp(38)),
                    maxHeight: min(64, context.dp(60))),
                margin: EdgeInsets.only(left: min(24, context.dp(18))),
                padding: EdgeInsets.only(
                    top: min(14, context.dp(8)),
                    right: min(24, context.dp(18)),
                    bottom: min(14, context.dp(8))),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black26, width: 0.5),
                  ),
                ),
                child: Text(
                  '${index + 1}. '
                  '${daftarKomponenProduk[index].namaProduk} '
                  '${(daftarKomponenProduk[index].isExpired) ? '(kedaluwarsa)' : ''}',
                  style: context.text.bodySmall?.copyWith(
                      color: (daftarKomponenProduk[index].isExpired)
                          ? context.primaryColor
                          : context.onBackground,
                      fontWeight: (daftarKomponenProduk[index].isExpired)
                          ? FontWeight.w500
                          : FontWeight.w400),
                  semanticsLabel:
                      'Produk ${daftarKomponenProduk[index].idKomponenProduk}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
