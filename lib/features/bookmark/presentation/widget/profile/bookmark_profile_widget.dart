import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../auth/presentation/provider/auth_otp_provider.dart';
import 'package:provider/provider.dart';

import '../../provider/bookmark_provider.dart';
import '../../../entity/bookmark.dart';
import '../../../../../core/config/enum.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/helper/hive_helper.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';

class BookmarkProfileWidget extends StatefulWidget {
  const BookmarkProfileWidget({Key? key}) : super(key: key);

  @override
  State<BookmarkProfileWidget> createState() => _BookmarkProfileWidgetState();
}

class _BookmarkProfileWidgetState extends State<BookmarkProfileWidget> {
  final ScrollController _scrollController = ScrollController();
  late final BookmarkProvider _bookmarkProvider =
      context.read<BookmarkProvider>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<BookmarkMapel>>(
      valueListenable: HiveHelper.listenableBookmarkMapel(),
      child: _buildImageBookmark(false),
      builder: (context, box, imageBookmark) {
        List<BookmarkMapel> daftarBookmark = box.values.toList();

        if (kDebugMode) {
          logger.log(
              'BOOKMARK_PROFILE_WIDGET-ValueListenableBuilder: daftar bookmark >> ${daftarBookmark.toString()}');
        }

        if (daftarBookmark.length == 1 &&
            daftarBookmark.first.listBookmark.isEmpty) {
          if (kDebugMode) {
            logger.log(
                'BOOKMARK_PROFILE_WIDGET-ValueListenableBuilder: daftar soal ${daftarBookmark.first.namaKelompokUjian} kosong');
          }

          _bookmarkProvider
              .removeBookmarkMapel(
                  isShowLoading: false,
                  isSiswa: context.read<AuthOtpProvider>().isSiswa,
                  idKelompokUjian: daftarBookmark.first.idKelompokUjian)
              .then((value) {
            if (kDebugMode) {
              logger.log(
                  'BOOKMARK_PROFILE_WIDGET-ValueListenableBuilder: ${(value) ? 'berhasil' : 'gagal'} hapus daftar soal ${daftarBookmark.first.namaKelompokUjian}');
            }
          });
        }

        if (daftarBookmark.isEmpty ||
            (daftarBookmark.length == 1 &&
                daftarBookmark.first.listBookmark.isEmpty)) {
          if (kDebugMode) {
            logger.log(
                'BOOKMARK_PROFILE_WIDGET-ValueListenableBuilder: cek daftar bookmark kosong >> ${daftarBookmark.isEmpty}');
            if ((daftarBookmark.length == 1 &&
                daftarBookmark.first.listBookmark.isEmpty)) {
              logger.log(
                  'BOOKMARK_PROFILE_WIDGET-ValueListenableBuilder: cek daftar soal kosong >> ${daftarBookmark.first.listBookmark.isEmpty}');
            }
          }
          // Jika daftarBookmark kosong, maka tampilkan Empty Bookmark.
          return _buildImageBookmark(true);
        }

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 8,
          radius: const Radius.circular(14),
          child: ListView.separated(
            controller: _scrollController,
            clipBehavior: Clip.none,
            itemCount: daftarBookmark.length + 1,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (_, index) => (index == 0)
                ? SizedBox(height: min(22, context.dp(18)))
                : Divider(indent: min(68, context.dp(64))),
            itemBuilder: (_, index) => (index == 0)
                ? imageBookmark!
                : _buildBookmarkMapelItem(daftarBookmark[index - 1]),
          ),
        );
      },
    );
  }

  void _navigateToDetailBookmarkScreen(BuildContext context,
          {required String namaKelompokUjian,
          required String idKelompokUjian}) =>
      Navigator.pushNamed(context, Constant.kRouteBookmark, arguments: {
        'idKelompokUjian': idKelompokUjian,
        'namaKelompokUjian': namaKelompokUjian,
      });

  ClipRRect _buildDefaultMapelImage() => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.asset(
          'assets/img/default_bookmark.png',
          fit: BoxFit.fitWidth,
        ),
      );

  Widget _buildImageBookmark(bool isBookmarkEmpty) => Padding(
        padding: EdgeInsets.symmetric(horizontal: min(28, context.dp(24))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              color: context.primaryColor,
              size: min(34, context.dp(32)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                textScaleFactor: context.textScale12,
                text: TextSpan(
                  text: 'My Bookmark\n',
                  style: context.text.titleMedium,
                  children: [
                    TextSpan(
                        text: (!isBookmarkEmpty)
                            ? 'Bookmark kamu dikelompokan berdasarkan Mata Uji dari tiap soal'
                            : 'Hmm, sepertinya kamu sama sekali belum bookmark soal Sobat',
                        style: context.text.labelMedium
                            ?.copyWith(color: context.hintColor))
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBookmarkMapelItem(BookmarkMapel bookmark) => ListTile(
        onTap: () => _navigateToDetailBookmarkScreen(context,
            namaKelompokUjian: bookmark.namaKelompokUjian,
            idKelompokUjian: bookmark.idKelompokUjian),
        onLongPress: () async {
          await gShowBottomDialog(context,
                  dialogType: DialogType.warning,
                  message:
                      'Kamu yakin ingin menghapus bookmark mata pelajaran ${bookmark.namaKelompokUjian}?')
              .then((value) async {
            if (value) {
              return await _bookmarkProvider.removeBookmarkMapel(
                idKelompokUjian: bookmark.idKelompokUjian,
                isSiswa: context.read<AuthOtpProvider>().isSiswa,
              );
            }
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Padding(
          padding: EdgeInsets.only(left: min(10, context.dp(8))),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: (bookmark.iconMapel != null)
                ? CustomImageNetwork.rounded(
                    bookmark.iconMapel!,
                    width: min(46, context.dp(32)),
                    fit: BoxFit.fitWidth,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  )
                : _buildDefaultMapelImage(),
          ),
        ),
        title: Text(
          bookmark.namaKelompokUjian,
          maxLines: 1,
          textScaleFactor: context.textScale12,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Jumlah: ${bookmark.listBookmark.length} Soal',
          maxLines: 1,
          textScaleFactor: context.textScale12,
          overflow: TextOverflow.ellipsis,
        ),
      );
}
