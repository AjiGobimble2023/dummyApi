import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

import '../../entity/detail_jawaban.dart';
import '../../../../../core/helper/hive_helper.dart';
import '../../../../../core/util/data_formatter.dart';

class SoalServiceLocal {
  // final _hiveHelper = HiveHelper();
  final String _jawabanSoalBox = 'BOX_JAWABAN_SOAL';

  static final SoalServiceLocal _instance = SoalServiceLocal._internal();

  factory SoalServiceLocal() => _instance;

  SoalServiceLocal._internal();

  /// Open box sebelum menggunakan hive
  Future<Box<List>> openJawabanBox() async =>
      await HiveHelper.openBox<List>(boxName: _jawabanSoalBox);

  /// Close box setelah menggunakan hive
  Future<void> closeJawabanBox() async =>
      await HiveHelper.closeBox<List>(boxName: _jawabanSoalBox);

  /// Realtime changing values listener
  ValueListenable<Box<List>> listenableJawabanSoal() =>
      HiveHelper.valueListenable<List>(_jawabanSoalBox);

  Future<List<DetailJawaban>> getJawabanSiswaByKodeBab({
    required String kodePaket,
    required String kodeBab,
    required String jenisProduk,
  }) async {
    try {
      final Box<List> box = HiveHelper.box<List>(_jawabanSoalBox);

      List<DetailJawaban> listDetailJawaban =
          [...(box.get(kodePaket) ?? [])].cast<DetailJawaban>();

      if (kDebugMode) {
        logger.log(
            'SOAL_SERVICE_LOCAL-GetJawabanSiswaByKodeBab: (${box.get(kodePaket)?.length}) '
            'JawabanSoalBox[$kodePaket] >> ${box.get(kodePaket)}');
      }

      if (listDetailJawaban.isNotEmpty) {
        listDetailJawaban.removeWhere(
          (jawaban) =>
              jawaban.jawabanSiswa == null ||
              jawaban.kodeBab != kodeBab ||
              jawaban.jenisProduk != jenisProduk,
        );

        listDetailJawaban
            .sort((a, b) => a.nomorSoalSiswa.compareTo(b.nomorSoalSiswa));
      }

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByKodeBab: '
            'Result Filter Bab (${listDetailJawaban.length}) >> $listDetailJawaban');
      }

