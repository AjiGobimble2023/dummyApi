import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/bookmark/entity/bookmark.dart';
import '../../features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../features/profile/entity/scanner_type.dart';
import '../../features/profile/entity/kelompok_ujian.dart';

class HiveHelper {
  static const String kSettingBox = 'BOX_SETTING';
  // static const String kJawabanSiswaBox = 'BOX_JAWABAN_SISWA';
  static const String kBookmarkMapelBox = 'BOX_BOOKMARK_MAPEL';
  static const String kKonfirmasiTOMerdekaBox = 'BOX_KONFIRMASI_TO_MERDEKA';
  static const String kKelompokUjianPilihanBox = 'BOX_KELOMPOK_UJIAN_PILIHAN';
  static const String kKampusImpianBox = 'BOX_KAMPUS_IMPIAN';
  static const String kRiwayatKampusImpianBox = 'BOX_RIWAYAT_KAMPUS_IMPIAN';

  static const String kScannerKey = 'SELECTED_SCANNER';

  static Future<Box<T>> openBox<T>({required String boxName}) async =>
      (!Hive.isBoxOpen(boxName))
          ? await Hive.openBox<T>(boxName)
          : Hive.box<T>(boxName);

  /// [closeBox] untuk menutup spesifik Hive Box yang terbuka.
  static Future<void> closeBox<T>({required String boxName}) async =>
      (Hive.isBoxOpen(boxName)) ? await Hive.box<T>(boxName).close() : null;

  /// [closeAllBoxes] untuk menutup semua Hive Box yang terbuka.
  static Future<void> closeAllBoxes() async => await Hive.close();

  static bool isBoxOpen<T>({required String boxName}) =>
      Hive.isBoxOpen(boxName);

  /// Mengambil inisiasi box
  static Box<T> box<T>(String boxName) => Hive.box<T>(boxName);

  /// Untuk realtime changing values
  static ValueListenable<Box<T>> valueListenable<T>(String boxName) =>
      Hive.box<T>(boxName).listenable();

  static ValueListenable<Box<ScannerType>> listenableQRScanner() =>
      Hive.box<ScannerType>(kSettingBox).listenable();

  static ValueListenable<Box<BookmarkMapel>> listenableBookmarkMapel() =>
      Hive.box<BookmarkMapel>(kBookmarkMapelBox).listenable();

  static ValueListenable<Box<KelompokUjian>> listenableKelompokUjian() =>
      Hive.box<KelompokUjian>(kKelompokUjianPilihanBox).listenable();

  static ValueListenable<Box<KampusImpian>> listenableKampusImpian() =>
      Hive.box<KampusImpian>(kKampusImpianBox).listenable();

  static ValueListenable<Box<KampusImpian>> listenableRiwayatKampusImpian() =>
      Hive.box<KampusImpian>(kRiwayatKampusImpianBox).listenable();

  /// [saveScannerSetting] digunakan untuk mengatur setting Scanner pilihan.
  static Future<bool> saveScannerSetting({
    required String key,
    required ScannerType scannerPilihan,
  }) async {
    final Box<ScannerType> box = Hive.box<ScannerType>(kSettingBox);

    if (kDebugMode) {
      logger.log(
          'HIVE_HELPER-SaveScannerSetting: ScannerSetting[$key] >> $scannerPilihan');
    }

    bool berhasilSimpan = true;
    await box.put(key, scannerPilihan).catchError((error, stackTrace) {
      if (kDebugMode) {
        logger.log('HIVE_HELPER-SaveScannerSetting: ERROR >> $error');
        logger.log('HIVE_HELPER-SaveScannerSetting: STACKTRACE >> $stackTrace');
      }
      berhasilSimpan = false;
    });

    return berhasilSimpan;
  }

