import 'package:flutter/material.dart';

import '../widget/buku_soal_menu.dart';
import '../../module/timer_soal/presentation/widget/paket_timer_list.dart';
import '../../module/bundel_soal/presentation/widget/bundel_soal_list.dart';
import '../../../menu/entity/menu.dart';
import '../../../menu/presentation/provider/menu_provider.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/screen/drop_down_action_screen.dart';

class BukuSoalScreen extends StatefulWidget {
  /// [idJenisProduk] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final int? idJenisProduk;

  /// [kodeTOB] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final String? kodeTOB;

  /// [kodePaket] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final String? kodePaket;

  /// UNtuk keperluan Pop. Isi dengan route name.
  final String? diBukaDari;

  const BukuSoalScreen({
    Key? key,
    this.idJenisProduk,
    this.kodeTOB,
    this.kodePaket,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<BukuSoalScreen> createState() => _BukuSoalScreenState();
}

class _BukuSoalScreenState extends State<BukuSoalScreen> {
  // SubMenu Buku Sakti
  final List<int> _listJenisProdukSakti = [76, 71, 72];
  // Initial selected menu index
  late final _initialIndex = (widget.idJenisProduk == null ||
          _listJenisProdukSakti.contains(widget.idJenisProduk))
      ? 0
      : MenuProvider.listMenuBukuSoal
          .indexWhere((menu) => menu.idJenis == widget.idJenisProduk);
  // Initial Selected Value
  late Menu _selectedBukuSoal =
      MenuProvider.listMenuBukuSoal[(_initialIndex < 0) ? 0 : _initialIndex];

  @override
  Widget build(BuildContext context) {
    return DropDownActionScreen(
      title: 'Buku Soal',
      dropDownItems: MenuProvider.listMenuBukuSoal,
      selectedItem: _selectedBukuSoal,
      isWatermarked: false,
      onChanged: (newValue) {
        if (newValue?.idJenis != _selectedBukuSoal.idJenis) {
          setState(() => _selectedBukuSoal = newValue!);
        }
      },
      body: _buildBody(),
      floatingActionButton:
          (_selectedBukuSoal.idJenis == 80) ? _leaderboardRacing() : null,
    );
  }

  // FAB Leaderboard Racing
  Widget _leaderboardRacing() {
    return ElevatedButton.icon(
      key: const ValueKey('Leaderboard Racing'),
      onPressed: () {
        Navigator.pushNamed(context, Constant.kRouteLeaderBoardRacing);
      },
      icon: const Icon(Icons.leaderboard_outlined),
      label: const Text('Leaderboard Racing'),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.secondaryContainer,
        foregroundColor: context.onSecondaryContainer,
        padding: EdgeInsets.only(
          right: (context.isMobile) ? context.dp(18) : 24,
          left: (context.isMobile) ? context.dp(14) : 18,
          top: (context.isMobile) ? context.dp(12) : 16,
          bottom: (context.isMobile) ? context.dp(12) : 16,
        ),
      ),
    );
  }

  // TODO: Lengkapi menu soal lainnya
  Widget _buildBody() {
    switch (_selectedBukuSoal.idJenis) {
      case 0:
        return BukuSaktiWidget(
          idJenisProduk: widget.idJenisProduk,
          kodeTOB: widget.kodeTOB,
          kodePaket: widget.kodePaket,
          diBukaDari: widget.diBukaDari,
        );
      case 77: // Paket Intensif
      case 78: // Paket Soal Koding
      case 79: // Pendalaman Materi
      case 82: // Soal Referensi
        return BundelSoalList(
          idJenisProduk: _selectedBukuSoal.idJenis,
          namaJenisProduk: _selectedBukuSoal.namaJenisProduk,
        );
      case 80: // Racing
      case 16: // Kuis
        return PaketTimerList(
          idJenisProduk: _selectedBukuSoal.idJenis,
          namaJenisProduk: _selectedBukuSoal.namaJenisProduk,
          kodeTOB: widget.kodeTOB,
          kodePaket: widget.kodePaket,
        );
      default:
        return Center(
            child: Text('Menu ${_selectedBukuSoal.label} belum tersedia.'));
    }
  }
}
