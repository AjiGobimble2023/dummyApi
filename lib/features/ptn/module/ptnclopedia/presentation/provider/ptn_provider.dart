import 'dart:async';
import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../entity/ptn.dart';
import '../../entity/jurusan.dart';
import '../../model/ptn_model.dart';
import '../../model/jurusan_model.dart';
import '../../entity/kampus_impian.dart';
import '../../service/api/ptn_service_api.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class PtnProvider extends ChangeNotifier {
  final PtnServiceApi _apiService = PtnServiceApi();

  final List<PTN> _listPTN = [];
  final Map<int, List<Jurusan>> _listJurusan = {};
  final Map<int, Jurusan> _listDetailJurusan = {};

  UnmodifiableListView<PTN> get listPTN => UnmodifiableListView(_listPTN);
  UnmodifiableListView<Jurusan> getDaftarJurusanByIdPTN(int idPTN) =>
      UnmodifiableListView(_listJurusan[idPTN] ?? []);

  Jurusan? getDetailJurusanById(int idJurusan) => _listDetailJurusan[idJurusan];

  bool _isLoadingImpian = true;

  PTN? _selectedPTN;
  Jurusan? _selectedJurusan;

  bool get isLoadingImpian => _isLoadingImpian;
  PTN? get selectedPTN => _selectedPTN;
  Jurusan? get selectedJurusan => _selectedJurusan;

  set selectedPTN(PTN? newPTN) {
    if (newPTN != null && newPTN.idPTN != _selectedPTN?.idPTN) {
      _selectedPTN = newPTN;
      _selectedJurusan = null;
      notifyListeners();
    }
  }

  set selectedJurusan(Jurusan? newJurusan) {
    if (kDebugMode) {
      logger.log('PTN_PROVIDER-SetSelectedJurusan: $newJurusan');
      logger.log('PTN_PROVIDER-SetSelectedJurusan: '
          '${newJurusan?.idJurusan != (_selectedJurusan?.idJurusan ?? 0)}');
    }
    if (newJurusan != null &&
        newJurusan.idJurusan != (_selectedJurusan?.idJurusan ?? 0)) {
      _selectedJurusan = newJurusan;
      notifyListeners();
    }
    if (kDebugMode) {
      logger.log(
          'PTN_PROVIDER-SetSelectedJurusan: Selected >> $_selectedJurusan');
    }
  }

  Future<List<PTN>> loadListUniversitas({
    bool isRefresh = false,
  }) async {
    if (listPTN.isNotEmpty) return listPTN;
    try {
      final responseData = await _apiService.fetchUniversitas();

      if (kDebugMode) {
        logger.log(
            'PTN_CLOPEDIA_PROVIDER-LoadPtnList: response data >> $responseData');
      }

      if (isRefresh) _listPTN.clear();

      if (responseData != null && _listPTN.isEmpty) {
        for (var dataPTN in responseData) {
          _listPTN.add(PTNModel.fromJson(dataPTN));
        }
      }

      if (kDebugMode) {
        logger.log('PTN_CLOPEDIA_PROVIDER-LoadPtnList: list ptn >> $listPTN');
      }

      return listPTN;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadPtnList: $e');
      }
      if (listPTN.isNotEmpty) return listPTN;
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadPtnList: $e');
      }
      if (listPTN.isNotEmpty) return listPTN;
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadPtnList: $e');
      }
      if (listPTN.isNotEmpty) return listPTN;
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  Future<List<Jurusan>> loadJurusanList({
    required int idPTN,
    bool isRefresh = false,
  }) async {
    if (!isRefresh && getDaftarJurusanByIdPTN(idPTN).isNotEmpty) {
      return getDaftarJurusanByIdPTN(idPTN);
    }
    try {
      final responseData = await _apiService.fetchJurusan(idPtn: idPTN);

      if (kDebugMode) {
        logger.log(
            'PTN_CLOPEDIA_PROVIDER-LoadJurusanList: response data >> $responseData');
      }

      if (isRefresh) {
        _listJurusan.remove(idPTN);
      }

      if (!_listJurusan.containsKey(idPTN)) {
        _listJurusan.putIfAbsent(idPTN, () => []);
      }

      if (responseData != null && getDaftarJurusanByIdPTN(idPTN).isEmpty) {
        for (var dataJurusan in responseData) {
          if (kDebugMode) {
            logger.log(
                'PTN_CLOPEDIA_PROVIDER-LoadJurusanList: data jurusan >> $dataJurusan');
          }
          _listJurusan[idPTN]!.add(JurusanModel.fromJson(dataJurusan));
        }
      }

      if (kDebugMode) {
        logger.log(
            'PTN_CLOPEDIA_PROVIDER-LoadJurusanList: list jurusan >> ${getDaftarJurusanByIdPTN(idPTN)}');
      }

      return getDaftarJurusanByIdPTN(idPTN);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadJurusanList: $e');
      }
      if (getDaftarJurusanByIdPTN(idPTN).isNotEmpty) {
        return getDaftarJurusanByIdPTN(idPTN);
      }
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadJurusanList: $e');
      }
      if (getDaftarJurusanByIdPTN(idPTN).isNotEmpty) {
        return getDaftarJurusanByIdPTN(idPTN);
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadJurusanList: $e');
      }
      if (getDaftarJurusanByIdPTN(idPTN).isNotEmpty) {
        return getDaftarJurusanByIdPTN(idPTN);
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  Future<Jurusan?> getDetailJurusan({
    required int idJurusan,
    bool isRefresh = false,
  }) async {
    if (!isRefresh && (_selectedJurusan != null)) {
      return getDetailJurusanById(idJurusan);
    }
    if (!isRefresh && (getDetailJurusanById(idJurusan) != null)) {
      _selectedJurusan = getDetailJurusanById(idJurusan);
      return getDetailJurusanById(idJurusan);
    }
    try {
      final responseData =
          await _apiService.fetchDetailJurusan(idJurusan: idJurusan);

      if (kDebugMode) {
        logger.log(
            'PTN_CLOPEDIA_PROVIDER-GetDetailJurusan: response data >> $responseData');
      }

      if (isRefresh) {
        _listDetailJurusan.remove(idJurusan);
      }

      if (responseData != null && !_listDetailJurusan.containsKey(idJurusan)) {
        if (kDebugMode) {
          logger.log(
              'PTN_CLOPEDIA_PROVIDER-GetDetailJurusan: data jurusan >> $responseData');
        }
        _selectedJurusan = JurusanModel.fromJson(responseData);
        _listDetailJurusan[idJurusan] = _selectedJurusan!;
      }

      if (kDebugMode) {
        logger.log(
            'PTN_CLOPEDIA_PROVIDER-GetDetailJurusan: detail jurusan $idJurusan '
            '>> ${getDetailJurusanById(idJurusan)}');
      }

      notifyListeners();
      return getDetailJurusanById(idJurusan);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDetailJurusan: $e');
      }
      if (getDetailJurusanById(idJurusan) != null) {
        _selectedJurusan = getDetailJurusanById(idJurusan);
        return getDetailJurusanById(idJurusan);
      }
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDetailJurusan: $e');
      }
      if (getDetailJurusanById(idJurusan) != null) {
        _selectedJurusan = getDetailJurusanById(idJurusan);
        return getDetailJurusanById(idJurusan);
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDetailJurusan: $e');
      }
      if (getDetailJurusanById(idJurusan) != null) {
        _selectedJurusan = getDetailJurusanById(idJurusan);
        return getDetailJurusanById(idJurusan);
      }
      throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
    }
  }

  /// Update pilihan kampus impian pada HiveBox dan API.
  /// Harus mengisi pilihan pertama terlebih dahulu.
  Future<void> updateKampusImpian({
    required int pilihanKe,
    required String noRegistrasi,
    String? namaPTN,
    String? aliasPTN,
    bool isRefresh = false,
  }) async {
    if (pilihanKe < 0 || pilihanKe > 2) return;
    var completer = Completer();

    try {
      if (_selectedJurusan == null) {
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          'Pilih jurusan terlebih dahulu yaa',
        );
        completer.complete();
        return;
      }
      // Cek pilihan 1
      KampusImpian? pilihan1 = HiveHelper.getKampusImpian(pilihanKe: 1);

      if (pilihanKe == 2 && pilihan1 == null) {
        gShowBottomDialogInfo(
          gNavigatorKey.currentContext!,
          title: 'Belum memilih pilihan 1',
          message:
              'Sebelum memilih pilihan ke 2, kamu harus mengisi pilihan pertama terlebih dahulu Sobat!',
        );
        completer.complete();
        return;
      }

      gNavigatorKey.currentContext!
          .showBlockDialog(dismissCompleter: completer);

      final pilihanKampus = KampusImpian(
        pilihanKe: pilihanKe,
        tanggalPilih: DateTime.now(),
        idPTN: _selectedJurusan!.idPTN,
        namaPTN: _selectedPTN?.namaPTN ?? namaPTN ?? 'Undifined',
        aliasPTN: _selectedPTN?.aliasPTN ?? aliasPTN ?? 'N/a',
        idJurusan: _selectedJurusan!.idJurusan,
        namaJurusan: _selectedJurusan!.namaJurusan,
        peminat: 'Peminat: ${_selectedJurusan!.peminat.last['jml']}',
        tampung: 'Daya Tampung: ${_selectedJurusan!.tampung.last['jml']}',
      );

      if (kDebugMode) {
        logger.log(
            'PTN_PROVIDER-UpdateKampusImpian: Pilihan Kampus >> $pilihanKampus');
      }

      await HiveHelper.saveRiwayatKampusImpianPilihan(
        kampusPilihan: pilihanKampus,
      );

      // Membuat Object kampus pilihan baru di karenakan
      // Exception HiveError: The same instance of an HiveObject cannot be stored in two different boxes.
      await HiveHelper.saveKampusImpianPilihan(
        pilihanKe: pilihanKe,
        kampusPilihan: KampusImpian(
          pilihanKe: pilihanKe,
          tanggalPilih: DateTime.now(),
          idPTN: _selectedJurusan!.idPTN,
          namaPTN: _selectedPTN?.namaPTN ?? namaPTN ?? 'Undifined',
          aliasPTN: _selectedPTN?.aliasPTN ?? aliasPTN ?? 'N/a',
          idJurusan: _selectedJurusan!.idJurusan,
          namaJurusan: _selectedJurusan!.namaJurusan,
          peminat: 'Peminat: ${_selectedJurusan!.peminat.last['jml']}',
          tampung: 'Daya Tampung: ${_selectedJurusan!.tampung.last['jml']}',
        ),
      );

      final response = await _apiService.putKampusImpian(
        noRegistrasi: noRegistrasi,
        pilihanKe: pilihanKe,
        idJurusan: pilihanKampus.idJurusan,
      );

      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        response['message'],
        dialogType: response['status'] ? DialogType.success : DialogType.error,
      );

      completer.complete();

      Future.delayed(
        Duration(seconds: 2, milliseconds: gDelayedNavigation.inMilliseconds),
      ).then((_) => Navigator.pop(gNavigatorKey.currentContext!));
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-UpdateKampusImpian: $e');
      }

      if (!completer.isCompleted) completer.complete();

      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-UpdateKampusImpian: $e');
      }

      if (!completer.isCompleted) completer.complete();

      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
    }
  }

  /// Function ini akan mengecek isi dari HiveBox terlebih dahulu,
  /// Jika kosong maka akan fetch data dari API
  Future<void> getKampusImpian({
    required String? noRegistrasi,
    required bool isOrtu,
    bool isRefresh = false,
    bool fromHome = false,
  }) async {
    if (noRegistrasi?.isEmpty ?? true) {
      gShowTopFlash(
          gNavigatorKey.currentState!.context, 'No Registrasi tidak terbaca');
      return;
    }
    if (isRefresh) {
      _isLoadingImpian = true;
      await Future.delayed(const Duration(milliseconds: 300))
          .then((_) => notifyListeners());
    }
    try {
      if (!HiveHelper.isBoxOpen<KampusImpian>(
          boxName: HiveHelper.kKampusImpianBox)) {
        await HiveHelper.openBox<KampusImpian>(
            boxName: HiveHelper.kKampusImpianBox);
      }
      if (!HiveHelper.isBoxOpen<KampusImpian>(
          boxName: HiveHelper.kRiwayatKampusImpianBox)) {
        await HiveHelper.openBox<KampusImpian>(
            boxName: HiveHelper.kRiwayatKampusImpianBox);
      }

      final riwayat = await HiveHelper.getRiwayatKampusImpian();

      if (isOrtu && riwayat.isNotEmpty) {
        await HiveHelper.clearKampusImpianBox();
        await HiveHelper.clearRiwayatKampusImpian();
      }

      if (riwayat.isEmpty || isRefresh || isOrtu) {
        final response = await _apiService.fetchKampusImpianPilihan(
            noRegistrasi: noRegistrasi!);

        if (response['data'] == null && !fromHome) {
          gShowTopFlash(gNavigatorKey.currentState!.context,
              'Data kampus impian kamu tidak ditemukan');
          return;
        }

        if (response['status'] && response['data'] != null) {
          if (response['data']['pilihan1'] != null) {
            // Store Pilihan 1 ke HiveBox
            await HiveHelper.saveKampusImpianPilihan(
              pilihanKe: 1,
              kampusPilihan:
                  KampusImpian.fromJson(response['data']['pilihan1']),
            );
          }
          if (response['data']['pilihan2'] != null) {
            // Store Pilihan 2 ke HiveBox
            await HiveHelper.saveKampusImpianPilihan(
              pilihanKe: 2,
              kampusPilihan:
                  KampusImpian.fromJson(response['data']['pilihan2']),
            );
          }

          if (response['data']['history'] != null) {
            List<KampusImpian> riwayatPilihan = [];

            for (var data in response['data']['history']) {
              riwayatPilihan.add(KampusImpian.fromJson(data));
            }

            // Store Riwayat Pilihan ke HiveBox
            await HiveHelper.saveAllRiwayatKampusImpian(
                riwayatPilihan: riwayatPilihan);
          }
        }

        if (!fromHome) {
          // ignore: use_build_context_synchronously
          gShowTopFlash(
            gNavigatorKey.currentState!.context,
            response['message'],
            dialogType:
                response['status'] ? DialogType.success : DialogType.error,
          );
        }
      }
      _isLoadingImpian = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetKampusImpian: $e');
      }
      if (!fromHome) {
        gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      }
      _isLoadingImpian = false;
      notifyListeners();
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetKampusImpian: $e');
      }

      if (!'$e'.contains('tidak ditemukan') && !fromHome) {
        gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      }

      _isLoadingImpian = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetKampusImpian: $e');
      }
      if (!fromHome) {
        gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
      }
      _isLoadingImpian = false;
      notifyListeners();
    }
  }
}
