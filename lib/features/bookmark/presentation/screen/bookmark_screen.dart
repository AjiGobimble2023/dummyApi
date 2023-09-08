import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../widget/bookmark_soal_item.dart';
import '../provider/bookmark_provider.dart';
import '../../entity/bookmark.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/shared/screen/basic_screen.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';

class BookmarkScreen extends StatefulWidget {
  final String idKelompokUjian;
  final String namaKelompokUjian;

  const BookmarkScreen({
    Key? key,
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
  }) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final ValueListenable<Box<BookmarkMapel>> _listenableBookmarkMapel =
      HiveHelper.listenableBookmarkMapel();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Bookmark',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: RichText(
              text: TextSpan(
                  text: 'Mata Pelajaran : ${widget.namaKelompokUjian}\n',
                  style: context.text.labelLarge,
                  children: [
                    TextSpan(
                        text: 'Swipe ke kiri untuk hapus bookmark soal.',
                        style: context.text.bodySmall)
                  ]),
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: context.textScale12,
            ),
          ),
          Expanded(child: _buildListViewBookmark()),
        ],
      ),
    );
  }

  void _navigateToSoalBasicScreen({required BookmarkSoal bookmarkSoal}) {
    Navigator.pushNamed(context, Constant.kRouteSoalBasicScreen, arguments: {
      'idJenisProduk': bookmarkSoal.idJenisProduk,
      'namaJenisProduk': bookmarkSoal.namaJenisProduk,
      'diBukaDariRoute': Constant.kRouteBookmark,
      'kodeTOB': bookmarkSoal.kodeTOB,
      'kodePaket': bookmarkSoal.kodePaket,
      'idBundel': bookmarkSoal.idBundel,
      'namaKelompokUjian': widget.namaKelompokUjian,
      'kodeBab': bookmarkSoal.kodeBab,
      'namaBab': bookmarkSoal.namaBab,
      'mulaiDariSoalNomor': bookmarkSoal.nomorSoalSiswa,
      'tanggalKedaluwarsa': bookmarkSoal.tanggalKedaluwarsa,
      'isPaket': bookmarkSoal.isPaket,
      'isSimpan': bookmarkSoal.isSimpan,
      'isBisaBookmark': true
    });
  }

  Future<void> _hapusBookmarkSoal(BookmarkSoal bookmarkSoal) async {
    await context.read<BookmarkProvider>().removeBookmarkSoal(
          bookmarkSoal: bookmarkSoal,
          idKelompokUjian: widget.idKelompokUjian,
          isSiswa: context.read<AuthOtpProvider>().isSiswa,
        );
  }

  Widget _buildListViewBookmark() {
    return ValueListenableBuilder<Box<BookmarkMapel>>(
        valueListenable: _listenableBookmarkMapel,
        builder: (_, box, __) {
          List<BookmarkMapel> daftarBookmark = box.values.toList();
          List<BookmarkSoal> daftarBookmarkSoal = [];

          if (daftarBookmark.isNotEmpty) {
            daftarBookmarkSoal = daftarBookmark
                .firstWhere((bookmarkMapel) =>
                    bookmarkMapel.idKelompokUjian == widget.idKelompokUjian)
                .listBookmark;

            if (kDebugMode) {
              logger.log(
                  'BOOKMARK_SCREEN-ValueListenableBuilder: daftar bookmark soal length >> ${daftarBookmarkSoal.length}');
            }
          }

          if (daftarBookmark.isEmpty || daftarBookmarkSoal.isEmpty) {
            // Jika daftarBookmarkSoal / daftarBookmark kosong, maka kembali ke HomeScreen
            // Navigator.pop(context);
            return BasicEmpty(
                isLandscape: !context.isMobile,
                imageUrl: 'ilustrasi_bookmark.png'.illustration,
                title: 'Oops',
                subTitle: 'Bookmark ${widget.namaKelompokUjian} Kosong',
                emptyMessage:
                    'Hai Sobat, bookmark kamu di mata pelajaran ${widget.namaKelompokUjian} sudah dihapus semua.');
          }

          return ListView.separated(
              itemCount: daftarBookmarkSoal.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, i) =>
                  const Divider(indent: 60, endIndent: 24),
              itemBuilder: (_, index) {
                return BookmarkSoalItem(
                  key: Key(
                      '${daftarBookmarkSoal[index].kodePaket}.${daftarBookmarkSoal[index].idBundel}.${daftarBookmarkSoal[index].idSoal}'),
                  namaKelompokUjian: widget.namaKelompokUjian,
                  bookmarkSoal: daftarBookmarkSoal[index],
                  onPress: () => _navigateToSoalBasicScreen(
                      bookmarkSoal: daftarBookmarkSoal[index]),
                  onRemove: () => _hapusBookmarkSoal(daftarBookmarkSoal[index]),
                );
              });
        });
  }
}
