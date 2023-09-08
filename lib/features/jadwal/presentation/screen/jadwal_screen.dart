import 'dart:async';
import 'dart:developer' as logger show log;

import 'package:flash/flash_helper.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../provider/jadwal_provider.dart';
import '../widget/jadwal_list_widget.dart';
import '../../../menu/entity/menu.dart';
import '../../../profile/entity/scanner_type.dart';
import '../../../menu/presentation/provider/menu_provider.dart';
import '../../../standby/presentation/widget/standby_widget.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../video/presentation/widget/jadwal/video_jadwal_widget.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/util/custom_scan_qr_util.dart';
import '../../../../core/util/custom_location_util.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/screen/drop_down_action_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({Key? key}) : super(key: key);

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  Menu _selectedJadwal = MenuProvider.listMenuJadwal[0];

  late final _authProvider = context.read<AuthOtpProvider>();
  late final String _noRegistrasi = _authProvider.userData?.noRegistrasi ?? '';
  late final List<String> _idKelasGO = _authProvider.userData?.idKelasGO ?? [];

  @override
  void dispose() {
    if (HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      HiveHelper.closeBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    super.dispose();
  }

  Future<bool> _openSettingBox() async {
    if (!HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      await HiveHelper.openBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    return HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox);
  }

  @override
  Widget build(BuildContext context) {
    return DropDownActionScreen(
      isWatermarked: false,
      title: 'Jadwal & Video',
      dropDownItems: MenuProvider.listMenuJadwal,
      selectedItem: _selectedJadwal,
      onChanged: (newValue) {
        setState(() => _selectedJadwal = newValue!);
      },
      body: (_selectedJadwal.label == "Jadwal")
          ? const JadwalListWidget()
          : (_selectedJadwal.label == "Video")
              ? const VideoJadwalWidget()
              : const StandbyWidget(),
      floatingActionButton: FutureBuilder<bool>(
        future: _openSettingBox(),
        builder: (_, snapshot) => (snapshot.connectionState ==
                ConnectionState.waiting)
            ? ShimmerWidget.rounded(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(12),
              )
            : ValueListenableBuilder<Box<ScannerType>>(
                valueListenable: HiveHelper.listenableQRScanner(),
                builder: (_, box, qrIcon) => AnimatedSwitcher(
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
                  child: (_selectedJadwal.label != 'Video' &&
                          _authProvider.isSiswa)
                      ? FloatingActionButton(
                          onPressed: () async => await _scanQRPresensi(box.get(
                            HiveHelper.kScannerKey,
                            defaultValue: ScannerType.mobileScanner,
                          )!),
                          child: qrIcon,
                        )
                      : const SizedBox(),
                ),
                child: const Icon(Icons.qr_code_scanner, size: 30),
              ),
      ),
    );
  }

  Future<void> _scanQRPresensi(ScannerType scannerPilihan) async {
    var completer = Completer();
    try {
      final jadwalProvider = context.read<JadwalProvider>();
      String message = 'Berhasil melakukan kehadiran';

      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-OnClickQrScanner: START');
      }

      final Map dataQR =
          await CustomScanQrUtils.scanBarcode(context, scannerPilihan);

      // ignore: use_build_context_synchronously
      context.showBlockDialog(dismissCompleter: completer);
      if (kDebugMode) {
        logger.log('SCANNER RESULT >> $dataQR\n'
            'cek data from ${dataQR['from']}\n'
            'cek data isTst ${dataQR['from'] == 'tst'}');
      }

      if (!['teaching', 'tst'].contains(dataQR['from'])) {
        completer.complete();
        throw DataException(message: "QRCode tidak sesuai");
      }

      final String waktuPresensi = DataFormatter.formatLastUpdate();

      if (dataQR['from'] == 'teaching') {
        final coordinate = await CustomLocationUtil.getLocation();
        final tanggalPresensi = waktuPresensi.split(' ')[0];
        int flag = 0;
        String idSekolahKelas = "";

        for (int i = 0; i < _idKelasGO.length; i++) {
          if (kDebugMode) {
            logger.log(
                'JADWAL_LIST_WIDGET-OnClickQrScanner(teaching): Class Id >> '
                '$i ${dataQR['class_id']} | $i ${_idKelasGO[i]}');
          }

          if (dataQR['class_id'] == _idKelasGO[i]) {
            flag++;
            idSekolahKelas = _idKelasGO[i];
          }
        }
        final Map<String, dynamic> dataPresensi = {
          "idRencana": dataQR['uid'],
          "idGedung": dataQR['loc_code'],
          "waktu": waktuPresensi,
          "tanggal": tanggalPresensi,
          "idKelas": dataQR['class_id'],
          "namaKelas": dataQR['class'],
          "idKelasSiswa":
              idSekolahKelas.isEmpty ? _idKelasGO.first : idSekolahKelas,
          "sesi": dataQR['session'],
          "nis": _noRegistrasi,
          "imei": gDeviceID,
          "latitude": coordinate.latitude.toString(),
          "longitude": coordinate.longitude.toString(),
          "flag": (flag > 0) ? "Sama" : "Tidak Sama",
          "nik": dataQR['person'],
          "namaPengajar": dataQR['person_name'],
          "jamAwal": dataQR['start'],
          "jamAkhir": dataQR['finish'],
          "from": "teaching",
        };

        if (kDebugMode) {
          logger.log('JADWAL_LIST_WIDGET-OnClickQrScanner(teaching):\n'
              'Data Presensi >> $dataPresensi\n'
              'FLAG >> ${(flag > 0) ? 'Sama' : 'Tidak Sama'}\n'
              'KELAS GO >> ${_idKelasGO[0]}');
        }

        message = await jadwalProvider.setPresensiSiswa(dataPresensi);
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          message,
          dialogType: DialogType.success,
        );

        /// Pencegahan jika presensi dengan tingkat kelas yang berbeda
        /// Belum bisa digunakan karena harus menunggu perbaikan dari aplikasi pengajar
        // if (dataQR['id_sekolah_kelas'] ==
        //     _authProvider.userData!.idSekolahKelas) {
        //   message = await jadwalProvider.setPresensiSiswa(dataPresensi);
        //   gShowTopFlash(
        //     gNavigatorKey.currentContext!,
        //     message,
        //     dialogType: DialogType.success,
        //   );
        // } else {
        //     logger.log(
        //       "${dataQR['id_sekolah_kelas']} == ${_authProvider.userData!.idSekolahKelas}");
        //   gShowBottomDialogInfo(gNavigatorKey.currentContext!,
        //       message: "Oops! Tingkat kelasnya berbeda Sobat");
        // }
        if (kDebugMode) {
          logger.log('MESSAGE TEACHING >> $message');
        }
      }

      if (dataQR['from'] == 'tst') {
        final Map<String, dynamic> dataPresensi = {
          "tstRequestId": dataQR['uid'],
          "studentId": _noRegistrasi,
          "presenceTime": waktuPresensi,
          "from": "tst",
        };

        if (kDebugMode) {
          logger.log('dataQR >> $dataQR');
          logger.log(
              'JADWAL_LIST_WIDGET-OnClickQrScanner(tst): Data Presensi >> $dataPresensi');
        }

        message = await jadwalProvider.setPresensiSiswaTst(dataPresensi);

        if (kDebugMode) {
          logger.log('MESSAGE TST >> $message');
        }
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          message,
          dialogType: DialogType.success,
        );
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    } on QRException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (e.toString().contains('QR Code tidak terbaca')) {
        List<String> titleMessage = e.toString().split('|');
        gShowBottomDialogInfo(
          context,
          title: titleMessage[0],
          message: titleMessage[1],
        );
      } else {
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          e.toString(),
        );
      }
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-QRException: $e');
      }
    } on LocationException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        e.toString(),
      );
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-LocationException: $e');
      }
    } on DataException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        e.toString(),
      );
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-DataException: $e');
      }
    } on PlatformException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        'Terjadi kesalahan saat scan QR Presensi',
      );
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-PlatformException: $e');
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowBottomDialogInfo(context, message: e.toString());

      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-FatalException: $e');
      }
    }
  }
}
