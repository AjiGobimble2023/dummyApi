import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../provider/laporan_tryout_provider.dart';
import '../widget/laporan_tryout_chart_widget.dart';
import '../../model/laporan_tryout_tob_model.dart';
import '../../../../../ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';

class LaporanTryoutScreen extends StatefulWidget {
  const LaporanTryoutScreen({Key? key}) : super(key: key);

  @override
  State<LaporanTryoutScreen> createState() => _LaporanTryoutScreenState();
}

class _LaporanTryoutScreenState extends State<LaporanTryoutScreen> {
  /// [_authProvider] merupakan variabel provider untuk memanggil data login user
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  /// [_scrollController] merupakan variabel untuk controller scroll bottomsheet pilihan list jenis Tryout
  final ScrollController _scrollController = ScrollController();

  /// Kumpulan variable data user
  late final String _noRegistrasi = _authProvider.userData!.noRegistrasi;
  late final String _userType = _authProvider.userData!.siapa;
  late final String _idSekolahKelas = _authProvider.userData!.idSekolahKelas;
  late final String _tingkatKelas = _authProvider.userData!.tingkatKelas;
  int? _idJurusanPilihan1, _idJurusanPilihan2;

  /// [_selectedIndex] merupakan variabel untuk menampung data index jenis TO yang dipilih
  int _selectedIndex = 0;
  String? _jenisTO;

  /// [_opsiJenisTO] merupakan variabel untuk menampung data list TO
  final List<Map<String, String?>> _opsiJenisTO = [
    {"nama": "Pilih Jenis", "jenisTO": null},
    {"nama": "UTBK", "jenisTO": "UTBK"},
    {"nama": "Ujian Sekolah", "jenisTO": "US"},
    {"nama": "ANBK", "jenisTO": "ANBK"},
    {"nama": "STAN", "jenisTO": "STAN"},
  ];

  @override
  void initState() {
    super.initState();

    _loadKampusImpian();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadKampusImpian() async {
    if (!HiveHelper.isBoxOpen<KampusImpian>(
        boxName: HiveHelper.kKampusImpianBox)) {
      await HiveHelper.openBox<KampusImpian>(
          boxName: HiveHelper.kKampusImpianBox);
    }

    _idJurusanPilihan1 = HiveHelper.getKampusImpian(pilihanKe: 1)?.idJurusan ??
        _authProvider.userData!.idJurusanPilihan1;
    _idJurusanPilihan2 = HiveHelper.getKampusImpian(pilihanKe: 2)?.idJurusan ??
        _authProvider.userData!.idJurusanPilihan2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildJenisTOPicker(),

        /// Widget untuk menampilkan laporan data TryOut
        Expanded(
          child: Container(
            child: (_jenisTO != null)
                ? FutureBuilder<List<LaporanTryoutTobModel>>(
                    future:
                        context.read<LaporanTryoutProvider>().loadLaporanTryout(
                              noRegistrasi: _noRegistrasi,
                              idSekolahKelas: _idSekolahKelas,
                              userType: _userType,
                              jenisTO: _jenisTO!,
                              idJurusanPilihan1: _idJurusanPilihan1,
                              idJurusanPilihan2: _idJurusanPilihan2,
                              tingkatKelas: _tingkatKelas,
                            ),
                    builder: (context, snap) {
                      bool isLoading =
                          snap.connectionState == ConnectionState.waiting;
                      bool hasError = snap.hasError;
                      bool emptyData = snap.data?.isEmpty ?? true;

                      if (isLoading) {
                        return (context.isMobile)
                            ? _buildShimmer()
                            : const LoadingWidget();
                      }

                      if (hasError) {
                        return _buildDataNotfound(
                          context,
                          imageUrl: 'ilustrasi_laporan_tobk.png'.illustration,
                          title: 'Laporan TOBK',
                          subtitle: '${snap.error}',
                          emptyMessage: snap.error.toString(),
                        );
                      }

                      if (emptyData) {
                        return _buildDataNotfound(
                          context,
                          imageUrl: 'ilustrasi_laporan_tobk.png'.illustration,
                          title: 'Laporan TOBK',
                          subtitle: 'Ayo ikuti Tryout dahulu Sobat',
                          emptyMessage:
                              'Belum ada Try Out $_jenisTO yang sudah sobat kerjakan',
                        );
                      }

                      return SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 12,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Column(
                            children: [
                              _buildTryOutLineChart(snap),
                              ..._buildTryoutItem(snap.data!),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : _buildDataNotfound(
                    context,
                    imageUrl: 'ilustrasi_laporan_tobk.png'.illustration,
                    title: 'Laporan TOBK',
                    subtitle: "Ayo pantau hasil Tryout Sobat",
                    emptyMessage: "Pilih jenis Tryout sobat terlebih dahulu",
                  ),
          ),
        ),
      ],
    );
  }

  Future<int?> _showModalJenisTO() async {
    return await showModalBottomSheet<int>(
        context: context,
        constraints: BoxConstraints(maxWidth: min(650, context.dw)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              top: context.dp(24),
              bottom: context.dp(20),
              left: context.dp(18),
              right: context.dp(18),
            ),
            child: SizedBox(
              width: context.dw,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(14),
                child: ListView.separated(
                  shrinkWrap: true,
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _opsiJenisTO.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        Navigator.of(context).pop(_selectedIndex);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "${_opsiJenisTO[index]['nama']}",
                            style: context.text.bodyLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        });
  }

  /// [_buildDataNotfound] widget untuk menampilkan ilustrasi
  /// dan message saat data tidak ditemukan
  SingleChildScrollView _buildDataNotfound(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String subtitle,
    required String emptyMessage,
  }) {
    return SingleChildScrollView(
      child: SizedBox(
        height: (context.isMobile) ? context.dh * 0.7 : context.dh * 1.2,
        child: BasicEmpty(
          shrink: !context.isMobile,
          imageUrl: imageUrl,
          title: title,
          subTitle: subtitle,
          emptyMessage: emptyMessage,
        ),
      ),
    );
  }

  /// [_buildTryOutLineChart] merupakan widget untuk menampilkan LineChart Nilai TO
  Container _buildTryOutLineChart(
      AsyncSnapshot<List<LaporanTryoutTobModel>> snap) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: LaporanTryoutChartWidget(
        jenisTO: _jenisTO!,
        listTryout: snap.data!,
      ),
    );
  }

  /// [_buildJenisTOPicker] widget untuk memilih jenis Try out
  Padding _buildJenisTOPicker() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: GestureDetector(
        child: Container(
            decoration: BoxDecoration(
                borderRadius: gDefaultShimmerBorderRadius,
                border: Border.all(color: context.disableColor)),
            child: ListTile(
              title: Text('Jenis Tryout', style: context.text.bodyMedium),
              subtitle: Text(
                _opsiJenisTO[_selectedIndex]['nama']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
            )),
        onTap: () async {
          final selectedType = await _showModalJenisTO();

          if (selectedType != null) {
            setState(() {
              _selectedIndex = selectedType;
              _jenisTO = _opsiJenisTO[_selectedIndex]['jenisTO'];
            });
          }
        },
      ),
    );
  }

