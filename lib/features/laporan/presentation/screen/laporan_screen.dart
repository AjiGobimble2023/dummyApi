import 'package:flutter/material.dart';

import '../../../../core/shared/screen/drop_down_action_screen.dart';
import '../../../menu/entity/menu.dart';
import '../../../menu/presentation/provider/menu_provider.dart';
import '../../module/aktivitas/presentation/screen/laporan_aktivitas_screen.dart';
import '../../module/presensi/presentation/screen/laporan_presensi_screen.dart';
import '../../module/quiz/presentation/screen/laporan_quiz_screen.dart';
import '../../module/tobk/presentation/screen/laporan_tryout_screen.dart';
import '../../module/vak/widget/laporan_vak_widget.dart';

class MenuLaporanScreen extends StatefulWidget {
  const MenuLaporanScreen({Key? key}) : super(key: key);

  @override
  State<MenuLaporanScreen> createState() => _MenuLaporanScreenState();
}

class _MenuLaporanScreenState extends State<MenuLaporanScreen> {
  /// Menginisialisasi nilai variabel [_selectedlaporan] dengan nilai pertama dari
  /// ListMenulaporan.
  Menu _selectedLaporan = MenuProvider.listMenuLaporan[0];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropDownActionScreen(
        isWatermarked: false,
        title: 'Laporan',
        dropDownItems: MenuProvider.listMenuLaporan,
        selectedItem: _selectedLaporan,
        onChanged: (newValue) => setState(() => _selectedLaporan = newValue!),
        body: (_selectedLaporan.label == "TOBK")
            ? const LaporanTryoutScreen()
            : (_selectedLaporan.label == "VAK")
                ? const LaporanVakWidget()
                : (_selectedLaporan.label == "Kuis")
                    ? const LaporanQuizScreen()
                    : (_selectedLaporan.label == "Presensi")
                        ? const LaporanPresensiScreen()
                        : const LaporanAktivitasScreen());
  }
}
