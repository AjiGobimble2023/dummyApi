import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../buku/presentation/widget/buku_list.dart';

import '../../../soal/module/timer_soal/presentation/widget/tob_list.dart';
import '../../../video/presentation/widget/jadwal/video_jadwal_widget.dart';
import '../../../soal/module/paket_soal/presentation/widget/paket_soal_list.dart';
import '../../../soal/module/timer_soal/presentation/widget/paket_timer_list.dart';
import '../../../soal/module/bundel_soal/presentation/widget/bundel_soal_list.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/screen/basic_screen.dart';
import '../../../../core/shared/widget/empty/no_data_found.dart';

class RencanaPickerScreen extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final String menuLabel;

  const RencanaPickerScreen({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.menuLabel,
  }) : super(key: key);

  @override
  State<RencanaPickerScreen> createState() => _RencanaPickerScreenState();
}

class _RencanaPickerScreenState extends State<RencanaPickerScreen> {
  @override
  void dispose() {
    if (kDebugMode) {
      logger.log('RENCANA_PICKER_SCREEN: Disposed');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      logger.log('RENCANA_PICKER_SCREEN: Build');
    }
    return BasicScreen(
      title: widget.menuLabel,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (widget.idJenisProduk) {
      case 76: // Latihan Ekstra
      case 77: // Paket Intensif
      case 78: // Paket Soal Koding
      case 79: // Pendalaman Materi
      case 82: // Soal Referensi
        // Bundel Soal List Bisa langsung intent ke SoalBasicScreen.
        return BundelSoalList(
          idJenisProduk: widget.idJenisProduk,
          namaJenisProduk: widget.namaJenisProduk,
          isRencanaPicker: true,
        );
      case 65: // VAK, Constant.kRouteProfilingScreen
      case 71: // Empati Mandiri, Constant.kRouteBukuSoalScreen
      case 72: // Empati Wajib, Constant.kRouteBukuSoalScreen
        // Paket Soal List Bisa langsung intent ke SoalBasicScreen.
        return PaketSoalList(
          idJenisProduk: widget.idJenisProduk,
          namaJenisProduk: widget.namaJenisProduk,
          isRencanaPicker: true,
          diBukaDari: (widget.idJenisProduk == 65)
              ? Constant.kRouteProfilingScreen
              : Constant.kRouteBukuSoalScreen,
        );
      case 12: // GO-Assessment
      case 16: // Kuis
      case 80: // Racing Soal
        // Paket Timer List hanya akan menuju ke Screen sesuai idJenisProduk.
        return PaketTimerList(
          idJenisProduk: widget.idJenisProduk,
          namaJenisProduk: widget.namaJenisProduk,
          isRencanaPicker: true,
        );
      case 25: // TOBK
        // Paket Timer List hanya akan menuju ke Screen TOBK.
        return TOBList(
          idJenisProduk: widget.idJenisProduk,
          namaJenisProduk: widget.namaJenisProduk,
          isRencanaPicker: true,
        );
      case 88: // Video Teori (Jadwal)
        // Video Bisa langsung menuju ke Video Player.
        return const VideoJadwalWidget(isRencanaPicker: true);
      case 46: // Buku Rumus
      case 59: // Buku Teori
        // Buku Bisa langsung menuju ke Content Teori.
        return BukuList(
          idJenisProduk: widget.idJenisProduk,
          namaJenisProduk: widget.namaJenisProduk,
          isRencanaPicker: true,
        );
      default: // If selected menu not found
        return NoDataFoundWidget(
          imageUrl: 'ilustrasi_rencana_belajar.png'.illustration,
          subTitle: 'Rencana Belajar Picker',
          emptyMessage: 'Menu ${widget.menuLabel} tidak tersedia.',
        );
    }
  }
}