      return listDetailJawaban;
    } catch (e) {
      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByKodeBab: ERROR >> $e');
      }
      return [];
    }
  }

  Future<List<DetailJawaban>> getJawabanSiswaByIdBundel({
    required String kodePaket,
    required String idBundel,
    required String jenisProduk,
  }) async {
    try {
      final Box<List> box = HiveHelper.box<List>(_jawabanSoalBox);

      List<DetailJawaban> listDetailJawaban =
          [...(box.get(kodePaket) ?? [])].cast<DetailJawaban>();

      if (kDebugMode) {
        logger
            .log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByIdBundel: Before Remove '
                '(${box.get(kodePaket)?.length}) '
                'JawabanSoalBox[$kodePaket] >> ${box.get(kodePaket)}');
      }

      if (listDetailJawaban.isNotEmpty) {
        listDetailJawaban.removeWhere(
          (jawaban) =>
              jawaban.jawabanSiswa == null ||
              jawaban.idBundel != idBundel ||
              jawaban.jenisProduk != jenisProduk,
        );

        listDetailJawaban
            .sort((a, b) => a.nomorSoalSiswa.compareTo(b.nomorSoalSiswa));
      }

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByIdBundel: '
            'Result Filter Bab (${listDetailJawaban.length}) >> $listDetailJawaban');
      }

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByIdBundel: After Remove '
            '(${box.get(kodePaket)?.length}) '
            'JawabanSoalBox[$kodePaket] >> ${box.get(kodePaket)}');
      }

      return listDetailJawaban;
    } catch (e) {
      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByIdBundel: ERROR >> $e');
      }
      return [];
    }
  }

  Future<List<DetailJawaban>> getJawabanSiswaByKodePaket({
    required String kodePaket,
    bool kumpulkanSemua = false,
  }) async {
    try {
      final Box<List> box = HiveHelper.box<List>(_jawabanSoalBox);

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByKodePaket: START');
      }

      List<DetailJawaban> listDetailJawaban =
          [...(box.get(kodePaket) ?? [])].cast<DetailJawaban>();

      if (kDebugMode) {
        logger.log(
            'SOAL_SERVICE_LOCAL-GetJawabanSiswaByKodePaket: (${box.get(kodePaket)?.length})'
            'JawabanSoalBox[$kodePaket] >> ${box.get(kodePaket)}');
      }

      if (listDetailJawaban.isNotEmpty) {
        if (!kumpulkanSemua) {
          listDetailJawaban.removeWhere((jawaban) =>
              !jawaban.sudahDikumpulkan && jawaban.jawabanSiswa == null);
        }

        listDetailJawaban
            .sort((a, b) => a.nomorSoalSiswa.compareTo(b.nomorSoalSiswa));
      }

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByKodePaket: '
            'Result Filter Kode Paket (${listDetailJawaban.length}) >> $listDetailJawaban');
      }

      return listDetailJawaban;
    } catch (e) {
      if (kDebugMode) {
        logger
            .log('SOAL_SERVICE_LOCAL-GetJawabanSiswaByKodePaket: ERROR >> $e');
      }
      return [];
    }
  }

  Future<bool> setTempJawabanSiswa({
    required String kodePaket,
    required String idSoal,
    required Map<String, dynamic> jsonSoalJawabanSiswa,
  }) async {
    final Box<List> box = HiveHelper.box<List>(_jawabanSoalBox);

    List<DetailJawaban> listDetailJawaban =
        [...box.get(kodePaket) ?? []].cast<DetailJawaban>();

    if (kDebugMode) {
      logger.log('SOAL_SERVICE_LOCAL-SetTempJawabanSiswa: '
          'JawabanSoalBox[$kodePaket] >> ${listDetailJawaban.length}');
    }

    listDetailJawaban.removeWhere((jawaban) => jawaban.idSoal == idSoal);

    final jawabanSiswa = DetailJawaban.fromJson(jsonSoalJawabanSiswa);

    listDetailJawaban.add(jawabanSiswa);

    if (kDebugMode) {
      logger.log(
          'SOAL_SERVICE_LOCAL-SetTempJawabanSiswa: jawaban >> $jsonSoalJawabanSiswa');
    }

    bool berhasilSimpan = true;

    await box.put(kodePaket, listDetailJawaban).catchError((error, stackTrace) {
      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-SetTempJawabanSiswa: ERROR >> $error');
        logger.log(
            'SOAL_SERVICE_LOCAL-SetTempJawabanSiswa: STACKTRACE >> $stackTrace');
      }
      berhasilSimpan = false;
    });

    return berhasilSimpan;
  }

  Future<bool> updateRaguRagu({
    required String kodePaket,
    required String idSoal,
    required bool isRagu,
  }) async {
    try {
      final Box<List> box = HiveHelper.box<List>(_jawabanSoalBox);

      List<DetailJawaban> listDetailJawaban =
          [...box.get(kodePaket) ?? []].cast<DetailJawaban>();

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-UpdateRaguRagu: '
            'JawabanSoalBox[$kodePaket] >> $listDetailJawaban');
      }

      if (listDetailJawaban.isNotEmpty) {
        final jawabanSiswa =
            listDetailJawaban.firstWhere((jawaban) => jawaban.idSoal == idSoal);

        var jawabanSiswaJson = jawabanSiswa.toJson();

        jawabanSiswaJson.update('isRagu', (value) => isRagu);
        jawabanSiswaJson.update(
            'lastUpdate', (value) => DataFormatter.formatLastUpdate());

        listDetailJawaban.removeWhere((jawaban) => jawaban.idSoal == idSoal);
        listDetailJawaban.add(DetailJawaban.fromJson(jawabanSiswaJson));

        bool berhasilSimpan = true;
        await box
            .put(kodePaket, listDetailJawaban)
            .catchError((error, stackTrace) {
          if (kDebugMode) {
            logger
                .log('SOAL_SERVICE_LOCAL-SetTempJawabanSiswa: ERROR >> $error');
            logger.log(
                'SOAL_SERVICE_LOCAL-SetTempJawabanSiswa: STACKTRACE >> $stackTrace');
          }
          berhasilSimpan = false;
        });

        return berhasilSimpan;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-UpdateRaguRagu: ERROR >> $e');
      }
      return false;
    }
  }

  Future<bool> updateKumpulkanJawabanSiswa({
    required String kodePaket,
    required bool isKumpulkan,
    required bool onlyUpdateNull,
  }) async {
    try {
      final Box<List> box = HiveHelper.box<List>(_jawabanSoalBox);

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: START');
      }

      List<DetailJawaban> listDetailJawaban =
          [...(box.get(kodePaket) ?? [])].cast<DetailJawaban>();

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: '
            'JawabanSoalBox[$kodePaket] >> ${box.get(kodePaket)}');
      }

      List<DetailJawaban> listDetailJawabanTemp = [];
      if (listDetailJawaban.isNotEmpty) {
        if (onlyUpdateNull) {
          listDetailJawaban.removeWhere((jawaban) {
            if (jawaban.jawabanSiswa != null) {
              listDetailJawabanTemp.add(jawaban);
            }
            return jawaban.jawabanSiswa != null;
          });
        }

        if (!isKumpulkan) {
          listDetailJawaban.removeWhere((jawaban) {
            if (jawaban.jawabanSiswa == null) {
              listDetailJawabanTemp.add(jawaban);
            }
            return jawaban.jawabanSiswa == null;
          });
        }

        if (kDebugMode) {
          logger.log('SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: '
              'Only Update Null >> $onlyUpdateNull');
          logger.log('SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: '
              'Is Kumpulkan >> $isKumpulkan');
          logger.log('SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: '
              'List Jawaban after >> $listDetailJawaban');
        }

        for (var detailJawaban in listDetailJawaban) {
          // Jika kumpulkan, maka ubah semua data menjadi dikumpulkan.
          // Jika isKumpulkan false, maka artinya Simpan.
          // Jika simpan, maka hanya soal yang sudah dijawab saja yang dikumpulkan.
          var jawabanSiswaJson = detailJawaban.toJson();

          jawabanSiswaJson.update('sudahDikumpulkan', (value) => true);
          jawabanSiswaJson.update(
              'lastUpdate', (value) => DataFormatter.formatLastUpdate());

          listDetailJawabanTemp.add(DetailJawaban.fromJson(jawabanSiswaJson));
        }

        bool berhasilSimpan = true;
        await box
            .put(kodePaket, listDetailJawabanTemp)
            .catchError((error, stackTrace) {
          if (kDebugMode) {
            logger.log(
                'SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: ERROR >> $error');
            logger.log(
                'SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: STACKTRACE >> $stackTrace');
          }
          berhasilSimpan = false;
        });

        return berhasilSimpan;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger
            .log('SOAL_SERVICE_LOCAL-UpdateKumpulkanJawabanSiswa: ERROR >> $e');
      }
      return false;
    }
  }

  Future<void> resetRemedialGOA({
    required String kodePaket,
    required String namaKelompokUjian,
  }) async {
    try {
      final Box<List> box = HiveHelper.box<List>(_jawabanSoalBox);

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-ResetRemedialGOA: START');
      }

      List<DetailJawaban> listDetailJawaban =
          [...(box.get(kodePaket) ?? [])].cast<DetailJawaban>();

      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-ResetRemedialGOA: '
            'JawabanSoalBox[$kodePaket] >> ${box.get(kodePaket)}');
      }

      if (listDetailJawaban.isNotEmpty) {
        listDetailJawaban.removeWhere(
            (jawaban) => jawaban.namaKelompokUjian == namaKelompokUjian);

        if (kDebugMode) {
          logger.log('SOAL_SERVICE_LOCAL-ResetRemedialGOA: '
              'List Jawaban After Reset >> $listDetailJawaban');
        }

        await box
            .put(kodePaket, listDetailJawaban)
            .catchError((error, stackTrace) {
          if (kDebugMode) {
            logger.log('SOAL_SERVICE_LOCAL-ResetRemedialGOA: ERROR >> $error');
            logger.log(
                'SOAL_SERVICE_LOCAL-ResetRemedialGOA: STACKTRACE >> $stackTrace');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('SOAL_SERVICE_LOCAL-ResetRemedialGOA: ERROR >> $e');
      }
    }
  }
}
