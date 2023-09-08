import 'dart:async';
import 'dart:developer' as logger show log;

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'rencana_picker_screen.dart';
import '../widgets/menu_rencana_picker.dart';
import '../provider/rencana_belajar_provider.dart';
import '../../model/rencana_menu.dart';
import '../../model/rencana_belajar.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/shared/screen/basic_screen.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/card/custom_card.dart';
import '../../../../core/shared/widget/animation/hero_dialog_route.dart';

class RencanaEditorScreen extends StatefulWidget {
  final RencanaBelajar? rencanaBelajar;

  const RencanaEditorScreen({
    super.key,
    this.rencanaBelajar,
  });

  @override
  State<RencanaEditorScreen> createState() => _RencanaEditorScreenState();
}

class _RencanaEditorScreenState extends State<RencanaEditorScreen> {
  late final RencanaBelajarProvider _rencanaBelajarProvider =
      context.read<RencanaBelajarProvider>();
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  late final String _noRegistrasi = _authProvider.userData!.noRegistrasi;

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: context.read<RencanaBelajarProvider>().editorTitle,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: _rencanaBelajarProvider.listMenuRencana.isEmpty
            ? BasicEmpty(
                imageUrl: 'ilustrasi_rencana_belajar.png'.illustration,
                title: context.read<RencanaBelajarProvider>().editorTitle,
                subTitle: 'Terjadi Kesalahan',
                emptyMessage: 'Pilihan menu rencana belajar gagal disiapkan, '
                    'coba buka kembali halaman Rencana Belajar.',
              )
            : _getAppointmentEditor(context),
      ),
    );
  }

  Future<void> _onClickBelajarSekarang(
      {required RencanaBelajar selectedRencana}) async {
    if (kDebugMode) {
      logger.log(
          'RENCANA_EDITOR_SCREEN-OnClickBelajarSekarang: ${selectedRencana.argument}');
    }
    await _rencanaBelajarProvider.bukaScreen(
        argumentRencana: selectedRencana.argument);
  }

  Future<void> _onClickDateTimePicker(
    BuildContext context, {
    required DateTime initialDate,
    required bool isStart,
    required bool isDatePicker,
  }) async {
    var rencanaBelajar = context.read<RencanaBelajarProvider>();

    if (isDatePicker) {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        confirmText: 'Pilih',
        cancelText: 'Batal',
        firstDate:
            (!isStart) ? rencanaBelajar.startRencanaDate : DateTime(2021),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null && pickedDate != initialDate) {
        if (isStart) {
          rencanaBelajar.startRencanaDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            rencanaBelajar.startRencanaDate.hour,
            rencanaBelajar.startRencanaDate.minute,
          );
        } else {
          rencanaBelajar.endRencanaDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            rencanaBelajar.endRencanaDate.hour,
            rencanaBelajar.endRencanaDate.minute,
          );
        }
      }
    } else {
      // Time Picker
      final initialTime = TimeOfDay.fromDateTime(initialDate);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        cancelText: 'Batal',
        confirmText: 'Pilih',
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        initialTime: initialTime,
      );

      if (pickedTime != null && pickedTime != initialTime) {
        if (isStart) {
          rencanaBelajar.startRencanaDate = DateTime(
            rencanaBelajar.startRencanaDate.year,
            rencanaBelajar.startRencanaDate.month,
            rencanaBelajar.startRencanaDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          rencanaBelajar.endRencanaDate = DateTime(
            rencanaBelajar.endRencanaDate.year,
            rencanaBelajar.endRencanaDate.month,
            rencanaBelajar.endRencanaDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }
    }
  }

  Future<void> _openRencanaSelector(
      BuildContext context, int selectedMenuIndex) async {
    final RencanaBelajarProvider rencanaProvider =
        context.read<RencanaBelajarProvider>();
    final RencanaMenu selectedMenu =
        _rencanaBelajarProvider.listMenuRencana[selectedMenuIndex];

    Map<String, dynamic>? intentArgument =
        await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => RencanaPickerScreen(
          idJenisProduk: selectedMenu.idJenisProduk,
          namaJenisProduk: selectedMenu.namaJenisProduk,
          menuLabel: selectedMenu.label,
        ),
      ),
    );

    if (kDebugMode) {
      logger.log(
          'RENCANA_EDITOR_SCREEN-RencanaSelector: Pop Argument >> $intentArgument');
    }

    if (intentArgument != null) {
      final newRencana = RencanaBelajar(
        idRencana: (widget.rencanaBelajar == null)
            ? 'Temp-Rencana'
            : widget.rencanaBelajar!.idRencana,
        noRegistrasi: _authProvider.userData!.noRegistrasi,
        menuLabel: selectedMenu.label,
        keterangan: intentArgument['keterangan'],
        startRencana: rencanaProvider.startRencanaDate,
        endRencana: rencanaProvider.endRencanaDate,
        createdDate: DateTime.now(),
        isDone: false,
        idJenisProduk: selectedMenu.idJenisProduk,
        namaJenisProduk: selectedMenu.namaJenisProduk,
        backgroundColor: selectedMenu.warna,
        argument: intentArgument,
        lastUpdate: DateTime.now(),
      );
      // _rencanaBelajarProvider.argumentResult = intentArgument;
      _rencanaBelajarProvider.selectedRencana = newRencana;
    }
  }

  Future<void> _simpanRencana(
    BuildContext context,
    RencanaBelajar? selectedRencana,
  ) async {
    var completer = Completer();
    var rencanaBelajarProvider = context.read<RencanaBelajarProvider>();
    int selectedMenuIndex = rencanaBelajarProvider.selectedMenuIndex;

    try {
      if (selectedMenuIndex == 0) return;
      context.showBlockDialog(dismissCompleter: completer);

      var response = await rencanaBelajarProvider.simpanRencanaBelajar(
        noRegistrasi: _noRegistrasi,
        isSimpan: widget.rencanaBelajar == null,
      );

      if (kDebugMode) {
        logger.log(
            'RENCANA_EDITOR_SCREEN-SimpanRencana: Status >> ${response['status']}');
      }
      completer.complete();
      if (response['status']) {
        await Future.delayed(const Duration(seconds: 2, milliseconds: 300))
            .then((value) => Navigator.pop(context));
      }
    } catch (e) {
      if (!completer.isCompleted) completer.complete();
      if (kDebugMode) {
        logger.log('RENCANA_EDITOR_SCREEN-SimpanRencana: Error >> $e');
      }
    }
  }

  Widget _getAppointmentEditor(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
      children: <Widget>[
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.only(right: context.dp(12)),
              decoration: BoxDecoration(
                color: context.secondaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryColor.withOpacity(0.42)),
                  BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryColor.withOpacity(0.42))
                ],
              ),
              child: Icon(
                Icons.date_range_rounded,
                size: 24,
                color: context.onSecondary,
                semanticLabel: 'ic_date_range_rencana',
              ),
            ),
            Expanded(
              child: Text(
                'Mau mulai belajar kapan Sobat?',
                style: context.text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Divider(height: 24, thickness: 1, color: Colors.black12),
        ..._buildDatePickerButton(context, isStart: true),
        ..._buildDatePickerButton(context, isStart: false),
        const Divider(height: 4, thickness: 1, color: Colors.black12),
        _buildMenuPicker(),
        Selector<RencanaBelajarProvider, bool>(
          selector: (_, rencana) =>
              rencana.selectedMenuRencana == 'pilih' ||
              rencana.selectedRencana == null,
          shouldRebuild: (prev, next) => prev != next,
          builder: (_, isNotExist, __) {
            if (kDebugMode) {
              logger.log(
                  'RENCANA_EDITOR_SCREEN-SelectorRencanaItem: isNotExist >> $isNotExist');
            }

            if (isNotExist) return const SizedBox.shrink();

            return CustomCard(
              elevation: 3,
              borderRadius: BorderRadius.circular(24),
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Hero(
                    tag: 'icon_rencana_menu',
                    transitionOnUserGestures: true,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: context.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(-1, -1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color:
                                    context.secondaryColor.withOpacity(0.42)),
                            BoxShadow(
                                offset: const Offset(1, 1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: context.secondaryColor.withOpacity(0.42))
                          ],
                        ),
                        child: Icon(
                          Icons.task_alt_rounded,
                          size: 24,
                          color: context.onSecondary,
                          semanticLabel: 'ic_date_range_rencana',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Selector<RencanaBelajarProvider, String>(
                          selector: (_, rencana) =>
                              rencana.selectedRencana?.menuLabel ??
                              'Pilih Menu',
                          builder: (_, rencanaLabel, __) => Text(
                            rencanaLabel,
                            style: context.text.titleMedium,
                          ),
                        ),
                        const Divider(thickness: 1, color: Colors.black12),
                        Selector<RencanaBelajarProvider, String>(
                          selector: (_, rencana) =>
                              rencana.selectedRencana?.keterangan ??
                              'Pilih menu terlebih dahulu',
                          builder: (_, deskripsiRencana, __) => Text(
                            deskripsiRencana,
                            style: context.text.bodySmall?.copyWith(
                              color: context.onBackground.withOpacity(0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Divider(height: 32, thickness: 1, color: Colors.black12),
        Selector<RencanaBelajarProvider, RencanaBelajar?>(
          selector: (_, rencana) => rencana.selectedRencana,
          builder: (context, selectedRencana, child) =>
              (widget.rencanaBelajar != null)
                  ? Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: OutlinedButton(
                            onPressed: (selectedRencana == null)
                                ? null
                                : () async => await _onClickBelajarSekarang(
                                    selectedRencana: selectedRencana),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Belajar Sekarang'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: (selectedRencana == null)
                                ? null
                                : () async => await _simpanRencana(
                                    context, selectedRencana),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: (selectedRencana == null)
                          ? null
                          : () async =>
                              await _simpanRencana(context, selectedRencana),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Simpan'),
                    ),
        ),
      ],
    );
  }

  List<Widget> _buildDatePickerButton(
    BuildContext context, {
    required bool isStart,
  }) {
    return [
      Text(
        (isStart) ? 'Mulai' : 'Selesai',
        style: context.text.bodyLarge?.copyWith(
          color: context.hintColor,
        ),
      ),
      Selector<RencanaBelajarProvider, DateTime>(
        selector: (_, rencana) =>
            (isStart) ? rencana.startRencanaDate : rencana.endRencanaDate,
        shouldRebuild: (prev, next) =>
            prev.year != next.year ||
            prev.month != next.month ||
            prev.day != next.day ||
            prev.hour != next.hour ||
            prev.minute != next.minute,
        builder: (context, rencanaDate, _) => Padding(
          padding: EdgeInsets.only(
            top: 8,
            left: 14,
            bottom: (isStart) ? 10 : 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 0,
                    child: InkWell(
                      onTap: () async => _onClickDateTimePicker(
                        context,
                        initialDate: rencanaDate,
                        isStart: isStart,
                        isDatePicker: true,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Text(
                          DataFormatter.dateTimeToString(
                              rencanaDate, 'EEEE, dd MMM y'),
                          style: context.text.titleSmall,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 0,
                    child: InkWell(
                      onTap: () async => _onClickDateTimePicker(
                        context,
                        initialDate: rencanaDate,
                        isStart: isStart,
                        isDatePicker: false,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Text(
                          DataFormatter.dateTimeToString(
                              rencanaDate, 'HH:mm a'),
                          style: context.text.titleSmall,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildMenuPicker() {
    var listMenuRencana = _rencanaBelajarProvider.listMenuRencana;

    return Selector<RencanaBelajarProvider, int>(
      selector: (_, rencana) => rencana.selectedMenuIndex,
      builder: (context, currentMenuIndex, _) => Padding(
        padding: const EdgeInsets.only(top: 16, left: 6, bottom: 16),
        child: Row(
          children: [
            Hero(
              tag: 'rencana_belajar_menu_title',
              transitionOnUserGestures: true,
              child: Text(
                'Mau belajar apa Sobat?',
                style: context.text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Hero(
              tag: 'selected_menu_label',
              transitionOnUserGestures: true,
              child: Container(
                width: context.dw * 0.3,
                height: context.dp(42),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                alignment: Alignment.center,
                child: Material(
                  elevation: 0,
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () async {
                      final selectedMenuIndex =
                          await Navigator.of(context).push<int>(
                        HeroDialogRoute(
                          builder: (context) => MenuRencanaPicker(
                            selectedIndex: currentMenuIndex,
                            daftarMenuRencana: listMenuRencana,
                          ),
                        ),
                      );

                      if (kDebugMode) {
                        logger.log('RENCANA_EDITOR_SCREEN-PilihMenu: '
                            'selected menu index >> $selectedMenuIndex '
                            '(${selectedMenuIndex != null}, ${(selectedMenuIndex ?? 0) > 0})');
                      }

                      if (selectedMenuIndex != null) {
                        _rencanaBelajarProvider.selectedMenuIndex =
                            selectedMenuIndex;

                        if (selectedMenuIndex > 0) {
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          // ignore: use_build_context_synchronously
                          _openRencanaSelector(context, selectedMenuIndex);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(11),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            listMenuRencana[currentMenuIndex].label,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
