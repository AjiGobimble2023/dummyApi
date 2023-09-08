import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/laporan_presensi_provider.dart';
import '../../model/laporan_presensi.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/data_formatter.dart';
import '../../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/separator/dash_divider.dart';
import '../../../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class LaporanPresensiWidget extends StatefulWidget {
  const LaporanPresensiWidget({Key? key}) : super(key: key);

  @override
  State<LaporanPresensiWidget> createState() => _LaporanPresensiWidgetState();
}

class _LaporanPresensiWidgetState extends State<LaporanPresensiWidget> {
  ///[_futureFetchPresensi] merupakan variable untuk meneampung data list presensi
  Future<List<LaporanPresensiDate>>? _futureFetchPresensi;

  /// [_refreshController] Membuat objek RefreshController dan menetapkannya ke variabel _refreshController.
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// [_refreshPresensi] fungsi yang digunakan untuk menyegarkan data yang ditampilkan di layar.
  Future<void> _refreshPresensi() async {
    return Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      setState(() {
        _futureFetchPresensi = context
            .read<LaporanPresensiProvider>()
            .loadPresensi(userId: gNoRegistrasi);
      });
      _refreshController.refreshCompleted();
    });
  }

  @override
  void initState() {
    super.initState();
    _futureFetchPresensi = context
        .read<LaporanPresensiProvider>()
        .loadPresensi(userId: gNoRegistrasi);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LaporanPresensiDate>>(
      future: _futureFetchPresensi,
      builder: (context, snap) {
        bool isLoading = snap.connectionState != ConnectionState.done;

        if (isLoading) return const LoadingWidget();

        if (snap.data is List && snap.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: CustomSmartRefresher(
                      controller: _refreshController,
                      onRefresh: _refreshPresensi,
                      isDark: true,
                      child: _buildListPresensi(snap),
                    ),
                  ),
                )
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: SizedBox(
            height: (context.isMobile)
                ? context.dh - 200
                : context.dh > 600
                    ? context.dh
                    : context.dh * 1.2,
            child: BasicEmpty(
                shrink: false,
                // isLandscape: !context.isMobile,
                imageUrl: 'ilustrasi_laporan_presensi.png'.illustration,
                title: 'Laporan Presensi',
                subTitle: "Data tidak ditemukan",
                emptyMessage:
                    "Sobat belum hadir dan memindai QR-Code presensi"),
          ),
        );
      },
    );
  }

  ListView _buildListPresensi(AsyncSnapshot<List<LaporanPresensiDate>> snap) {
    return ListView.builder(
      itemCount: snap.data!.length,
      itemBuilder: (context, idx) {
        return Column(
          children: [
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: CustomExpansionTile(
                title: Text(
                  DateFormat.yMMMMd('ID')
                      .format(DateTime.parse(snap.data![idx].date)),
                ),
                subtitle: Row(
                  children: [
                    Text(
                        "Jumlah kegiatan : ${snap.data![idx].listPresences.length}"),
                    const Spacer(),
                    (snap.data![idx].feedbackCount > 0)
                        ? Text(
                            "Belum feedback : ${snap.data![idx].feedbackCount.toString()}",
                          )
                        : const SizedBox.shrink()
                  ],
                ),
                children: snap.data![idx].listPresences
                    .map(
                      (listPresence) => _buildCard(context, listPresence),
                    )
                    .toList(),
              ),
            ),
            const Divider()
          ],
        );
      },
    );
  }

  /// [_buildCard] fungsi yang digunakan untuk membuat Card Widget yang akan digunakan untuk menampilkan
  /// data yang telah diperoleh dari API.
  Widget _buildCard(BuildContext context, LaporanPresensiInfo listPresence) {
    return CustomCard(
      elevation: 3,
      margin: EdgeInsets.symmetric(
        horizontal: context.dp(18),
        vertical: context.dp(8),
      ),
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.only(
          top: context.dp(10),
          left: context.dp(10),
          right: context.dp(10),
          bottom: context.dp(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, listPresence),
          const Divider(
            height: 24,
            thickness: 1,
            color: Colors.black12,
          ),
          IntrinsicHeight(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: (context.isMobile) ? 46 : 112),
              child: Row(
                children: [
                  _buildWaktuKegiatan(context, listPresence),
                  _buildInformasiKegiatan(context, listPresence),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// [_buildInformasiKegiatan] digunakan untuk menampilkan informasi data kegiatan.
  Expanded _buildInformasiKegiatan(
      BuildContext context, LaporanPresensiInfo listPresence) {
    return Expanded(
      flex: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: 'Jam Presensi: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: DateFormat.Hm()
                        .format(DateTime.parse(listPresence.presenceTime!)),
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: 'Lokasi: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: listPresence.buildingName,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: 'Kelas GO: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: listPresence.className,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: 'Mata Pelajaran: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: listPresence.lesson,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pengajar:',
            style: context.text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 4),
          Text(
            listPresence.teacherName!,
            style: context.text.labelMedium?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '(${listPresence.teacherId})',
            style: context.text.bodySmall?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  /// [_buildWaktuKegiatan] digunakan untuk menampilkan widget data waktu aktivitas.
  Expanded _buildWaktuKegiatan(
      BuildContext context, LaporanPresensiInfo listPresence) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(right: context.dp(6)),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryColor,
                borderRadius: BorderRadius.circular(300),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: context.secondaryContainer.withOpacity(0.87)),
                  BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: context.secondaryContainer.withOpacity(0.87)),
                ],
              ),
              child: Text(
                DateFormat.Hm()
                    .format(DateTime.parse(listPresence.scheduleStart!)),
                style: context.text.labelMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: DashedDivider(
                dashColor: context.disableColor,
                strokeWidth: 1,
                dash: 6,
                direction: Axis.vertical,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryColor,
                borderRadius: BorderRadius.circular(300),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryContainer.withOpacity(0.87)),
                  BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryContainer.withOpacity(0.87)),
                ],
              ),
              child: Text(
                DateFormat.Hm()
                    .format(DateTime.parse(listPresence.scheduleFinish!)),
                style: context.text.labelMedium,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// [_buildHeader] digunakan untuk membangun tajuk daftar laporan kehadiran.
  Row _buildHeader(BuildContext context, LaporanPresensiInfo listPresence) {
    return Row(
      children: [
        _buildIconJadwal(context),
        Expanded(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listPresence.activity!,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Pertemuan ke-${listPresence.session}',
                    style: context.text.labelSmall
                        ?.copyWith(color: context.hintColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const Spacer(),
              (listPresence.feedbackPermission! || !listPresence.isFeedback!)
                  ? GestureDetector(
                      onTap: () async {
                        final sekarang = DateTime.now();
                        final jamAkhir = DataFormatter.stringToDate(
                                listPresence.scheduleFinish!)
                            .subtract(const Duration(minutes: 15));

                        if (sekarang.isBefore(jamAkhir)) {
                          gShowTopFlash(context,
                              "Sobat bisa melakukan feedback setelah kelas berakhir");
                        } else {
                          await Navigator.of(context).pushNamed(
                            Constant.kRouteFeedback,
                            arguments: {
                              "idRencana": listPresence.planId,
                              "namaPengajar": listPresence.teacherName,
                              "tanggal": listPresence.date,
                              "kelas": listPresence.className,
                              "mapel": listPresence.lesson,
                              "flag": listPresence.flag,
                              "done": listPresence.isFeedback,
                            },
                          );
                          _refreshPresensi();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: listPresence.isFeedback!
                              ? Colors.green
                              : context.primaryColor,
                          borderRadius: BorderRadius.circular(300),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(-1, -1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: (listPresence.isFeedback!
                                        ? Colors.green
                                        : context.primaryColor)
                                    .withOpacity(0.42)),
                            BoxShadow(
                              offset: const Offset(1, 1),
                              blurRadius: 4,
                              spreadRadius: 1,
                              color: (listPresence.isFeedback!
                                  ? Colors.green
                                  : context.primaryColor.withOpacity(0.42)),
                            ),
                          ],
                        ),
                        child: Text(
                          listPresence.isFeedback! ? "Done" : "Feedback",
                          style: context.text.labelMedium
                              ?.copyWith(color: context.background),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: context.disableColor,
                          borderRadius: BorderRadius.circular(300),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(-1, -1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: context.disableColor.withOpacity(0.1)),
                            BoxShadow(
                                offset: const Offset(1, 1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: context.disableColor.withOpacity(0.1))
                          ]),
                      child: Text(
                        "Expired",
                        style: context.text.labelMedium
                            ?.copyWith(color: context.background),
                      ),
                    )
            ],
          ),
        ),
      ],
    );
  }

  /// [_buildIconJadwal] widget untuk membangun icon jadwal
  Container _buildIconJadwal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: EdgeInsets.only(right: context.dp(12)),
      decoration: BoxDecoration(
          color: context.tertiaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                offset: const Offset(-1, -1),
                blurRadius: 4,
                spreadRadius: 1,
                color: context.tertiaryColor.withOpacity(0.42)),
            BoxShadow(
                offset: const Offset(1, 1),
                blurRadius: 4,
                spreadRadius: 1,
                color: context.tertiaryColor.withOpacity(0.42))
          ]),
      child: Icon(
        Icons.schedule,
        size: context.dp(32),
        color: context.onTertiary,
        semanticLabel: 'ic_jadwal_siswa',
      ),
    );
  }
}
