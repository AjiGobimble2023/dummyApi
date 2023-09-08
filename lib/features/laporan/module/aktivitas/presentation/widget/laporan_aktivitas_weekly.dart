import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../provider/laporan_aktivitas_provider.dart';
import '../../model/laporan_aktivitas_model.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/exception/exception_widget.dart';

class LogAktivitasMingguan extends StatefulWidget {
  const LogAktivitasMingguan({super.key});

  @override
  State<LogAktivitasMingguan> createState() => _LogAktivitasMingguanState();
}

class _LogAktivitasMingguanState extends State<LogAktivitasMingguan> {
  /// [_futureFetchAktivitas] variabel yang akan digunakan untuk menyimpan Future List Laporan Aktivitas.
  Future<List<LaporanAktivitasModel>>? _futureFetchAktivitas;

  /// [_userId] variabel yang berisi nomor registrasi Siswa.
  String? _userId;

  /// [_authProvider] variabel untuk membaca data login user dari authotpprovider.
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  /// [_refreshController] Membuat objek RefreshController dan menetapkannya ke variabel _refreshController.
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// [_refreshAktivitas] digunakan untuk menyegarkan data.
  Future<void> _refreshAktivitas() async {
    return Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      if (mounted) {
        setState(() {
          _futureFetchAktivitas = context
              .read<LaporanAktivitasProvider>()
              .loadLogAktivitas(userId: _userId, type: 'weekly');
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _userId = _authProvider.userData?.noRegistrasi;
    _futureFetchAktivitas = context
        .read<LaporanAktivitasProvider>()
        .loadLogAktivitas(userId: _userId, type: 'weekly');
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LaporanAktivitasModel>>(
      future: _futureFetchAktivitas,
      builder: (context, aktivitasSnapshot) {
        return aktivitasSnapshot.hasError
            ? SingleChildScrollView(
                child: SizedBox(
                  height: (context.isMobile)
                      ? context.dh - 200
                      : context.dh < 600
                          ? context.dh - 100
                          : context.dh - 150,
                  child: BasicEmpty(
                      // shrink: context.isMobile,
                      isLandscape: !context.isMobile,
                      imageUrl: 'ilustrasi_laporan_aktivitas.png'.illustration,
                      title: 'Laporan Aktivitas',
                      emptyMessage:
                          "Sobat belum membaca, menonton video dan mengerjakan soal minggu ini, ayo mulai belajar Sobat!",
                      subTitle: "Data tidak ditemukan"),
                ),
              )
            : aktivitasSnapshot.connectionState == ConnectionState.done
                ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.pd, vertical: context.pd / 2),
                    child: CustomSmartRefresher(
                      controller: _refreshController,
                      onRefresh: _refreshAktivitas,
                      isDark: true,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: <Widget>[
                          aktivitasSnapshot.hasError
                              ? SliverExceptionWidget(
                                  aktivitasSnapshot.error.toString(),
                                  exceptionMessage:
                                      aktivitasSnapshot.error.toString(),
                                )
                              : aktivitasSnapshot.hasData
                                  ? SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) => buildTimeLine(
                                            aktivitasSnapshot.data![index],
                                            index,
                                            aktivitasSnapshot.data!.length),
                                        childCount:
                                            aktivitasSnapshot.data!.length,
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: SizedBox(
                                        height: (context.isMobile)
                                            ? context.dh - 200
                                            : context.dh < 600
                                                ? context.dh - 100
                                                : context.dh - 150,
                                        child: BasicEmpty(
                                            // shrink: context.isMobile,
                                            isLandscape: !context.isMobile,
                                            imageUrl:
                                                'ilustrasi_laporan_aktivitas.png'
                                                    .illustration,
                                            title: 'Laporan Aktivitas',
                                            subTitle: 'Data tidak ditemukan',
                                            emptyMessage:
                                                "Kami tidak dapat menemukan data yang kamu inginkan untuk saat ini"),
                                      ),
                                    )
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(context.pd),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: SizedBox(
                                    height: 20,
                                    width: (context.isMobile)
                                        ? context.dw * 0.25
                                        : (context.dw - context.dp(132)) * 0.25,
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: SizedBox(
                                    height: 80,
                                    width: (context.isMobile)
                                        ? context.dw - (context.dw * 0.25) - 60
                                        : (context.dw - context.dp(132)) -
                                            (context.dw * 0.25) -
                                            60,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
      },
    );
  }

  /// [buildTimeLine] digunakan untuk membangun time line
  ///
  /// Args:
  ///   aktivitasModel (LaporanAktivitasModel): Model data yang akan digunakan untuk membangun time line.
  ///   index: Indeks item dalam list.
  ///   length: Panjang data dari list item.
  Widget buildTimeLine(LaporanAktivitasModel aktivitasModel, index, length) {
    return TimelineTile(
      endChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              buildWaktu(aktivitasModel),
              buildCard(aktivitasModel)
            ],
          ),
        ],
      ),
      beforeLineStyle: LineStyle(
          color: (index == 0) ? Colors.transparent : Colors.grey, thickness: 2),
      afterLineStyle: LineStyle(
          color: (index == length - 1) ? Colors.transparent : Colors.grey,
          thickness: 2),
      indicatorStyle: const IndicatorStyle(
        padding: EdgeInsets.all(0),
        color: Colors.green,
        width: 12,
      ),
    );
  }

  /// [buildWaktu] digunakan untuk menampilkan tanggal dan waktu aktivitas.
  Widget buildWaktu(LaporanAktivitasModel aktivitasModel) {
    return SizedBox(
      width: (context.isMobile) ? 100 : 200,
      child: Column(
        children: [
          Text(
            DateFormat.yMMMd('ID').format(DateTime.parse(aktivitasModel.masuk)),
            style: context.text.bodySmall?.copyWith(color: Colors.grey),
          ),
          Text(
            DateFormat("HH:mm").format(DateTime.parse(aktivitasModel.masuk)),
            style: context.text.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// [buildCard] digunakan untuk membangun Widget Card yang berisi data aktivitas.
  ///
  /// Args:
  ///   aktivitasModel (LaporanAktivitasModel): Model data yang berisi data yang akan ditampilkan.
  Widget buildCard(LaporanAktivitasModel aktivitasModel) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(context.pd / 2),
        child: Container(
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(context.pd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: EdgeInsets.only(right: context.dp(12)),
                      decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(-1, -1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: context.primaryColor.withOpacity(0.42)),
                            BoxShadow(
                                offset: const Offset(1, 1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: context.primaryColor.withOpacity(0.42))
                          ]),
                      child: Icon(
                        (aktivitasModel.menu == "Buku Teori")
                            ? Icons.book
                            : (aktivitasModel.menu == "Video")
                                ? Icons.play_circle
                                : Icons.menu_book,
                        size: context.dp(24),
                        color: context.background,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aktivitasModel.menu,
                            style: context.text.titleSmall,
                          ),
                          SizedBox(
                            width: context.dw * 0.6,
                            child: Text(
                              aktivitasModel.detail,
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.hintColor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              (aktivitasModel.keluar.isNotEmpty)
                                  ? Row(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          width: 5,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red),
                                        ),
                                        Text(
                                          DateFormat("HH:mm").format(
                                              DateTime.parse(
                                                  aktivitasModel.keluar)),
                                          style: context.text.labelSmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
