import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/buku_provider.dart';
import '../../entity/buku.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/separator/dash_divider.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../core/shared/widget/expanded/custom_expanded_widget.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [BukuList] merupakan Widget List Buku Teori & Rumus.<br><br>
/// Digunakan pada produk-produk berikut:<br>
/// 1. Buku Teori (id: 59).<br>
/// 2. Buku Rumus (id: 46).
class BukuList extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final bool isRencanaPicker;

  const BukuList({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    this.isRencanaPicker = false,
  }) : super(key: key);

  @override
  State<BukuList> createState() => _BukuListState();
}

class _BukuListState extends State<BukuList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  late String _jenisBuku;

  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _jenisBuku = (widget.idJenisProduk == 46) ? 'rumus' : 'teori';
    if (kDebugMode) {
      logger.log('BUKU_LIST-Build: IdJenisProduk >> ${widget.idJenisProduk}'
          ' | JenisBuku >> $_jenisBuku');
    }
    return Selector<BukuProvider, List<Buku>>(
      selector: (_, buku) =>
          buku.getListBukuByIdJenisProduk(widget.idJenisProduk),
      // shouldRebuild: (previous, next) => next.any((buku) {
      //   bool shouldRebuild = next.length != previous.length;
      //
      //   if (!shouldRebuild &&
      //       previous.any((prev) =>
      //           prev.idMataPelajaran == buku.idMataPelajaran &&
      //           prev.kelengkapan == buku.kelengkapan &&
      //           prev.levelTeori == buku.levelTeori &&
      //           prev.namaMataPelajaran == buku.namaMataPelajaran)) {
      //     var prevBuku = previous
      //         .where((prev) =>
      //             prev.idMataPelajaran == buku.idMataPelajaran &&
      //             prev.kodeBuku == buku.kodeBuku &&
      //             prev.namaMataPelajaran == buku.namaMataPelajaran)
      //         .first;
      //
      //     shouldRebuild =
      //         buku.namaMataPelajaran != prevBuku.namaMataPelajaran ||
      //             buku.idMataPelajaran != prevBuku.idMataPelajaran ||
      //             buku.kodeBuku != prevBuku.kodeBuku ||
      //             buku.imageUrl != prevBuku.imageUrl ||
      //             buku.isTeaser != prevBuku.isTeaser;
      //   }
      //
      //   return shouldRebuild;
      // }),
      builder: (_, listBuku, loadingWidget) => FutureBuilder<void>(
          future: _onRefreshBuku(false),
          builder: (context, snapshot) {
            final bool isLoadingBuku = snapshot.connectionState ==
                    ConnectionState.waiting ||
                context
                    .select<BukuProvider, bool>((buku) => buku.isLoadingBuku);

            if (isLoadingBuku) {
              return loadingWidget!;
            }

            var refreshWidget = CustomSmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefreshBuku,
              isDark: true,
              child: (listBuku.isEmpty)
                  ? _getIllustrationImage(widget.idJenisProduk)
                  : _buildListBuku(listBuku),
            );

            return (listBuku.isEmpty)
                ? refreshWidget
                : WatermarkWidget(child: refreshWidget);
          }),
      child: const ShimmerListTiles(isWatermarked: true),
    );
  }

  bool _isProdukDibeli({bool ortuBolehAkses = false}) {
    bool isProdukDibeli = _authOtpProvider.isProdukDibeliSiswa(
        widget.idJenisProduk,
        ortuBolehAkses: ortuBolehAkses);
    if (widget.idJenisProduk == 59) {
      bool isBeliTeori = _authOtpProvider.isProdukDibeliSiswa(59,
          ortuBolehAkses: ortuBolehAkses);
      bool isBeliTeoriSingkat = _authOtpProvider.isProdukDibeliSiswa(97,
          ortuBolehAkses: ortuBolehAkses);
      bool isBeliTeoriRingkas = _authOtpProvider.isProdukDibeliSiswa(98,
          ortuBolehAkses: ortuBolehAkses);

      isProdukDibeli = isBeliTeori | isBeliTeoriSingkat | isBeliTeoriRingkas;
    }
    return isProdukDibeli;
  }

  // On Refresh Function
  Future<void> _onRefreshBuku([bool refresh = true]) async {
    // Function load and refresh data
    await context
        .read<BukuProvider>()
        .loadDaftarBuku(
          isRefresh: refresh,
          noRegistrasi: _authOtpProvider.userData?.noRegistrasi,
          idSekolahKelas: _authOtpProvider.userData?.idSekolahKelas ??
              _authOtpProvider.idSekolahKelas.value ??
              '14',
          idJenisProduk: widget.idJenisProduk,
          roleTeaser: _authOtpProvider.teaserRole,
          isProdukDibeli: _isProdukDibeli(),
        )
        .onError((error, stackTrace) => _refreshController.refreshFailed())
        .then((_) => _refreshController.refreshCompleted());
  }

  // Get Illustration Image Function
  Widget _getIllustrationImage(int idJenisProduk) {
    String imageUrl = 'ilustrasi_data_not_found.png'.illustration;
    String title = 'Buku ';

    switch (idJenisProduk) {
      case 46: // Rumus
        imageUrl = 'ilustrasi_rumus.png'.illustration;
        title += 'Rumus';
        break;
      case 59: // Teori
        imageUrl = 'ilustrasi_teori.png'.illustration;
        title += 'Teori';
        break;
      default:
        break;
    }

    Widget basicEmpty = BasicEmpty(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      imageUrl: imageUrl,
      title: title,
      subTitle: gEmptyProductSubtitle(
          namaProduk: title,
          isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
          isOrtu: _authOtpProvider.isOrtu,
          isNotSiswa: !_authOtpProvider.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: title,
        isOrtu: _authOtpProvider.isOrtu,
        isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
      ),
    );

    return (context.isMobile || context.dh > 600)
        ? basicEmpty
        : SingleChildScrollView(
            child: basicEmpty,
          );
  }

  Widget _buildLeadingItem({required Buku buku, required bool isTeaser}) {
    var leadingWidget = (buku.imageUrl != null)
        ? CustomImageNetwork.rounded(
            buku.imageUrl!,
            width: 46,
            height: 46,
            fit: BoxFit.fitHeight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          )
        : ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.asset(
              'assets/img/default_buku.png',
              width: 46,
              height: 46,
              fit: BoxFit.fitHeight,
            ),
          );

    return !isTeaser
        ? leadingWidget
        : Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                min(14, context.dp(14)),
              ),
              border: Border.all(color: context.tertiaryColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: context.tertiaryColor),
                  child: Text(
                    'TEASER',
                    style: context.text.labelSmall?.copyWith(
                      color: context.onTertiary,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                leadingWidget,
              ],
            ),
          );
  }

  // List Bundel Widgets
  Widget _buildListBuku(List<Buku> listBuku) {
    final Map<String, List<Buku>> bukuGroupBy = listBuku.fold(
      {},
      (prev, buku) {
        prev
            .putIfAbsent('${buku.namaKelompokUjian}.${buku.isTeaser}', () => [])
            .add(buku);
        return prev;
      },
    );
    final List<String> label = bukuGroupBy.keys.toList();
    final List<List<Buku>> subListBuku = bukuGroupBy.values.toList();

    return ListView.separated(
      itemCount: bukuGroupBy.length,
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding:
          EdgeInsets.only(top: min(8, context.dp(4)), bottom: context.dp(30)),
      separatorBuilder: (_, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DashedDivider(
          dashColor: context.outline,
          strokeWidth: 0.6,
          gap: 4,
          dash: 4,
          direction: Axis.horizontal,
        ),
      ),
      itemBuilder: (_, index) {
        final subBukuLength = subListBuku[index].length;
        final noExpandWidget = Container(
          padding: const EdgeInsets.only(top: 18, bottom: 18),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 14),
                    _buildLeadingItem(
                      buku: subListBuku[index].first,
                      isTeaser: subListBuku[index].first.isTeaser,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label[index].split('.')[0],
                            style: context.text.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Singkatan: ${subListBuku[index].first.singkatan}',
                            style: context.text.labelSmall
                                ?.copyWith(color: context.hintColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
                const SizedBox(height: 6),
                ..._buildSubBukuItemList(subBukuLength, subListBuku, index),
              ],
            ),
          ),
        );

        return (subBukuLength < 3)
            ? noExpandWidget
            : CustomExpandedWidget(
                leadingItem: _buildLeadingItem(
                  buku: subListBuku[index].first,
                  isTeaser: subListBuku[index].first.isTeaser,
                ),
                title: label[index].split('.')[0],
                subTitle: 'Singkatan: ${subListBuku[index].first.singkatan}',
                moreItemCount: subBukuLength - 2,
                collapsedVisibilityFactor: 2 / subBukuLength,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildSubBukuItemList(
                        subBukuLength, subListBuku, index),
                  ),
                ),
              );
      },
    );
  }

  List<Widget> _buildSubBukuItemList(
    int subBukuLength,
    List<List<Buku>> subListBuku,
    int index,
  ) {
    return (context.isMobile)
        ? List<Widget>.generate(
            subBukuLength,
            (subIndex) => _buildItemSubBuku(subListBuku[index][subIndex]),
          )
        : List<Widget>.generate(
            (subBukuLength.isEven)
                ? (subBukuLength / 2).floor()
                : (subBukuLength / 2).floor() + 1,
            (subIndex) => Padding(
              padding: const EdgeInsets.only(left: 48, right: 32, top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildItemSubBuku(
                      subListBuku[index][subIndex * 2],
                      // height: 118,
                    ),
                  ),
                  const SizedBox(width: 20),
                  (((subIndex * 2) + 1) < subBukuLength)
                      ? Expanded(
                          child: _buildItemSubBuku(
                            subListBuku[index][(subIndex * 2) + 1],
                            // height: 118,
                          ),
                        )
                      : const Spacer(),
                ],
              ),
            ),
          );
  }

  Container _buildItemSubBuku(
    Buku buku, {
    double? height,
  }) {
    // buku.isTeaser;
    return Container(
      height: height,
      margin: EdgeInsets.only(
        top: 8,
        left: (context.isMobile) ? 48 : 0,
        right: (context.isMobile) ? 20 : 0,
      ),
      decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular((context.isMobile) ? 16 : 24),
          border: Border.all(color: context.outline)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular((context.isMobile) ? 16 : 24),
        elevation: 0,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            Constant.kRouteBabTeoriScreen,
            arguments: {
              'jenisBuku': _jenisBuku,
              'buku': buku,
              'isRencanaPicker': widget.isRencanaPicker,
            },
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (context.isMobile) ? 12 : 18,
              vertical: (context.isMobile) ? 10 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buku.namaBuku,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: context.onBackground.withOpacity(0.86),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaleFactor: context.textScale11),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Kelas:\n  ${buku.sekolahKelas}',
                          style: (context.isMobile)
                              ? context.text.bodySmall
                              : context.text.bodyMedium
                                  ?.copyWith(color: context.hintColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Semester: ${buku.semester}\n',
                            style: (context.isMobile)
                                ? context.text.bodySmall
                                : context.text.bodyMedium
                                    ?.copyWith(color: context.hintColor),
                            children: [
                              TextSpan(
                                text: 'Level        : ${buku.levelTeori}',
                                style: (context.isMobile)
                                    ? context.text.bodySmall
                                    : context.text.bodyMedium
                                    ?.copyWith(color: context.hintColor),),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
