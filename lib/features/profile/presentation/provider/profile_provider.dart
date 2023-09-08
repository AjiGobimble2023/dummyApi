// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../model/about_model.dart';
import '../../entity/kelompok_ujian.dart';
import '../../service/api/data_service_api.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class ProfileProvider extends DisposableProvider {
  final _apiService = DataServiceAPI();

  static final ProfileProvider _instance = ProfileProvider._internal();

  factory ProfileProvider() => _instance;

  ProfileProvider._internal();

  bool _isLoadingAturan = true;
  bool _isLoadingAbout = true;
  bool _isLoadingPilihanKelompokUjian = true;
  bool _isLoadingDeleteAccount = false;
  bool _isMenyetujuiAturan = false;
  String? _aturanHtml;
  // Default maksimal dan  minimal dari tingkat SMA.
  int _maksimalPilihKelompokUjian = 7;
  int _minimumPilihKelompokUjian = 3;
  // ignore: prefer_final_fields
  List<AboutModel> _aboutGOKreasi = [];

  bool get isLoadingAturan => _isLoadingAturan;
  bool get isLoadingAbout => _isLoadingAbout;
  bool get isLoadingPilihanKelompokUjian => _isLoadingPilihanKelompokUjian;
  bool get isLoadingDeleteAccount => _isLoadingDeleteAccount;
  bool get isMenyetujuiAturan => _isMenyetujuiAturan;

  int get maksimalPilihKelompokUjian => _maksimalPilihKelompokUjian;
  int get minimumPilihKelompokUjian => _minimumPilihKelompokUjian;

  String? get aturanHtml => _aturanHtml;
  UnmodifiableListView<AboutModel> get aboutGOKreasi =>
      UnmodifiableListView(_aboutGOKreasi);

  @override
  void disposeValues() {
    _isLoadingAturan = true;
    _isMenyetujuiAturan = false;
    _isLoadingPilihanKelompokUjian = true;
  }

  Map<int, Map<String, String>> getDaftarPilihanKelompokUjian(
      {required String tingkatSekolah}) {
    // Set maksimum dan minimum pilihan kelompok ujian sesuai tingkat sekolah
    switch (tingkatSekolah) {
      case 'SMP':
        // TODO: Menyesuaikan aturan TO Merdeka dari BMP dan BPPPS.
        _maksimalPilihKelompokUjian = 7;
        _minimumPilihKelompokUjian = 3;
        break;
      case 'SD':
        // TODO: Menyesuaikan aturan TO Merdeka dari BMP dan BPPPS.
        _maksimalPilihKelompokUjian = 7;
        _minimumPilihKelompokUjian = 3;
        break;
      default:
        break;
    }

    Map<int, Map<String, String>> opsiPilihan = {};

    for (var kelompokUjian in Constant.kInitialKelompokUjian.entries) {
      bool isOpsiPilihan =
          (Constant.kKelompokUjianPilihan[tingkatSekolah] ?? [])
              .contains(kelompokUjian.key);

      if (isOpsiPilihan) {
        opsiPilihan.putIfAbsent(kelompokUjian.key, () => kelompokUjian.value);
      }
    }

    return opsiPilihan;
  }

  Future<void> updateKelompokUjianPilihan(
      {required MapEntry<int, Map<String, String>> kelompokUjian}) async {
    List<KelompokUjian> listKelompokUjianPilihan =
        await HiveHelper.getDaftarKelompokUjianPilihan();
    bool isAlreadySelected = listKelompokUjianPilihan
        .any((dataSaved) => dataSaved.idKelompokUjian == kelompokUjian.key);

    if (!isAlreadySelected &&
        listKelompokUjianPilihan.length == _maksimalPilihKelompokUjian) {
      gShowTopFlash(gNavigatorKey.currentState!.context,
          'Maksimum pilihan mata uji adalah $_maksimalPilihKelompokUjian pilihan');
      return;
    }

    if (isAlreadySelected &&
        listKelompokUjianPilihan.length <= _minimumPilihKelompokUjian) {
      gShowTopFlash(gNavigatorKey.currentState!.context,
          'Minimum pilihan mata uji adalah $_minimumPilihKelompokUjian pilihan');
      return;
    }

    if (isAlreadySelected) {
      HiveHelper.removeKelompokUjianPilihan(idKelompokUjian: kelompokUjian.key);
    } else {
      HiveHelper.saveKelompokUjianPilihan(
        idKelompokUjian: kelompokUjian.key,
        dataKelompokUjianPilihan: KelompokUjian(
            idKelompokUjian: kelompokUjian.key,
            namaKelompokUjian: kelompokUjian.value['nama'] ?? '-',
            initial: kelompokUjian.value['initial'] ?? '-'),
      );
    }
    notifyListeners();
  }

  Future<bool> simpanKelompokUjianPilihan(
      {required String noRegistrasi}) async {
    try {
      List<KelompokUjian> listKelompokUjianPilihan =
          await HiveHelper.getDaftarKelompokUjianPilihan();

      final responseStatus = await _apiService.setKelompokUjianPilihan(
        noRegistrasi: noRegistrasi,
        daftarIdKelompokUjian: listKelompokUjianPilihan
            .map<String>((e) => '${e.idKelompokUjian}')
            .toList(),
      );

      gShowTopFlash(
        gNavigatorKey.currentContext!,
        (responseStatus)
            ? 'Berhasil menyimpan pilihan'
            : 'Gagal menyimpan pilihan, coba lagi!',
        dialogType: (responseStatus) ? DialogType.success : DialogType.error,
      );
      return responseStatus;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SimpanKelompokUjianPilihan: $e');
      }
      gShowTopFlash(gNavigatorKey.currentContext!, gPesanError);
      return false;
    }
  }

  Future<void> getKelompokUjianPilihan({required String noRegistrasi}) async {
    try {
      await HiveHelper.openBox<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox);

      List<KelompokUjian> listKelompokUjianPilihan =
          await HiveHelper.getDaftarKelompokUjianPilihan();

      if (kDebugMode) {
        logger.log('PROFILE_PROVIDER-GetKelompokUjianPilihan: '
            'Hive Length >> ${listKelompokUjianPilihan.length}');
      }

      if (listKelompokUjianPilihan.isEmpty) {
        final responseData = await _apiService.fetchKelompokUjianPilihan(
          noRegistrasi: noRegistrasi,
        );

        if (kDebugMode) {
          logger.log(
              'PROFILE_PROVIDER-GetKelompokUjianPilihan: Response Data >> $responseData');
        }

        if (responseData != null &&
            responseData is List &&
            responseData.isNotEmpty) {
          for (var id in responseData) {
            int idKelompokUjian = (id is int) ? id : int.tryParse('$id') ?? -1;

            String namaKelompokUjian =
                Constant.kInitialKelompokUjian[idKelompokUjian]?['nama'] ??
                    'Undefined';

            String initial = Constant.kInitialKelompokUjian[idKelompokUjian]
                    ?['initial'] ??
                'N/a';

            if (kDebugMode) {
              logger.log('PROFILE_PROVIDER-GetKelompokUjianPilihan: '
                  'Kelompok Ujian $idKelompokUjian >> $namaKelompokUjian ($initial)');
            }

            await HiveHelper.saveKelompokUjianPilihan(
              idKelompokUjian: idKelompokUjian,
              dataKelompokUjianPilihan: KelompokUjian(
                idKelompokUjian: idKelompokUjian,
                namaKelompokUjian: namaKelompokUjian,
                initial: initial,
              ),
            );
          }
        }
      }
      if (_isLoadingPilihanKelompokUjian) {
        _isLoadingPilihanKelompokUjian = false;
        notifyListeners();
      }
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetKelompokUjianPilihan: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);

      if (_isLoadingPilihanKelompokUjian) {
        _isLoadingPilihanKelompokUjian = false;
        notifyListeners();
      }
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-Data-GetKelompokUjianPilihan: $e');
      }
      if (!'$e'.contains('Tidak ditemukan')) {
        gShowTopFlash(gNavigatorKey.currentContext!, '$e');
      }
      if (_isLoadingPilihanKelompokUjian) {
        _isLoadingPilihanKelompokUjian = false;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetKelompokUjianPilihan: $e');
      }
      gShowTopFlash(gNavigatorKey.currentContext!, gPesanError);
      if (_isLoadingPilihanKelompokUjian) {
        _isLoadingPilihanKelompokUjian = false;
        notifyListeners();
      }
    }
  }

  Future<List<AboutModel>> loadAbout({bool isRefresh = false}) async {
    if (!isRefresh && _aboutGOKreasi.isNotEmpty) return aboutGOKreasi;

    if (isRefresh) {
      _isLoadingAbout = true;
      _aboutGOKreasi.clear();
      await Future.delayed(const Duration(milliseconds: 300));
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    try {
      final responseData = await _apiService.fetchAbout();

      if (responseData != null && _aboutGOKreasi.isEmpty) {
        for (var data in responseData) {
          _aboutGOKreasi.add(AboutModel.fromJson(data));
        }
      }

      _isLoadingAbout = false;
      notifyListeners();
      return aboutGOKreasi;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadAbout: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      _isLoadingAbout = false;
      notifyListeners();
      return Constant.defaultAbout;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-Data-LoadAbout: $e');
      }
      _isLoadingAbout = false;
      notifyListeners();
      return Constant.defaultAbout;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-Data-LoadAbout: $e');
      }
      _isLoadingAbout = false;
      notifyListeners();
      return Constant.defaultAbout;
    }
  }

  Future<bool> loadAturanSiswa({
    String? noRegistrasi,
    String? tipeUser,
    bool isRefresh = false,
  }) async {
    if (noRegistrasi == null || tipeUser == null) {
      return _isMenyetujuiAturan;
    }
    if (!isRefresh && _aturanHtml != null && _isMenyetujuiAturan) {
      return _isMenyetujuiAturan;
    }

    if (isRefresh) {
      _isLoadingAturan = true;
      await Future.delayed(const Duration(milliseconds: 300));
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    try {
      final responseData = await _apiService.fetchAturanSiswa(
        noRegistrasi: noRegistrasi,
        tipeUser: tipeUser,
      );

      _isMenyetujuiAturan = responseData['sudahTercatat'];
      if (responseData != null && responseData['aturan'] != null) {
        _aturanHtml = responseData['aturan'];
      }

      _isLoadingAturan = false;
      notifyListeners();
      return _isMenyetujuiAturan;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadAturanSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      _isLoadingAturan = false;
      notifyListeners();
      return _isMenyetujuiAturan;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-LoadAturanSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      _isLoadingAturan = false;
      notifyListeners();
      return _isMenyetujuiAturan;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadAturanSiswa: $e');
      }
      _isLoadingAturan = false;
      notifyListeners();
      return _isMenyetujuiAturan;
    }
  }

  Future<bool> simpanAturanSiswa({
    String? noRegistrasi,
    String? tipeUser,
  }) async {
    if (noRegistrasi == null || tipeUser == null) {
      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        'Mohon ${(noRegistrasi == null) ? 'isi No Registrasi' : 'pilih Tipe User'} terlebih dahulu',
      );
      return false;
    }

    try {
      final responseData = await _apiService.setAturanSiswa(
        noRegistrasi: noRegistrasi,
        tipeUser: tipeUser,
      );

      if (responseData != null) {
        _isMenyetujuiAturan = responseData['isSetuju'];
        gShowTopFlash(
          gNavigatorKey.currentState!.context,
          responseData['message'],
          dialogType:
              _isMenyetujuiAturan ? DialogType.success : DialogType.error,
        );
        notifyListeners();
      } else {
        gShowTopFlash(gNavigatorKey.currentState!.context,
            'Gagal menyetujui Aturan, Coba lagi!');
      }

      return _isMenyetujuiAturan;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadAturanSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      notifyListeners();
      return _isMenyetujuiAturan;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-LoadAturanSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
      notifyListeners();
      return _isMenyetujuiAturan;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadAturanSiswa: $e');
      }
      gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
      notifyListeners();
      return _isMenyetujuiAturan;
    }
  }

  Future<bool> hapusAkun({
    required String nomorHp,
    required String noRegistrasi,
  }) async {
    try {
      _isLoadingDeleteAccount = true;
      notifyListeners();
      final responseStatus = await _apiService.deleteAccount(
        nomorHp: nomorHp,
        noRegistrasi: noRegistrasi,
      );
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        (responseStatus['status'])
            ? 'Berhasil menghapus akun'
            : 'Gagal menghapus akun',
        dialogType:
            (responseStatus['status']) ? DialogType.success : DialogType.error,
      );
      Future.delayed(const Duration(seconds: 2), () {
        _isLoadingDeleteAccount = false;
      });
      notifyListeners();
      return responseStatus['status'];
    } catch (e) {
      _isLoadingDeleteAccount = false;
      if (kDebugMode) {
        logger.log('FatalException-HapusAkun: $e');
      }
      gShowTopFlash(gNavigatorKey.currentContext!, gPesanError);
      return false;
    }
  }
}