  /// [_buildTryoutItem] widget untuk menampilkan data list item tryout yang telah dikerjakan
  List<Widget> _buildTryoutItem(List<LaporanTryoutTobModel> listTryout) {
    if (kDebugMode) {
      logger.log('LIST TRYOUT >> $listTryout');
    }
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "List Tryout",
            style: context.text.titleMedium,
          ),
          const Expanded(
            child: Divider(
                thickness: 1, indent: 8, endIndent: 8, color: Colors.black26),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      ...listTryout.map(
        (val) {
          if (kDebugMode) {
            logger.log('TRYOUT ITEM >> $val');
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Constant.kRouteLaporanTryOutNilai,
                    arguments: {
                      "penilaian": val.penilaian,
                      "kodeTOB": val.kode,
                      'namaTOB': val.nama,
                      'isExists': val.isExists,
                      'link': val.link,
                      'jenisTO': _opsiJenisTO[_selectedIndex]['jenisTO'],
                      'showEPB': true,
                    },
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.tertiaryColor)),
                    child: Icon(
                      Icons.donut_small_rounded,
                      color: context.tertiaryColor,
                    ),
                  ),
                  title: Text(val.nama),
                  subtitle: Text(
                    DateFormat.yMMMMd('ID').format(
                      DateTime.parse(val.tanggalAkhir),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
              const Divider(),
            ],
          );
        },
      ).toList(),
    ];
  }

  /// [_buildShimmer] widget loading shimmer laporan tryout
  Padding _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: context.dp(30)),
        itemBuilder: (_, index) => Column(
          children: [
            if (index == 0)
              Column(
                children: [
                  ShimmerWidget.rounded(
                      borderRadius: gDefaultShimmerBorderRadius,
                      width: context.dw,
                      height: context.dp(250)),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ListTile(
              leading: ShimmerWidget.rounded(
                  borderRadius: gDefaultShimmerBorderRadius,
                  width: context.dp(50),
                  height: context.dp(50)),
              title: Padding(
                padding: EdgeInsets.only(right: context.dw * 0.3),
                child: ShimmerWidget.rounded(
                    borderRadius: gDefaultShimmerBorderRadius,
                    width: context.dp(80),
                    height: context.dp(18)),
              ),
              subtitle: ShimmerWidget.rounded(
                  borderRadius: gDefaultShimmerBorderRadius,
                  width: context.dp(180),
                  height: context.dp(12)),
              trailing: ShimmerWidget.rounded(
                  borderRadius: gDefaultShimmerBorderRadius,
                  width: context.dp(32),
                  height: context.dp(32)),
            ),
          ],
        ),
        separatorBuilder: (_, index) => const Divider(),
        itemCount: 5,
      ),
    );
  }
}
