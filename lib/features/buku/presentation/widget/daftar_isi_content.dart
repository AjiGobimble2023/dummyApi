import 'dart:math';

import 'package:flutter/material.dart';

import '../../entity/bab_buku.dart';
import '../../../../core/config/extensions.dart';

/// [DaftarIsiContent] merupakan Widget yang menampilkan List dari Daftar Isi.<br><br>
/// [title] adalah nama Bab Utama (Dari Buku Teori / Rumus) atau
/// nama Mata Pelajaran (Dari Sobat Tips / Kisi-Kisi).
class DaftarIsiContent extends StatelessWidget {
  final String title;
  final BabBuku babAktif;
  final List<BabBuku> daftarBab;
  final Function(BabBuku) onClickBabBuku;

  const DaftarIsiContent({
    super.key,
    required this.title,
    required this.daftarBab,
    required this.onClickBabBuku,
    required this.babAktif,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final headerWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.list_alt_rounded,
          color: context.tertiaryColor,
          size: min(36, context.dp(32)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            textScaleFactor: context.textScale12,
            text: TextSpan(
                text: 'Daftar Isi\n',
                style: context.text.titleMedium,
                children: [
                  TextSpan(
                      text: (daftarBab.isEmpty)
                          ? 'Daftar isi terkait $title tidak tersedia'
                          : '~Daftar isi terkait $title',
                      style: context.text.labelMedium
                          ?.copyWith(color: context.hintColor))
                ]),
          ),
        ),
      ],
    );

    return (context.isMobile)
        ? Padding(
            padding: EdgeInsets.only(
              top: context.dp(24),
              bottom: context.dp(20),
              left: context.dp(18),
              right: context.dp(18),
            ),
            child: (daftarBab.isEmpty)
                ? headerWidget
                : _buildDaftarIsi(scrollController, context, headerWidget),
          )
        : MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaleFactor: context.textScale11),
            child: _buildDaftarIsi(scrollController, context, headerWidget),
          );
  }

  Widget _buildDaftarIsi(ScrollController scrollController,
      BuildContext context, Row headerWidget) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 8,
      radius: const Radius.circular(14),
      child: ListView(
        shrinkWrap: true,
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        padding: (context.isMobile)
            ? null
            : const EdgeInsets.only(top: 8, bottom: 14, left: 12, right: 12),
        children: [
          if (context.isMobile) headerWidget,
          if (context.isMobile) SizedBox(height: min(16, context.dp(12))),
          ...List<Widget>.generate(
            daftarBab.length,
            (index) => _buildBabButton(context,
                bab: daftarBab[index], part: index + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildBabButton(
    BuildContext context, {
    required BabBuku bab,
    required int part,
  }) {
    bool isSelected = '${bab.kodeBab} ${bab.namaBab}' ==
        '${babAktif.kodeBab} ${babAktif.namaBab}';
    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.hintColor)),
      ),
      padding: EdgeInsets.symmetric(vertical: (isSelected) ? 8 : 0),
      child: TextButton(
        onPressed: (isSelected) ? null : () => onClickBabBuku(bab),
        style: TextButton.styleFrom(
          foregroundColor: context.hintColor,
          backgroundColor: (isSelected) ? Colors.black12 : null,
          padding: EdgeInsets.symmetric(
            vertical: (context.isMobile)
                ? context.dp(12)
                : (isSelected)
                    ? 14
                    : 12,
            horizontal: (isSelected) ? 14 : 0,
          ),
          alignment: Alignment.centerLeft,
          textStyle: context.text.bodyMedium,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          '${bab.kodeBab} ${bab.namaBab}',
          textAlign: TextAlign.left,
          semanticsLabel: 'Daftar Isi Teori ${bab.kodeBab}',
          style: context.text.bodyMedium,
        ),
      ),
    );
  }
}
