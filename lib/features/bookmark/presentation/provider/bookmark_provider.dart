import 'dart:async';
import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';

import '../../entity/bookmark.dart';
import '../../service/api/bookmark_service_api.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class BookmarkProvider extends DisposableProvider {
  final _apiService = BookmarkServiceAPI();

  List<BookmarkMapel> _listBookmark = [];

  // Local variable
  bool _isLoadBookmark = true;
  bool _isAlreadyCheckAPI = false;
  bool bookmarkUpdated = false;
  String? _noRegistrasi;

  bool get isLoadBookmark => _isLoadBookmark;

  String get lastUpdate => DataFormatter.formatLastUpdate();
  UnmodifiableListView<BookmarkMapel> get listBookmark =>
      UnmodifiableListView(_listBookmark);

  Future<void> reloadBookmarkFromHive() async {
    try {
      if (!HiveHelper.isBoxOpen<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox)) {
        await HiveHelper.openBox<BookmarkMapel>(
            boxName: HiveHelper.kBookmarkMapelBox);
      }
      bookmarkUpdated = true;
      _listBookmark = await HiveHelper.getDaftarBookmarkMapel();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-ReloadBookmarkFromHive: $e');
      }
    }
  }

  // Function untuk menampilkan shortcut bookmark pada halaman home
  Future<void> loadBookmarkMapel({
    String? noRegistrasi,
    required bool isSiswa,
    bool refresh = false,
  }) async {
    if (refresh && _listBookmark.isNotEmpty) {
      _listBookmark.clear();
      _isLoadBookmark = true;
      notifyListeners();
    }
    try {
      if (kDebugMode) {
        logger.log('BOOKMARK_PROVIDER-LoadBookmarkMapel: START');
        logger.log(
            'BOOKMARK_PROVIDER-LoadBookmarkMapel: No Registrasi >> $noRegistrasi');
      }

      _noRegistrasi = noRegistrasi;
      _listBookmark = await HiveHelper.getDaftarBookmarkMapel();

      // Jika list bookmark pada hive kosong dan belum cek API,
      // Maka cek ke API dan masukkan ke hive.
      if (isSiswa &&
          _listBookmark.isEmpty &&
          !_isAlreadyCheckAPI &&
          noRegistrasi != null) {
        final responseData =
            await _apiService.fetchBookmark(noRegistrasi: noRegistrasi);

        if (kDebugMode) {
          logger.log(
              'BOOKMARK_PROVIDER-LoadBookmarkMapel: GET RESPONSE DATA >> $responseData');
        }

        for (Map<String, dynamic> bookmark in responseData) {
          if (!bookmark.containsKey('iconMapel')) {
            int idKelompokUjian = int.parse(bookmark['idKelompokUjian'] ?? '0');

            final iconMapel = Constant.kIconMataPelajaran.entries
                .where(
                  (iconMapel) =>
                      iconMapel.value['idKelompokUjian']
                          ?.contains(idKelompokUjian) ??
                      false,
                )
                .toList();

            bookmark.putIfAbsent('iconMapel',
                () => (iconMapel.isEmpty) ? null : iconMapel[0].key);

            if (kDebugMode) {
              logger.log(
                  'BOOKMARK_PROVIDER-LoadBookmarkMapel: result icon mapel >> $iconMapel');
            }
          }

          if (kDebugMode) {
            logger.log(
                'BOOKMARK_PROVIDER-LoadBookmarkMapel: bookmark data >> $bookmark');
          }

          BookmarkMapel bookmarkMapel = BookmarkMapel.fromJson(bookmark);

          await HiveHelper.saveBookmarkMapel(
              keyBookmarkMapel: bookmarkMapel.idKelompokUjian,
              dataBookmark: bookmarkMapel);

          _isAlreadyCheckAPI = true;
        }

        // Setelah data bookmark masuk ke hive semua, set _listBookmark value dengan value dar Hive.
        _listBookmark = await HiveHelper.getDaftarBookmarkMapel();
      }

      _isLoadBookmark = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadBookmarkMapel: $e');
      }
      _isLoadBookmark = false;
      notifyListeners();
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadBookmarkMapel: $e');
      }
      _isLoadBookmark = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadBookmarkMapel: $e');
      }
      // throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
      _isLoadBookmark = false;
      notifyListeners();
    }
  }

  Future<bool> removeBookmarkMapel({
    required String idKelompokUjian,
    required bool isSiswa,
    bool isShowLoading = true,
  }) async {
    if (_noRegistrasi == null) {
      return false;
    }
    Completer? completer;
    if (isShowLoading) {
      completer = Completer();
      gNavigatorKey.currentState!.context
          .showBlockDialog(dismissCompleter: completer);
    }
    try {
      if (kDebugMode) {
        logger.log('BOOKMARK_PROVIDER-RemoveBookmarkMapel: START');
        logger.log(
            'BOOKMARK_PROVIDER-RemoveBookmarkMapel: No Registrasi >> $_noRegistrasi');
      }

      bool isBerhasilHapus = false;

      isBerhasilHapus = await HiveHelper.removeBookmarkMapel(
          keyBookmarkMapel: idKelompokUjian);

      if (isBerhasilHapus) {
        _listBookmark = await HiveHelper.getDaftarBookmarkMapel();

        if (isSiswa) {
          isBerhasilHapus = await _apiService.updateBookmark(
              noRegistrasi: _noRegistrasi!, daftarBookmark: _listBookmark);
        }
      }

      if (isShowLoading) {
        completer!.complete();
      }
      notifyListeners();
      return isBerhasilHapus;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-RemoveBookmarkMapel: $e');
      }
      if (isShowLoading) {
        completer!.complete();
      }
      return false;
    }
  }

  Future<bool> removeBookmarkSoal(
      {required String idKelompokUjian,
      required bool isSiswa,
      required BookmarkSoal bookmarkSoal}) async {
    if (_noRegistrasi == null) {
      return false;
    }
    var completer = Completer();
    gNavigatorKey.currentState!.context
        .showBlockDialog(dismissCompleter: completer);
    try {
      if (kDebugMode) {
        logger.log('BOOKMARK_PROVIDER-RemoveBookmarkSoal: START');
        logger.log(
            'BOOKMARK_PROVIDER-RemoveBookmarkSoal: No Registrasi >> $_noRegistrasi');
      }

      bool isBerhasilHapus = false;

      isBerhasilHapus = await HiveHelper.removeBookmarkSoal(
          keyBookmarkMapel: idKelompokUjian, bookmarkSoal: bookmarkSoal);

      if (isBerhasilHapus) {
        BookmarkMapel? bookmarkMapelHive = await HiveHelper.getBookmarkMapel(
            keyBookmarkMapel: idKelompokUjian);

        // Jika pada bookmark mapel tidak terdapat bookmark soal, maka hapus mapel tersebut.
        if (bookmarkMapelHive != null &&
            bookmarkMapelHive.listBookmark.isEmpty) {
          await HiveHelper.removeBookmarkMapel(
              keyBookmarkMapel: idKelompokUjian);
        }

        _listBookmark = await HiveHelper.getDaftarBookmarkMapel();

        if (isSiswa) {
          isBerhasilHapus = await _apiService.updateBookmark(
              noRegistrasi: _noRegistrasi!, daftarBookmark: _listBookmark);
        }
      }

      completer.complete();
      notifyListeners();
      return isBerhasilHapus;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-RemoveBookmarkSoal: $e');
      }
      completer.complete();
      return false;
    }
  }

  Future<bool> updateBookmark({
    required String noRegistrasi,
    required bool isSiswa,
  }) async {
    if (!bookmarkUpdated) {
      if (kDebugMode) {
        logger.log('BOOKMARK_PROVIDER-UpdateBookmark: Bookmark hasn\'t change.');
      }
      return false;
    }
    try {
      if (kDebugMode) {
        logger.log('BOOKMARK_PROVIDER-UpdateBookmark: START');
        logger.log(
            'BOOKMARK_PROVIDER-UpdateBookmark: No Registrasi >> $noRegistrasi');
      }

      _listBookmark = await HiveHelper.getDaftarBookmarkMapel();
      bool isBerhasilUpdate = true;

      if (isSiswa) {
        isBerhasilUpdate = await _apiService.updateBookmark(
            noRegistrasi: noRegistrasi, daftarBookmark: _listBookmark);
      }

      notifyListeners();
      return isBerhasilUpdate;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-UpdateBookmark: $e');
      }
      return false;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-UpdateBookmark: $e');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-UpdateBookmark: $e');
      }
      // throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
      return false;
    }
  }

  @override
  void disposeValues() async {
    bookmarkUpdated = false;
    _listBookmark = [];
    if (!HiveHelper.isBoxOpen<BookmarkMapel>(
        boxName: HiveHelper.kBookmarkMapelBox)) {
      await HiveHelper.openBox<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox);
    }
    await HiveHelper.clearBookmarkBox();
  }
}