  /// [getScannerSetting] mengambil scanner type pilihan user.
  static ScannerType getScannerSetting({required String key}) {
    final Box<ScannerType> box = Hive.box<ScannerType>(kSettingBox);

    if (kDebugMode) {
      logger.log('HIVE_HELPER-GetScannerSetting: '
          'ScannerSettingBox[$key] >> ${box.get(key)}');
    }

    return box.get(key) ?? ScannerType.mobileScanner;
  }
  //
  // /// [saveJawabanSiswa] digunakan pada saat akan menyimpan TempJawaban.<br>
  // /// Format [key] berupa String, bisa jadi bentuknya $idBundle-$idBab-$idSoal
  // /// atau $kodePaket-$idSoal
  // static Future<void> saveJawabanSiswa(
  //     {required String key, required Map<String, dynamic> jawabanSiswa}) async {
  //   final Box<Map<String, dynamic>> box =
  //       Hive.box<Map<String, dynamic>>(kJawabanSiswaBox);
  //
  //   if (kDebugMode) {
  //     logger.log(
  //         'HIVE_HELPER-SaveJawabanSiswa: JawabanSiswaBox[$key] >> $jawabanSiswa');
  //   }
  //
  //   await box.put(key, jawabanSiswa);
  // }
  //
  // /// [getJawabanSiswaLocal] mengambil temp jawaban siswa dari db local
  // static Map<String, dynamic>? getJawabanSiswaLocal({required String key}) {
  //   final Box<Map<String, dynamic>> box =
  //       Hive.box<Map<String, dynamic>>(kJawabanSiswaBox);
  //
  //   if (kDebugMode) {
  //     logger.log(
  //         'HIVE_HELPER-GetJawabanSiswaLocal: JawabanSiswaBox[$key] >> ${box.get(key)}');
  //   }
  //
  //   return box.get(key);
  // }
  //
  // /// [getJawabanSiswaLocal] mengambil semua temp jawaban siswa dari db local
  // static List<DetailJawaban> getAllJawabanSiswaLocal(
  //     {required String kodePaket, String? kodeBab}) {
  //   final Box<Map<String, dynamic>> box =
  //       Hive.box<Map<String, dynamic>>(kJawabanSiswaBox);
  //
  //   final List<Map<String, dynamic>> listDetailJawabanLocal =
  //       box.values.toList();
  //   List<DetailJawaban> listDetailJawaban = [];
  //
  //   for (Map<String, dynamic> jawaban in listDetailJawabanLocal) {
  //     if (kodeBab != null) {
  //       if (jawaban['kodePaket'] == kodePaket &&
  //           jawaban['kodeBab'] == kodeBab) {
  //         listDetailJawaban.add(DetailJawabanModel.fromJson(jawaban));
  //       }
  //     } else {
  //       if (jawaban['kodePaket'] == kodePaket) {
  //         listDetailJawaban.add(DetailJawabanModel.fromJson(jawaban));
  //       }
  //     }
  //   }
  //
  //   if (kDebugMode) {
  //     logger.log(
  //         'HIVE_HELPER-GetAllJawabanSiswaLocal: data local >> $listDetailJawabanLocal');
  //     logger.log(
  //         'HIVE_HELPER-GetAllJawabanSiswaLocal: data convert >> $listDetailJawaban');
  //   }
  //
  //   return listDetailJawaban;
  // }

  static Future<void> clearBookmarkBox() async {
    final Box<BookmarkMapel> box = Hive.box<BookmarkMapel>(kBookmarkMapelBox);
    box.clear();
  }

  static Future<void> saveBookmarkMapel(
      {required String keyBookmarkMapel,
      required BookmarkMapel dataBookmark}) async {
    final Box<BookmarkMapel> box = Hive.box<BookmarkMapel>(kBookmarkMapelBox);

    if (kDebugMode) {
      logger.log(
          'HIVE_HELPER-SaveBookmarkSoal: BookmarkBox[$keyBookmarkMapel] >> $dataBookmark');
    }

    await box.put(keyBookmarkMapel, dataBookmark);
  }

  static Future<List<BookmarkMapel>> getDaftarBookmarkMapel() async {
    final Box<BookmarkMapel> box = Hive.box<BookmarkMapel>(kBookmarkMapelBox);

    List<BookmarkMapel> daftarBookmarkMapel = box.values.toList();

    if (kDebugMode) {
      logger.log(
          'HIVE_HELPER-GetDaftarBookmarkMapel: BookmarkBox values >> $daftarBookmarkMapel');
    }

    return daftarBookmarkMapel;
  }

  static Future<BookmarkMapel?> getBookmarkMapel(
      {required String keyBookmarkMapel}) async {
    final Box<BookmarkMapel> box = Hive.box<BookmarkMapel>(kBookmarkMapelBox);

    BookmarkMapel? bookmarkMapel = box.get(keyBookmarkMapel);

    if (kDebugMode) {
      logger.log(
          'HIVE_HELPER-GetBookmarkMapel: BookmarkBox[$keyBookmarkMapel] >> $bookmarkMapel');
    }

    return bookmarkMapel;
  }

