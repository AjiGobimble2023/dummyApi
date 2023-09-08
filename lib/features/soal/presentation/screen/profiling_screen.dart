import 'package:flutter/material.dart';

import '../../../laporan/module/vak/widget/laporan_vak_widget.dart';
import '../../module/paket_soal/presentation/widget/paket_soal_list.dart';
import '../../module/timer_soal/presentation/widget/paket_timer_list.dart';
import '../../../menu/entity/menu.dart';
import '../../../menu/presentation/provider/menu_provider.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/screen/drop_down_action_screen.dart';

/// [ProfilingScreen] merupakan screen utama dari VAK dan GOA sebagai profiling belajar siswa.
class ProfilingScreen extends StatefulWidget {
  final int? idJenisProduk;

  const ProfilingScreen({Key? key, this.idJenisProduk}) : super(key: key);

  @override
  State<ProfilingScreen> createState() => _ProfilingScreenState();
}

class _ProfilingScreenState extends State<ProfilingScreen> {
  late final int _initialMenuIndex =
      (widget.idJenisProduk != null && widget.idJenisProduk == 65) ? 1 : 0;
  // Initial Selected Value
  late Menu _selectedProfiling =
      MenuProvider.listMenuProfiling[_initialMenuIndex];

  @override
  Widget build(BuildContext context) {
    return DropDownActionScreen(
      title: 'Profiling',
      dropDownItems: MenuProvider.listMenuProfiling,
      selectedItem: _selectedProfiling,
      isWatermarked: false,
      onChanged: (newValue) {
        if (newValue?.idJenis != _selectedProfiling.idJenis) {
          setState(() => _selectedProfiling = newValue!);
        }
      },
      body: _buildBody(),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.centerRight,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween(
            begin: const Offset(2.0, 0.0),
            end: const Offset(0.0, 0.0),
          ).animate(anim),
          child: child,
        ),
        child: (_selectedProfiling.idJenis == 12)
            ? const SizedBox()
            : ElevatedButton.icon(
                key: const ValueKey('LAPORAN_VAK_BUTTON'),
                onPressed: _onClickLaporanVAK,
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Hasil Tes VAK'),
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
              ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedProfiling.idJenis) {
      case 12: // GOA
        return PaketTimerList(
            idJenisProduk: _selectedProfiling.idJenis,
            namaJenisProduk: _selectedProfiling.namaJenisProduk);
      case 65: // VAK
        return PaketSoalList(
          idJenisProduk: _selectedProfiling.idJenis,
          namaJenisProduk: _selectedProfiling.namaJenisProduk,
          diBukaDari: Constant.kRouteProfilingScreen,
        );
      default:
        return Center(
            child: Text('Menu ${_selectedProfiling.label} belum tersedia.'));
    }
  }

  Future<void> _onClickLaporanVAK() async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(minHeight: 10, maxHeight: context.dh * 0.9),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      backgroundColor: context.background,
      builder: (context) {
        childWidget ??= LaporanVakWidget(isLandscape: !context.isMobile);
        return childWidget!;
      },
    );
  }
}
