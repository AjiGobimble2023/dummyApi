import 'dart:async';
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/simulasi_pilihan_provider.dart';
import '../../model/pilihan_model.dart';
import '../../../ptnclopedia/entity/jurusan.dart';
import '../../../ptnclopedia/presentation/widget/ptn_clopedia.dart';
import '../../../ptnclopedia/presentation/provider/ptn_provider.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';

class SimulasiPilihanFormScreen extends StatefulWidget {
  final PilihanModel pilihanModel;

  const SimulasiPilihanFormScreen({Key? key, required this.pilihanModel})
      : super(key: key);

  @override
  State<SimulasiPilihanFormScreen> createState() =>
      _SimulasiPilihanFormScreenState();
}

class _SimulasiPilihanFormScreenState extends State<SimulasiPilihanFormScreen> {
  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Pilih PTN dan Jurusan',
      subTitle: 'Prioritas ke-${widget.pilihanModel.prioritas}',
      jumlahBarisTitle: 2,
      body: PtnClopediaWidget(
        isLandscape: !context.isMobile,
        isSimulasi: true,
        pilihanKe: int.parse(widget.pilihanModel.prioritas!),
        kampusPilihan: null,
        padding: EdgeInsets.only(
          top: min(32, context.dp(20)),
          left: min(20, context.dp(16)),
          right: min(20, context.dp(16)),
          bottom: (context.isMobile) ? context.dp(120) : 104,
        ),
      ),
      bottomNavigationBar: Selector<PtnProvider, Jurusan?>(
        selector: (_, ptn) => ptn.selectedJurusan,
        builder: (bottomCtx, selectedJurusan, _) {
          bool isShrink = selectedJurusan == null;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              final position = Tween<Offset>(
                begin: const Offset(0, -100),
                end: const Offset(0, 0),
              ).animate(animation);
              return SlideTransition(
                position: position,
                child: child,
              );
            },
            child: (isShrink)
                ? const SizedBox.shrink()
                : Container(
                    constraints: BoxConstraints(maxWidth: min(650, context.dw)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                        color: context.background,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, -1),
                            blurRadius: 14,
                          )
                        ]),
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text((widget.pilihanModel.universitasModel ==
                                    null)
                                ? 'Apakah ini PTN impian\npilihan ${widget.pilihanModel.prioritas} kamu Sobat?'
                                : 'Apakah kamu ingin mengubah\npilihan PTN ${widget.pilihanModel.prioritas} kamu Sobat?'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            var completer = Completer();
                            context.showBlockDialog(
                                dismissCompleter: completer);
                            await simpanPilihanPTN(context, selectedJurusan);

                            completer.complete();
                          },
                          child: const Text('Ya'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: (widget.pilihanModel.universitasModel
                                      ?.jurusanId ==
                                  null)
                              ? const Text('Tidak')
                              : const Text('Bukan'),
                        )
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// [simpanPilihanPTN] adalah fungsi yang digunakan untuk menyimpan pilihan kuliah pengguna.
  ///
  /// Args:
  ///   context (BuildContext): BuildContext
  ///   selectedJurusan (Jurusan): Objek SelectedJurusan adalah objek yang berisi data universitas yang dipilih.
  simpanPilihanPTN(BuildContext context, Jurusan selectedJurusan) async {
    await context.read<SimulasiPilihanProvider>().savePilihan(
          noRegistrasi: gNoRegistrasi,
          jurusanId: selectedJurusan.idJurusan.toString(),
          prioritas: widget.pilihanModel.prioritas.toString(),
          status: (int.parse(widget.pilihanModel.status!) < 3)
              ? (int.parse(widget.pilihanModel.status!) + 1).toString()
              : "fix",
        );

    if (!mounted) return;
    await context
        .read<SimulasiPilihanProvider>()
        .loadPilihan(noRegistrasi: gNoRegistrasi);
  }
}
