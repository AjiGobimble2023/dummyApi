import 'dart:async';
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/ptn_clopedia.dart';
import '../provider/ptn_provider.dart';
import '../../entity/jurusan.dart';
import '../../entity/kampus_impian.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';

class KampusImpianPickerScreen extends StatefulWidget {
  final int pilihanKe;
  final KampusImpian? kampusPilihan;

  const KampusImpianPickerScreen({
    Key? key,
    required this.pilihanKe,
    this.kampusPilihan,
  }) : super(key: key);

  @override
  State<KampusImpianPickerScreen> createState() =>
      _KampusImpianPickerScreenState();
}

class _KampusImpianPickerScreenState extends State<KampusImpianPickerScreen> {
  late final _authOtpProvider = context.read<AuthOtpProvider>();

  String get pilihanKe => (widget.pilihanKe == 1) ? 'pertama' : 'kedua';

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Pilih Kampus Impian',
      body: PtnClopediaWidget(
        isLandscape: !context.isMobile,
        pilihanKe: widget.pilihanKe,
        kampusPilihan: widget.kampusPilihan,
        padding: EdgeInsets.only(
          top: min(32, context.dp(20)),
          left: min(20, context.dp(16)),
          right: min(20, context.dp(16)),
          bottom: (context.isMobile) ? context.dp(120) : 104,
        ),
      ),
      bottomNavigationBar: Selector<PtnProvider, Jurusan?>(
        selector: (_, ptn) => ptn.selectedJurusan,
        builder: (context, selectedJurusan, _) {
          bool isShrink = selectedJurusan == null;

          if (selectedJurusan != null && widget.kampusPilihan != null) {
            isShrink =
                selectedJurusan.idJurusan == widget.kampusPilihan!.idJurusan &&
                    selectedJurusan.idPTN == widget.kampusPilihan!.idPTN;
          }

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
                            child: Text((widget.kampusPilihan == null)
                                ? 'Apakah ini kampus impian\npilihan $pilihanKe kamu Sobat?'
                                : 'Apakah kamu ingin mengubah\npilihan $pilihanKe kamu Sobat?'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            var completer = Completer();
                            context.showBlockDialog(
                                dismissCompleter: completer);

                            await context
                                .read<PtnProvider>()
                                .updateKampusImpian(
                                  pilihanKe: widget.pilihanKe,
                                  noRegistrasi:
                                      _authOtpProvider.userData!.noRegistrasi,
                                  namaPTN: widget.kampusPilihan?.namaPTN,
                                  aliasPTN: widget.kampusPilihan?.aliasPTN,
                                );

                            completer.complete();
                          },
                          child: const Text('Ya'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: (widget.kampusPilihan == null)
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
}