  static Future<bool> removeBookmarkMapel(
      {required String keyBookmarkMapel}) async {
    final Box<BookmarkMapel> box = Hive.box<BookmarkMapel>(kBookmarkMapelBox);

    BookmarkMapel? bookmarkMapel = box.get(keyBookmarkMapel);

    if (kDebugMode) {
      logger.log(
          'HIVE_HELPER-RemoveBookmarkMapel: BookmarkBox[$keyBookmarkMapel] >> $bookmarkMapel');
    }

    if (bookmarkMapel != null) {
      await box.delete(keyBookmarkMapel);
      return true;
    }
    return false;
  }

  static Future<BookmarkSoal?> getBookmarkSoal(
      {required String keyBookmarkMapel,
      required BookmarkSoal bookmarkSoal}) async {
    final Box<BookmarkMapel> box = Hive.box<BookmarkMapel>(kBookmarkMapelBox);

    BookmarkMapel? bookmarkMapel = box.get(keyBookmarkMapel);

    if (kDebugMode) {
      logger.log(
          'HIVE_HELPER-GetBookmarkSoal: BookmarkBox[$keyBookmarkMapel] >> $bookmarkMapel');
    }

    if (bookmarkMapel != null) {
      List<BookmarkSoal> bookmarks = bookmarkMapel.listBookmark
          .where((bookmark) =>
              bookmark.idSoal == bookmarkSoal.idSoal &&
              bookmark.nomorSoal == bookmarkSoal.nomorSoal &&
              bookmark.nomorSoalSiswa == bookmarkSoal.nomorSoalSiswa &&
              bookmark.kodePaket == bookmarkSoal.kodePaket &&
              bookmark.idBundel == bookmarkSoal.idBundel &&
              bookmark.kodeBab == bookmarkSoal.kodeBab &&
              bookmark.namaBab == bookmarkSoal.namaBab &&
              bookmark.isPaket == bookmarkSoal.isPaket &&
              bookmark.isSimpan == bookmarkSoal.isSimpan)
          .toList();

      if (bookmarks.isNotEmpty) {
        return bookmarks.first;
      }
    }
    return null;
  }

  static Future<bool> removeBookmarkSoal(
      {required String keyBookmarkMapel,
      required BookmarkSoal bookmarkSoal}) async {
    final Box<BookmarkMapel> box = Hive.box<BookmarkMapel>(kBookmarkMapelBox);

    BookmarkMapel? bookmarkMapel = box.get(keyBookmarkMapel);

    if (kDebugMode) {
      logger.log(
          'HIVE_HELPER-RemoveBookmarkSoal: BookmarkBox[$keyBookmarkMapel] >> $bookmarkMapel');
    }

    if (bookmarkMapel != null) {
      bool isExist = bookmarkMapel.listBookmark.any((bookmark) =>
          bookmark.idSoal == bookmarkSoal.idSoal &&
          bookmark.nomorSoal == bookmarkSoal.nomorSoal &&
          bookmark.nomorSoalSiswa == bookmarkSoal.nomorSoalSiswa &&
          bookmark.kodePaket == bookmarkSoal.kodePaket &&
          bookmark.idBundel == bookmarkSoal.idBundel &&
          bookmark.kodeBab == bookmarkSoal.kodeBab &&
          bookmark.namaBab == bookmarkSoal.namaBab &&
          bookmark.isPaket == bookmarkSoal.isPaket &&
          bookmark.isSimpan == bookmarkSoal.isSimpan);

      if (isExist) {
        bookmarkMapel.listBookmark.removeWhere((bookmark) =>
            bookmark.idSoal == bookmarkSoal.idSoal &&
            bookmark.nomorSoal == bookmarkSoal.nomorSoal &&
            bookmark.nomorSoalSiswa == bookmarkSoal.nomorSoalSiswa &&
            bookmark.kodePaket == bookmarkSoal.kodePaket &&
            bookmark.idBundel == bookmarkSoal.idBundel &&
            bookmark.kodeBab == bookmarkSoal.kodeBab &&
            bookmark.namaBab == bookmarkSoal.namaBab &&
            bookmark.isPaket == bookmarkSoal.isPaket &&
            bookmark.isSimpan == bookmarkSoal.isSimpan);

        await bookmarkMapel.save();
        return true;
      }
    }
    return false;
  }

  static Future<void> clearKelompokUjianPilihanBox() async {
    final Box<KelompokUjian> box =
        Hive.box<KelompokUjian>(kKelompokUjianPilihanBox);
    box.clear();
  }

