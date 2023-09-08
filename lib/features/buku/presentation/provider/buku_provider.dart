import 'dart:convert';
import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../entity/buku.dart';
import '../../entity/bab_buku.dart';
import '../../model/buku_model.dart';
import '../../model/content_model.dart';
import '../../model/bab_buku_model.dart';
import '../../service/api/buku_service_api.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class BukuProvider extends DisposableProvider {
  final _apiService = BukuServiceAPI();

  Map<int, List<Buku>> _listBuku = {};
  Map<String, List<BabUtamaBuku>> _listBab = {};
  Map<String, ContentModel> _contentBab = {};

  bool _isLoadingBuku = true;
  bool _isLoadingBab = true;
  bool _isLoadingContent = true;

  bool get isLoadingBuku => _isLoadingBuku;

  bool get isLoadingBab => _isLoadingBab;

  bool get isLoadingContent => _isLoadingContent;

  UnmodifiableListView<Buku> getListBukuByIdJenisProduk(int idJenisProduk) =>
      UnmodifiableListView<Buku>(_listBuku[idJenisProduk] ?? []);

  UnmodifiableListView<BabUtamaBuku> getListBabByKodeBuku({
    required String kodeBuku,
    required String kelengkapan,
    required String levelTeori,
  }) =>
      UnmodifiableListView<BabUtamaBuku>(
          _listBab['$kodeBuku-$kelengkapan-$levelTeori'] ?? []);

  ContentModel? getContentBabByIdTeoriBab(String idTeoriBab) =>
      _contentBab[idTeoriBab];

  @override
  void disposeValues() {
    _isLoadingBuku = true;
    _isLoadingBab = true;
    _isLoadingContent = true;
    _listBab = {};
    _listBuku = {};
    _contentBab = {};
  }

  Future<void> loadDaftarBuku({
    String? noRegistrasi,
    required int idJenisProduk,
    required String idSekolahKelas,
    required String roleTeaser,
    required bool isProdukDibeli,
    bool isRefresh = false,
  }) async {
    // Jika tidak refresh dan data sudah ada di cache [_listBuku]
    // maka return List dari [_listBuku].
    if (!isRefresh && (_listBuku[idJenisProduk]?.isNotEmpty ?? false)) {
      return;
    }
    if (isRefresh) {
      _isLoadingBuku = true;
      notifyListeners();
      _listBuku[idJenisProduk]?.clear();
    }
    try {
      final responseData = await _apiService.fetchDaftarBuku(
        jenisBuku: (idJenisProduk == 59) ? 'teori' : 'rumus',
        noRegistrasi: noRegistrasi,
        roleTeaser: roleTeaser,
        idSekolahKelas: idSekolahKelas,
        isProdukDibeli: isProdukDibeli,
      );

      if (!_listBuku.containsKey(idJenisProduk)) {
        _listBuku[idJenisProduk] = [];
      }

      if (responseData.isNotEmpty && _listBuku[idJenisProduk]!.isEmpty) {
        for (var dataBuku in responseData) {
          int idKelompokUjian = int.parse(dataBuku['c_IdKelompokUjian'] ?? '0');

          final iconMapel = Constant.kIconMataPelajaran.entries
              .where(
                (iconMapel) =>
            iconMapel.value['idKelompokUjian']
                ?.contains(idKelompokUjian) ??
                false,
          )
              .toList();

          _listBuku[idJenisProduk]!.add(
            BukuModel.fromJson(
              json: dataBuku,
              imageUrl: (iconMapel.isEmpty) ? null : iconMapel[0].key,
            ),
          );
        }
        _listBuku[idJenisProduk]?.sort(
              (a, b) {
            int kelompokUjian =
            a.namaKelompokUjian.compareTo(b.namaKelompokUjian);
            if (kelompokUjian == 0) {
              int tingkatKelas = a.tingkatKelas.compareTo(b.tingkatKelas);
              if (tingkatKelas == 0) {
                int sekolahKelas = a.sekolahKelas.compareTo(b.sekolahKelas);
                if (sekolahKelas == 0) {
                  return a.namaBuku.compareTo(b.namaBuku);
                }
                return -sekolahKelas;
              }
              return -tingkatKelas;
            }
            return kelompokUjian;
          },
        );
      }

      if (kDebugMode) {
        logger.log(
            'BUKU_PROVIDER-LoadDaftarBuku: Daftar Buku >> ${_listBuku[idJenisProduk]}');
      }

      _isLoadingBuku = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadDaftarBuku: $e');
      }

      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        'Koneksi internet Sobat tidak stabil, coba lagi!',
        dialogType: DialogType.error,
      );
      _isLoadingBuku = false;
      notifyListeners();
      return;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadDaftarBuku: $e');
      }

      if (!'$e'.contains('tidak ditemukan')) {
        gShowTopFlash(
          gNavigatorKey.currentState!.context,
          '$e',
          dialogType: DialogType.error,
        );
      }
      _isLoadingBuku = false;
      notifyListeners();
      return;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadDaftarBuku: $e');
      }

      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        gPesanError,
        dialogType: DialogType.error,
      );
      _isLoadingBuku = false;
      notifyListeners();
      return;
    }
  }

  Future<void> loadDaftarBab({
    required String kodeBuku,
    required String kelengkapan,
    required String levelTeori,
    bool isRefresh = false,
  }) async {
    String cacheKey = '$kodeBuku-$kelengkapan-$levelTeori';
    // Jika tidak refresh dan data sudah ada di cache [_listBab]
    // maka return List dari [_listBab].
    if (!isRefresh && (_listBab[cacheKey]?.isNotEmpty ?? false)) {
      return;
    }
    if (isRefresh) {
      _isLoadingBab = true;
      notifyListeners();
      _listBab[cacheKey]?.clear();
    }
    try {
      final responseData = await _apiService.fetchDaftarBab(
        kodeBuku: kodeBuku,
        kelengkapan: kelengkapan,
        levelTeori: levelTeori,
      );

      if (!_listBab.containsKey(cacheKey)) {
        _listBab[cacheKey] = [];
      }

      if (responseData.isNotEmpty && _listBab[cacheKey]!.isEmpty) {
        for (var dataBab in responseData) {
          _listBab[cacheKey]!.add(BabUtamaBukuModel.fromJson(dataBab));
        }
        _listBab[cacheKey]!.sort(
                (a, b) =>
                a.daftarBab.first.kodeBab.compareTo(b.daftarBab.first.kodeBab)
        );
      }

      if (kDebugMode) {
        logger.log(
            'BUKU_PROVIDER-LoadDaftarBab: Daftar Bab >> ${_listBab[cacheKey]}');
      }

      _isLoadingBab = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadDaftarBab: $e');
      }

      gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);
      _isLoadingBab = false;
      notifyListeners();
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadDaftarBab: $e');
      }

      if (!'$e'.contains('tidak ditemukan')) {
        gShowTopFlash(
          gNavigatorKey.currentState!.context,
          '$e',
          dialogType: DialogType.error,
        );
      }
      _isLoadingBab = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadDaftarBab: $e');
      }

      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        gPesanError,
        dialogType: DialogType.error,
      );
      _isLoadingBab = false;
      notifyListeners();
    }
  }

  Future<ContentModel?> loadContent({
    required String idTeoriBab,
    bool isRefresh = false,
  }) async {
    // Jika tidak refresh dan data sudah ada di cache [_contentBab]
    // maka return List dari [_contentBab].
    if (!isRefresh && (_contentBab[idTeoriBab] != null)) {
      return getContentBabByIdTeoriBab(idTeoriBab);
    }
    if (isRefresh) {
      _isLoadingContent = true;
      notifyListeners();
      _contentBab.remove(idTeoriBab);
    }
    try {
      final responseData =
      await _apiService.fetchContent(idTeoriBab: idTeoriBab);

      if (kDebugMode) {
        logger.log("cek provider : $responseData");
      }

      if (responseData != null && _contentBab[idTeoriBab] == null) {
        _contentBab[idTeoriBab] = ContentModel.fromJson(responseData);
      }

      _isLoadingContent = false;
      notifyListeners();
      return getContentBabByIdTeoriBab(idTeoriBab);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadContentBab: $e');
      }

      gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);

      _isLoadingContent = false;
      notifyListeners();
      return getContentBabByIdTeoriBab(idTeoriBab);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadContentBab: $e');
      }

      if (!'$e'.contains('tidak ditemukan')) {
        gShowTopFlash(
          gNavigatorKey.currentState!.context,
          '$e',
          dialogType: DialogType.error,
        );
      }

      _isLoadingContent = false;
      notifyListeners();
      return getContentBabByIdTeoriBab(idTeoriBab);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadContentBab: $e');
      }

      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        gPesanError,
        dialogType: DialogType.error,
      );
      _isLoadingContent = false;
      notifyListeners();
      return getContentBabByIdTeoriBab(idTeoriBab);
    }
  }
}