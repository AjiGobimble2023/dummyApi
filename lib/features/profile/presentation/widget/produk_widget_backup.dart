import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../auth/model/produk_dibeli_model.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class ProdukWidget extends StatefulWidget {
  final Map<String, List<ProdukDibeli>> daftarProdukDibeli;
  final void Function(RefreshController controller) onRefresh;

  const ProdukWidget(
      {Key? key, required this.daftarProdukDibeli, required this.onRefresh})
      : super(key: key);

  @override
  State<ProdukWidget> createState() => _ProdukWidgetState();
}

class _ProdukWidgetState extends State<ProdukWidget> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: context.textScale12),
      child: CustomSmartRefresher(
        isDark: true,
        controller: _refreshController,
        onRefresh: () async => widget.onRefresh(_refreshController),
        child: Container(
          width: (context.isMobile) ? context.dw : double.infinity,
          margin: EdgeInsets.only(
            top: min(14, context.dp(10)),
            right: min(24, context.dp(20)),
            left: min(24, context.dp(20)),
            bottom: min(36, context.dp(32)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: (widget.daftarProdukDibeli.isNotEmpty)
                ? min(20, context.dp(16))
                : 0,
            vertical: min(24, context.dp(20)),
          ),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                offset: Offset(1, 2),
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: (widget.daftarProdukDibeli.isEmpty)
              ? BasicEmpty(
                  shrink: true,
                  imageWidth: min(240, context.dp(200)),
                  imageUrl: 'ilustrasi_data_not_found.png'.illustration,
                  title: 'Oops',
                  subTitle: 'Tidak Ada Komponen Produk Yang Tertaut',
                  emptyMessage:
                      'Kamu sepertinya belum membeli produk Ganesha Operation Sobat. Yuk hubungi cabang terdekat dan beli produk Ganesha Operation!',
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Text('Daftar produk yang Sobat Beli',
                            style: context.text.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center)),
                    SizedBox(height: min(24, context.dp(20))),
                    ...List<Widget>.generate(
                      ((widget.daftarProdukDibeli.length) * 2),
                      (index) {
                        String jenisProduk =
                            widget.daftarProdukDibeli.keys.toList()[index ~/ 2];
                        List<ProdukDibeli> listProduk = widget
                            .daftarProdukDibeli.values
                            .toList()[index ~/ 2];

                        return (index.isEven)
                            ? ListTileTheme(
                                dense: true,
                                minLeadingWidth: 0,
                                horizontalTitleGap: -8.0,
                                minVerticalPadding: 0.0,
                                contentPadding: EdgeInsets.zero,
                                child: CustomExpansionTile(
                                  title: Text(jenisProduk),
                                  tilePadding: EdgeInsets.zero,
                                  children: List<Widget>.generate(
                                    listProduk.length,
                                    (index) => Container(
                                      constraints: BoxConstraints(
                                          minWidth: double.infinity,
                                          maxWidth: double.infinity,
                                          minHeight: min(42, context.dp(38)),
                                          maxHeight: min(64, context.dp(60))),
                                      margin:
                                          EdgeInsets.only(left: context.dp(24)),
                                      padding: EdgeInsets.only(
                                          top: min(14, context.dp(8)),
                                          right: context.dp(24),
                                          bottom: min(14, context.dp(8))),
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: context.disableColor)),
                                      ),
                                      child: Text(
                                        '${index + 1}. '
                                        '${listProduk[index].namaProduk} '
                                        '${(listProduk[index].isExpired) ? '(kedaluwarsa)' : ''}',
                                        style: context.text.bodySmall?.copyWith(
                                            color: (listProduk[index].isExpired)
                                                ? context.primaryColor
                                                : context.onBackground,
                                            fontWeight:
                                                (listProduk[index].isExpired)
                                                    ? FontWeight.w500
                                                    : FontWeight.w400),
                                        semanticsLabel:
                                            'Produk ${listProduk[index].idKomponenProduk}',
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const Divider();
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