  static Future<void> saveKelompokUjianPilihan(
      {required int idKelompokUjian,
      required KelompokUjian dataKelompokUjianPilihan}) async {
    final Box<KelompokUjian> box =
        Hive.box<KelompokUjian>(kKelompokUjianPilihanBox);

    if (kDebugMode) {
      logger.log('HIVE_HELPER-SaveKelompokUjianPilihan: '
          'KelompokUjianPilihanBox[$idKelompokUjian] >> $dataKelompokUjianPilihan');
    }

    await box.put(idKelompokUjian, dataKelompokUjianPilihan);
  }

  static Future<List<KelompokUjian>> getDaftarKelompokUjianPilihan() async {
    final Box<KelompokUjian> box =
        Hive.box<KelompokUjian>(kKelompokUjianPilihanBox);

    List<KelompokUjian> daftarKelompokUjianPilihan = box.values.toList();

    if (kDebugMode) {
      logger.log('HIVE_HELPER-GetDaftarKelompokUjianPilihan: '
          'KelompokUjianPilihanBox values >> $daftarKelompokUjianPilihan');
    }

    return daftarKelompokUjianPilihan;
  }

  static Future<bool> removeKelompokUjianPilihan(
      {required int idKelompokUjian}) async {
    final Box<KelompokUjian> box =
        Hive.box<KelompokUjian>(kKelompokUjianPilihanBox);

    KelompokUjian? kelompokUjian = box.get(idKelompokUjian);

    if (kDebugMode) {
      logger.log('HIVE_HELPER-RemoveKelompokUjianPilihan: '
          'KelompokUjianPilihanBox[$idKelompokUjian] >> $kelompokUjian');
    }

    if (kelompokUjian != null) {
      await box.delete(idKelompokUjian);
      return true;
    }
    return false;
  }

  static Future<void> saveKonfirmasiTOMerdeka({required String kodeTOB}) async {
    final Box<List<KelompokUjian>> box =
        Hive.box<List<KelompokUjian>>(kKonfirmasiTOMerdekaBox);

    List<KelompokUjian> daftarPilihan = await getDaftarKelompokUjianPilihan();

    if (kDebugMode) {
      logger.log('HIVE_HELPER-SaveKonfirmasiTOMerdeka: '
          'KonfirmasiTOMerdekaBox[Confirm-$kodeTOB] >> $daftarPilihan');
    }

    await box.put('Confirm-$kodeTOB', daftarPilihan);
  }

  static Future<List<KelompokUjian>> getKonfirmasiTOMerdeka(
      {required String kodeTOB}) async {
    if (isBoxOpen<List<KelompokUjian>>(boxName: kKonfirmasiTOMerdekaBox)) {
      await closeBox<List<KelompokUjian>>(boxName: kKonfirmasiTOMerdekaBox);
      await openBox(boxName: kKonfirmasiTOMerdekaBox);
    }
    final Box box = Hive.box(kKonfirmasiTOMerdekaBox);

    List daftarPilihan = box.get('Confirm-$kodeTOB') ?? [];
    List<KelompokUjian> daftarPilihanCast = daftarPilihan.cast<KelompokUjian>();

    if (kDebugMode) {
      logger.log('HIVE_HELPER-GetKonfirmasiTOMerdeka: '
          'KonfirmasiTOMerdekaBox[Confirm-$kodeTOB] >> $daftarPilihan');
      logger.log('HIVE_HELPER-GetKonfirmasiTOMerdeka: '
          'After Casting >> $daftarPilihanCast');
    }

    if (isBoxOpen(boxName: kKonfirmasiTOMerdekaBox)) {
      await closeBox(boxName: kKonfirmasiTOMerdekaBox);
      await openBox<List<KelompokUjian>>(boxName: kKonfirmasiTOMerdekaBox);
    }
    return daftarPilihanCast;
  }

  static Future<bool> removeKonfirmasiTOMerdeka(
      {required String kodeTOB}) async {
    final Box<List<KelompokUjian>> box =
        Hive.box<List<KelompokUjian>>(kKonfirmasiTOMerdekaBox);

    List<KelompokUjian>? daftarPilihan = box.get('Confirm-$kodeTOB');

    if (kDebugMode) {
      logger.log('HIVE_HELPER-RemoveKonfirmasiTOMerdeka: '
          'KelompokUjianPilihanBox[Confirm-$kodeTOB] >> $daftarPilihan');
    }

    if (daftarPilihan != null) {
      await box.delete('Confirm-$kodeTOB');
      return true;
    }
    return false;
  }

