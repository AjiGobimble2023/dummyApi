import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'detail_komponen_produk.dart';
import '../../../auth/model/produk_dibeli_model.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class ProdukWidget extends StatefulWidget {
  final Map<String, Map<String, List<ProdukDibeli>>> daftarProdukDibeli;
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

  void _onClickDetailKomponen({
    required String jenisProduk,
    required String namaBundling,
    required List<ProdukDibeli> listKomponenProduk,
  }) {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      elevation: 4,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: context.background,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        childWidget ??= DetailKomponenProduk(
          jenisProduk: jenisProduk,
          namaBundling: namaBundling,
          daftarKomponenProduk: listKomponenProduk,
        );
        return childWidget!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaleFactor: context.textScale12),
      child: CustomSmartRefresher(
        isDark: true,
        controller: _refreshController,
        onRefresh: () async => widget.onRefresh(_refreshController),
        child: (widget.daftarProdukDibeli.isEmpty)
            ? _buildCard(
                isLastItem: true,
                child: _buildEmptyProduk(context),
              )
            : ListView.builder(
                itemCount: widget.daftarProdukDibeli.length + 1,
                itemBuilder: (context, index) {
                  List<String> namaBundling =
                      widget.daftarProdukDibeli.keys.toList();
                  List<Map<String, List<ProdukDibeli>>> daftarProduk =
                      widget.daftarProdukDibeli.values.toList();

                  return (index == 0)
                      ? _buildDaftarProdukTitle(context)
                      : _buildCard(
                          isLastItem: index == widget.daftarProdukDibeli.length,
                          child: _buildListProduk(
                            context,
                            namaBundling: namaBundling[index - 1],
                            daftarKomponenProduk: daftarProduk[index - 1],
                          ),
                        );
                },
              ),
      ),
    );
  }

  Column _buildListProduk(
    BuildContext context, {
    required String namaBundling,
    required Map<String, List<ProdukDibeli>> daftarKomponenProduk,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.graphic_eq_rounded,
              color: context.tertiaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                textScaleFactor: context.textScale12,
                text: TextSpan(
                  text: 'Bundling\n',
                  style: context.text.bodySmall
                      ?.copyWith(fontSize: 11, color: context.hintColor),
                  children: [
                    TextSpan(text: namaBundling, style: context.text.labelLarge)
                  ],
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black54),
        Text(
          'Komponen Produk: ',
          style: context.text.bodySmall?.copyWith(color: context.hintColor),
        ),
        ...List<Widget>.generate(
          (daftarKomponenProduk.length),
          (index) {
            String jenisProduk = daftarKomponenProduk.keys.toList()[index];
            List<ProdukDibeli> listKomponenProduk =
                daftarKomponenProduk.values.toList()[index];

            return Container(
              constraints: BoxConstraints(
                  minWidth: double.infinity,
                  maxWidth: double.infinity,
                  minHeight: min(42, context.dp(38)),
                  maxHeight: min(64, context.dp(60))),
              margin: EdgeInsets.only(
                  top: (index == 0) ? 6 : 0, left: context.dp(14)),
              padding: EdgeInsets.only(
                  top: min(14, context.dp(8)),
                  right: context.dp(24),
                  bottom: min(14, context.dp(8))),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: RichText(
                textScaleFactor: context.textScale12,
                text: TextSpan(
                  text: '${index + 1}) $jenisProduk ',
                  style: context.text.bodySmall?.copyWith(
                      color: context.onBackground, fontWeight: FontWeight.w400),
                  semanticsLabel: 'Produk $jenisProduk',
                  children: [
                    TextSpan(
                      text: '(${listKomponenProduk.length} item) ',
                      style: context.text.bodySmall
                          ?.copyWith(fontSize: 11, color: Colors.black54),
                    ),
                    TextSpan(
                      text: 'lihat detail',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _onClickDetailKomponen(
                              jenisProduk: jenisProduk,
                              namaBundling: namaBundling,
                              listKomponenProduk: listKomponenProduk,
                            ),
                      style: context.text.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  BasicEmpty _buildEmptyProduk(BuildContext context) {
    // ExpansionPanel(headerBuilder: headerBuilder, body: body)
    return BasicEmpty(
      shrink: true,
      imageWidth: min(240, context.dp(200)),
      imageUrl: 'ilustrasi_data_not_found.png'.illustration,
      title: 'Oops',
      subTitle: 'Tidak Ada Komponen Produk Yang Tertaut',
      emptyMessage:
          'Kamu sepertinya belum membeli produk Ganesha Operation Sobat. Yuk hubungi cabang terdekat dan beli produk Ganesha Operation!',
    );
  }

  Widget _buildDaftarProdukTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: min(14, context.dp(10)),
        bottom: min(8, context.dp(6)),
      ),
      child: Center(
          child: Text('Daftar produk yang Sobat Beli',
              style: context.text.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center)),
    );
  }

  Container _buildCard({bool isLastItem = false, Widget? child}) => Container(
        width: (context.isMobile) ? context.dw : double.infinity,
        margin: EdgeInsets.only(
          top: min(14, context.dp(10)),
          right: min(24, context.dp(20)),
          left: min(24, context.dp(20)),
          bottom:
              (isLastItem) ? min(36, context.dp(32)) : min(8, context.dp(6)),
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
        child: child,
      );
}
