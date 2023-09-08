import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../provider/bookmark_provider.dart';
import '../../../entity/bookmark.dart';
import '../../../../../core/config/enum.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/helper/hive_helper.dart';
import '../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';

/// [BookmarkHomeWidget] merupakan widget bookmark yang digunakan pada home feature.
class BookmarkHomeWidget extends StatefulWidget {
  final String? noRegistrasi;
  final bool isSiswa;

  const BookmarkHomeWidget({
    Key? key,
    this.noRegistrasi,
    required this.isSiswa,
  }) : super(key: key);

  @override
  State<BookmarkHomeWidget> createState() => _BookmarkHomeWidgetState();
}

class _BookmarkHomeWidgetState extends State<BookmarkHomeWidget> {
  final ScrollController _scrollController = ScrollController();
  late final BookmarkProvider _bookmarkProvider =
      context.read<BookmarkProvider>();

  // Future dibuat final agar tidak ada pengulangan request,
  // kecuali BookmarkHomeWidget di rebuild.
  Future<void> _prepareBookmark() async {
    if (!HiveHelper.isBoxOpen<BookmarkMapel>(
        boxName: HiveHelper.kBookmarkMapelBox)) {
      await HiveHelper.openBox<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox);
    }

    await _bookmarkProvider.loadBookmarkMapel(
      isSiswa: widget.isSiswa,
      noRegistrasi: widget.noRegistrasi,
    );
  }

  void _navigateToDetailBookmarkScreen(
          {required String namaKelompokUjian,
          required String idKelompokUjian}) =>
      Navigator.pushNamed(context, Constant.kRouteBookmark, arguments: {
        'idKelompokUjian': idKelompokUjian,
        'namaKelompokUjian': namaKelompokUjian,
      });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: context.dp(56),
        maxHeight: (context.isMobile) ? context.dp(156) : context.dp(90),
      ),
      child: FutureBuilder(
        future: _prepareBookmark(),
        builder: (_, snapshot) => (snapshot.connectionState ==
                ConnectionState.waiting)
            ? _buildLoadingWidget()
            : Consumer<BookmarkProvider>(
                child: _buildEmptyBookmark(),
                builder: (_, bookmarkProvider, child) {
                  if (bookmarkProvider.isLoadBookmark) {
                    return _buildLoadingWidget();
                  }

                  if (bookmarkProvider.listBookmark.isEmpty) {
                    // Jika snapshot data berhasil diambil, tetapi data-nya null
                    // atau list-nya kosong maka tampilkan Empty Bookmark.
                    // Jika terjadi error, maka snapshot data akan bernilai null.
                    if (kDebugMode) {
                      logger.log('BOOKMARK_HOME_WIDGET-ValueListenableBuilder: '
                          'data di provider >> ${bookmarkProvider.listBookmark.length}');
                    }
                    return _buildEmptyBookmark();
                  }

                  // Tampilan loading get data dan list data tidak kosong.
                  // Menggunakan listenable untuk perubahan tampilan ketika update Hive data
                  return _buildValueListenableBuilder();
                }),
      ),
    );
  }

  ClipRRect _buildDefaultMapelImage(double width) => ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
          ),
        ),
        child: Image.asset(
          'assets/img/default_bookmark.png',
          width: width,
          fit: BoxFit.fitWidth,
        ),
      );

  Padding _buildLoadingItemWidget() => Padding(
        padding: EdgeInsets.only(left: context.dp(12)),
        child: ShimmerWidget(
          width: (context.isMobile) ? context.dp(106) : context.dp(64),
          height: (context.isMobile) ? context.dp(156) : context.dp(90),
          borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
          ),
        ),
      );

  ListView _buildLoadingWidget() => ListView.builder(
      itemCount: 4,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: min(28, context.dp(24))),
      itemBuilder: (_, i) =>
          (i == 0) ? _buildImageBookmark() : _buildLoadingItemWidget());

  CustomImageNetwork _buildImageBookmark() => CustomImageNetwork(
        'bookmark.webp'.imgUrl,
        width: min(140, context.dp(100)),
        height: min(140, context.dp(100)),
        fit: BoxFit.fitWidth,
      );

  Padding _buildEmptyBookmark() => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (context.isMobile) ? context.dp(24) : context.dp(18),
        ),
        child: LayoutBuilder(builder: (context, constraint) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildImageBookmark(),
              SizedBox(width: min(24, context.dp(12))),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    Constant.kRouteStoryBoardScreen,
                    arguments: Constant.kStoryBoard['Bookmark'],
                  ),
                  borderRadius: BorderRadius.circular(
                    (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
                  ),
                  child: Container(
                    // width: constraint.maxWidth -
                    //     ((context.isMobile) ? context.dp(120) : context.dp(64)),
                    // height: (context.isMobile)
                    //     ? max(56, context.dp(56))
                    //     : context.dp(32),
                    padding: (context.isMobile)
                        ? EdgeInsets.all(context.dp(12))
                        : EdgeInsets.only(
                            left: context.dp(10),
                            right: context.dp(4),
                            top: context.dp(6),
                            bottom: context.dp(6),
                          ),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(
                        (context.isMobile)
                            ? max(12, context.dp(12))
                            : context.dp(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Kenalan Sama Fitur\nYang Satu Ini Yuk',
                            style: context.text.labelMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: context.primaryColor,
                            size: min(46, context.dp(24))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      );

  Widget _buildBookmarkMapelItem(BookmarkMapel bookmark) => CustomCard(
        borderRadius: BorderRadius.circular(
          (context.isMobile) ? max(12, context.dp(12)) : context.dp(10),
        ),
        margin: EdgeInsets.only(
          left: min(16, context.dp(12)),
        ),
        padding: EdgeInsets.only(
          bottom: min(12, context.dp(8)),
        ),
        onTap: () => _navigateToDetailBookmarkScreen(
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
                isSiswa: widget.isSiswa,
              );
            }
          });
        },
        child: SizedBox(
          width: (context.isMobile) ? context.dp(106) : context.dp(64),
          height: (context.isMobile) ? context.dp(156) : context.dp(90),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) =>
                          (bookmark.iconMapel != null)
                              ? FittedBox(
                                  child: CustomImageNetwork.rounded(
                                    bookmark.iconMapel!,
                                    fit: BoxFit.fitWidth,
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        (context.isMobile)
                                            ? max(12, context.dp(12))
                                            : context.dp(10),
                                      ),
                                    ),
                                  ),
                                )
                              : _buildDefaultMapelImage(constraints.maxHeight),
                    ),
                  ),
                  Text(bookmark.namaKelompokUjian,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.onBackground),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis),
                  Text('(${bookmark.initial})',
                      style: context.text.labelSmall?.copyWith(
                          color: context.hintColor,
                          fontWeight: FontWeight.normal),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 7, bottom: 6, left: 9, right: 9),
                  decoration: BoxDecoration(
                    color: context.secondaryColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          (context.isMobile)
                              ? max(12, context.dp(12))
                              : context.dp(10),
                        ),
                        bottomLeft: Radius.circular(
                          (context.isMobile)
                              ? max(12, context.dp(12))
                              : context.dp(10),
                        )),
                  ),
                  child: Text('${bookmark.listBookmark.length}',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.onSecondary)),
                ),
              )
            ],
          ),
        ),
      );

  ValueListenableBuilder<Box<BookmarkMapel>> _buildValueListenableBuilder() =>
      ValueListenableBuilder<Box<BookmarkMapel>>(
        valueListenable: HiveHelper.listenableBookmarkMapel(),
        child: _buildImageBookmark(),
        builder: (_, box, imageBookmark) {
          List<BookmarkMapel> daftarBookmark = box.values.toList();

          if (kDebugMode) {
            logger.log(
                'BOOKMARK_HOME_WIDGET-ValueListenableBuilder: daftar bookmark >> ${daftarBookmark.toString()}');
          }
          if (daftarBookmark.length == 1 &&
              daftarBookmark.first.listBookmark.isEmpty) {
            if (kDebugMode) {
              logger.log(
                  'BOOKMARK_HOME_WIDGET-ValueListenableBuilder: daftar soal ${daftarBookmark.first.namaKelompokUjian} kosong');
            }

            _bookmarkProvider
                .removeBookmarkMapel(
                    isShowLoading: false,
                    isSiswa: widget.isSiswa,
                    idKelompokUjian: daftarBookmark.first.idKelompokUjian)
                .then((value) {
              if (kDebugMode) {
                logger.log(
                    'BOOKMARK_HOME_WIDGET-ValueListenableBuilder: ${(value) ? 'berhasil' : 'gagal'} hapus daftar soal ${daftarBookmark.first.namaKelompokUjian}');
              }
            });
          }

          if (daftarBookmark.isEmpty ||
              (daftarBookmark.length == 1 &&
                  daftarBookmark.first.listBookmark.isEmpty)) {
            if (kDebugMode) {
              logger.log(
                  'BOOKMARK_HOME_WIDGET-ValueListenableBuilder: cek daftar bookmark kosong >> ${daftarBookmark.isEmpty}');
              if ((daftarBookmark.length == 1 &&
                  daftarBookmark.first.listBookmark.isEmpty)) {
                logger.log(
                    'BOOKMARK_HOME_WIDGET-ValueListenableBuilder: cek daftar soal kosong >> ${daftarBookmark.first.listBookmark.isEmpty}');
              }
            }
            // Jika daftarBookmark kosong, maka tampilkan Empty Bookmark.
            return _buildEmptyBookmark();
          }

          return ListView.builder(
            controller: _scrollController,
            clipBehavior: Clip.none,
            itemCount: daftarBookmark.length + 1,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
            itemBuilder: (_, index) => (index == 0)
                ? imageBookmark!
                : _buildBookmarkMapelItem(daftarBookmark[index - 1]),
          );
        },
      );
}