  static Future<void> clearKampusImpianBox() async {
    final Box<KampusImpian> box = Hive.box<KampusImpian>(kKampusImpianBox);
    box.clear();
  }

  static Future<void> saveKampusImpianPilihan(
      {required int pilihanKe, required KampusImpian kampusPilihan}) async {
    final Box<KampusImpian> box = Hive.box<KampusImpian>(kKampusImpianBox);
    // final Box<KampusImpian> boxRiwayat =
    //     Hive.box<KampusImpian>(kRiwayatKampusImpianBox);

    if (kDebugMode) {
      logger.log('HIVE_HELPER-SaveKampusImpianPilihan: '
          'KampusImpianPilihanBox[$pilihanKe] >> $kampusPilihan');
    }

    await box.put(pilihanKe, kampusPilihan);
  }

  static KampusImpian? getKampusImpian({required int pilihanKe}) {
    final Box<KampusImpian> box = Hive.box<KampusImpian>(kKampusImpianBox);

    KampusImpian? kampusImpian = box.get(pilihanKe);

    if (kDebugMode) {
      logger.log('HIVE_HELPER-GetKampusImpian: '
          'KampusImpianPilihanBox[$pilihanKe] >> $kampusImpian');
    }

    return kampusImpian;
  }

  static Future<List<KampusImpian>> getDaftarKampusImpian() async {
    if (isBoxOpen<KampusImpian>(boxName: kKampusImpianBox)) {
      await closeBox<KampusImpian>(boxName: kKampusImpianBox);
    }
    if (!isBoxOpen<KampusImpian>(boxName: kKampusImpianBox)) {
      await openBox<KampusImpian>(boxName: kKampusImpianBox);
    }

    final Box<KampusImpian> box = Hive.box<KampusImpian>(kKampusImpianBox);

    List<KampusImpian> daftarKampusImpian = box.values.toList();

    if (kDebugMode) {
      logger.log('HIVE_HELPER-GetDaftarKampusImpianPilihan: '
          'KampusImpianPilihanBox values >> $daftarKampusImpian');
    }

    // if (isBoxOpen<List<KelompokUjian>>(boxName: kKonfirmasiTOMerdekaBox)) {
    //   await closeBox<List<KelompokUjian>>(boxName: kKonfirmasiTOMerdekaBox);
    //   await openBox(boxName: kKonfirmasiTOMerdekaBox);
    // }
    return daftarKampusImpian;
  }

  static Future<void> clearRiwayatKampusImpian() async {
    final Box<KampusImpian> box =
        Hive.box<KampusImpian>(kRiwayatKampusImpianBox);
    box.clear();
  }

  static Future<void> saveRiwayatKampusImpianPilihan(
      {required KampusImpian kampusPilihan}) async {
    final Box<KampusImpian> boxRiwayat =
        Hive.box<KampusImpian>(kRiwayatKampusImpianBox);

    if (kDebugMode) {
      logger.log('HIVE_HELPER-SaveRiwayatKampusImpianPilihan: '
          'RiwayatKampusImpianPilihanBox[${kampusPilihan.pilihanKe}-${kampusPilihan.tanggalPilih}] '
          '>> $kampusPilihan');
    }

    await boxRiwayat.put(
        '${kampusPilihan.pilihanKe}-${kampusPilihan.tanggalPilih}',
        kampusPilihan);
  }

  static Future<void> saveAllRiwayatKampusImpian(
      {required List<KampusImpian> riwayatPilihan}) async {
    final Box<KampusImpian> box =
        Hive.box<KampusImpian>(kRiwayatKampusImpianBox);

    if (kDebugMode) {
      logger.log('HIVE_HELPER-SaveRiwayatKampusImpian: '
          'Riwayat Kampus Impian: $riwayatPilihan');
    }

    for (var riwayat in riwayatPilihan) {
      await box.put('${riwayat.pilihanKe}-${riwayat.tanggalPilih}', riwayat);
    }
  }

  static Future<List<KampusImpian>> getRiwayatKampusImpian() async {
    final Box<KampusImpian> box =
        Hive.box<KampusImpian>(kRiwayatKampusImpianBox);

    List<KampusImpian> riwayatKampusImpian = box.values.toList();

    if (kDebugMode) {
      logger.log('HIVE_HELPER-GetRiwayatKampusImpian: '
          'RiwayatKampusImpianBox values >> $riwayatKampusImpian');
    }

    return riwayatKampusImpian;
  }
}
