import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'hive_helper.dart';
import '../config/global.dart';
import '../config/extensions.dart';
import '../../features/soal/entity/peserta_to.dart';
import '../../features/soal/entity/detail_jawaban.dart';
import '../../features/soal/model/peserta_to_model.dart';
import '../../features/profile/entity/kelompok_ujian.dart';
import '../../features/ptn/module/ptnclopedia/entity/kampus_impian.dart';

class FirebaseHelper {
  static const String _kPesertaTOCollection = 'peserta_to';
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  static final FirebaseHelper _instance = FirebaseHelper._internal();

  factory FirebaseHelper() => _instance;

  FirebaseHelper._internal();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _streamCheckLogin;

  String _collectionJawabanSiswa(
      {required String tipeUser,
      required String idSekolahKelas,
      required String tahunAjaran}) {
    String collectionName = 'jawaban_';
    collectionName += (tipeUser == 'SISWA') ? 'siswa_' : 'tamu_';

    collectionName += '${idSekolahKelas}_${tahunAjaran.replaceAll('/', '-')}';

    if (kDebugMode) {
      logger.log('FIREBASE_HELPER: Collection Name >> $collectionName');
    }

    return collectionName;
  }

  void stopStreamCheckLogin() {
    if (_streamCheckLogin != null) {
      _streamCheckLogin!.cancel();
      _streamCheckLogin = null;
    }
  }

  /// Updating Imei data jika berhasil login.
  Future<void> updateImeiLogin({
    required String noRegistrasi,
    required String userType,
    required String deviceId,
  }) async {
    try {
      String collectionName = 'user-$userType';

      await _firebaseFirestore
          .collection(collectionName)
          .doc(noRegistrasi)
          .set({'imei': deviceId}).onError((e, trace) {
        if (kDebugMode) {
          logger.log("Exception-UpdateImeiLogin: Error writing document >> $e");
          logger.log("Exception-UpdateImeiLogin: StackTrace >> $trace");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        logger.log("Exception-UpdateImeiLogin: Error >> $e");
      }
    }
  }

  void streamCheckLogin({
    String? noRegistrasi,
    required String userType,
    required String deviceId,
    required VoidCallback logout,
  }) async {
    if (noRegistrasi == null) {
      if (_streamCheckLogin != null) {
        _streamCheckLogin!.cancel();
        _streamCheckLogin = null;
      }
      return;
    }

    try {
      String collectionName = 'user-$userType';

      final dataImei = await _firebaseFirestore
          .collection(collectionName)
          .doc(noRegistrasi)
          .get();

      if (!dataImei.exists || dataImei.data()?['imei'] == null) {
        if (kDebugMode) {
          logger.log('FIREBASE_HELPER-StreamCheckLogin: '
              'Data User Not Exists');
        }

        await _firebaseFirestore
            .collection(collectionName)
            .doc(noRegistrasi)
            .set({'imei': deviceId}).onError((e, trace) {
          if (kDebugMode) {
            logger.log(
                "Exception-StreamCheckLogin: Error writing document >> $e");
            logger.log("Exception-StreamCheckLogin: StackTrace >> $trace");
          }
        });
      }

      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-StreamCheckLogin: '
            'Data User ${dataImei.id} >> ${dataImei.data()}');
        logger.log('FIREBASE_HELPER-StreamCheckLogin: '
            'Data Imei >> ${dataImei.data()?['imei']}');
      }

      _streamCheckLogin = _firebaseFirestore
          .collection('user-$userType')
          .doc(noRegistrasi)
          .snapshots(includeMetadataChanges: true)
          .listen(
        (event) {
          Map<String, dynamic>? dataUser = event.data();

          if (kDebugMode) {
            logger
                .log('FIREBASE_HELPER-StreamCheckLogin: DeviceId >> $deviceId');
            logger.log('FIREBASE_HELPER-StreamCheckLogin: '
                'Data User (Exists: ${event.exists}) >> $dataUser');
          }

          bool notExist = dataUser == null || !event.exists;
          bool differentDevice =
              dataUser != null && dataUser['imei'] != deviceId;

          if (notExist || differentDevice) {
            Future.delayed(const Duration(seconds: 1)).then((_) {
              logout();
              Future.delayed(gDelayedNavigation).then((_) {
                gShowBottomDialogInfo(gNavigatorKey.currentContext!,
                    title: 'Akun ${(userType == 'ORTU') ? 'anda' : 'kamu'} '
                        'terdeteksi menggunakan perangkat lain!',
                    message:
                        'Mohon hubungi cabang terdekat untuk melakukan konfirmasi perubahan perangkat '
                        'jika terdapat pergantian perangkat. GO Kreasi mewajibkan penggunaan perangkat tunggal.');
              });
            });
          }
        },
        onError: (error) {
          if (kDebugMode) {
            logger.log('FIREBASE_HELPER-StreamCheckLogin: '
                'Error Stream >> $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        logger.log('Exception-StreamCheckLogin: $e');
      }
    }
  }

  Future<List<DetailJawaban>> getJawabanSiswaByKodeBab({
    required String tahunAjaran,
    required String noRegistrasi,
    required String tipeUser,
    required String kodePaket,
    required String kodeBab,
    required String jenisProduk,
    required String idSekolahKelas,
    required bool isSimpan,
  }) async {
    try {
      final snapshots = await _firebaseFirestore
          .collection(_collectionJawabanSiswa(
              tipeUser: tipeUser,
              idSekolahKelas: idSekolahKelas,
              tahunAjaran: tahunAjaran))
          .doc(noRegistrasi.trim())
          .collection(kodePaket)
          .where('kodeBab', isEqualTo: kodeBab)
          .where('jenisProduk', isEqualTo: jenisProduk)
          .get();

      List<DetailJawaban> listDetailJawaban = [];

      for (var doc in snapshots.docs) {
        if (kDebugMode) {
          logger.log(
              'FIREBASE_HELPER-GetJawabanSiswaByKodeBab: doc id(${doc.id}) >> ${doc.data()}');
          // logger.log(
          //     'FIREBASE_HELPER-GetJawabanSiswaByKodeBab: doc.ref >> ${(await doc.reference.get()).data()}');
        }
        listDetailJawaban.add(DetailJawaban.fromJson(doc.data()));
      }

      listDetailJawaban.removeWhere(
        (jawaban) => (isSimpan)
            ? jawaban.jawabanSiswa == null ||
                jawaban.jawabanSiswa == '' ||
                jawaban.sudahDikumpulkan
            : jawaban.jawabanSiswa == null || jawaban.jawabanSiswa == '',
      );
      listDetailJawaban
          .sort((a, b) => a.nomorSoalSiswa.compareTo(b.nomorSoalSiswa));

      return listDetailJawaban;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-GetJawabanSiswaByKodeBab: ERROR >> $e');
      }
      return [];
    }
  }

  Future<List<DetailJawaban>> getJawabanSiswaByIdBundel({
    required String tahunAjaran,
    required String noRegistrasi,
    required String tipeUser,
    required String kodePaket,
    required String idBundel,
    required String jenisProduk,
    required String idSekolahKelas,
    required bool isSimpan,
  }) async {
    try {
      final snapshots = await _firebaseFirestore
          .collection(_collectionJawabanSiswa(
              tipeUser: tipeUser,
              idSekolahKelas: idSekolahKelas,
              tahunAjaran: tahunAjaran))
          .doc(noRegistrasi.trim())
          .collection(kodePaket)
          .where('idBundel', isEqualTo: idBundel)
          .where('jenisProduk', isEqualTo: jenisProduk)
          .get();

      List<DetailJawaban> listDetailJawaban = [];

      for (var doc in snapshots.docs) {
        if (kDebugMode) {
          logger.log(
              'FIREBASE_HELPER-GetJawabanSiswaIdBundel: doc id(${doc.id}) >> ${doc.data()}');
          // logger.log(
          //     'FIREBASE_HELPER-GetJawabanSiswaIdBundel: doc.ref >> ${(await doc.reference.get()).data()}');
        }
        listDetailJawaban.add(DetailJawaban.fromJson(doc.data()));
      }

      listDetailJawaban.removeWhere(
        (jawaban) => (isSimpan)
            ? jawaban.jawabanSiswa == null ||
                jawaban.jawabanSiswa == '' ||
                jawaban.sudahDikumpulkan
            : jawaban.jawabanSiswa == null || jawaban.jawabanSiswa == '',
      );
      listDetailJawaban
          .sort((a, b) => a.nomorSoalSiswa.compareTo(b.nomorSoalSiswa));

      return listDetailJawaban;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-GetJawabanSiswaIdBundel: ERROR >> $e');
      }
      return [];
    }
  }

  Future<List<DetailJawaban>> getJawabanSiswaByKodePaket({
    required String tahunAjaran,
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tipeUser,
    required String kodePaket,
    bool kumpulkanSemua = false,
  }) async {
    try {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-GetJawabanSiswaByKodePaket: START');
      }
      final snapshots = await _firebaseFirestore
          .collection(_collectionJawabanSiswa(
              tipeUser: tipeUser,
              idSekolahKelas: idSekolahKelas,
              tahunAjaran: tahunAjaran))
          .doc(noRegistrasi.trim())
          .collection(kodePaket)
          .get();

      List<DetailJawaban> listDetailJawaban = [];

      if (kDebugMode) {
        logger.log(
            'FIREBASE_HELPER-GetJawabanSiswaByKodePaket: hasil get >> ${snapshots.docs}');
      }
      for (var doc in snapshots.docs) {
        if (kDebugMode) {
          logger.log(
              'FIREBASE_HELPER-GetJawabanSiswaByKodePaket: doc id(${doc.id}) >> ${doc.data()}');
          // logger.log(
          //     'FIREBASE_HELPER-GetJawabanSiswaByKodePaket: doc.ref >> ${(await doc.reference.get()).data()}');
        }
        DetailJawaban detailJawaban = DetailJawaban.fromJson(doc.data());
        if (kDebugMode) {
          logger.log(
              'FIREBASE_HELPER-GetJawabanSiswaByKodePaket: From Json >> $detailJawaban');
        }
        bool jawabanKosongDanBelumDikumpulkan =
            !detailJawaban.sudahDikumpulkan &&
                detailJawaban.jawabanSiswa == null;

        if (kumpulkanSemua || !jawabanKosongDanBelumDikumpulkan) {
          listDetailJawaban.add(detailJawaban);
        }
      }

      if (!kumpulkanSemua) {
        listDetailJawaban
            .removeWhere((detailJawaban) => detailJawaban.sudahDikumpulkan);
      }

      listDetailJawaban
          .sort((a, b) => a.nomorSoalSiswa.compareTo(b.nomorSoalSiswa));

      return listDetailJawaban;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-GetJawabanSiswaByKodePaket: ERROR >> $e');
      }
      return [];
    }
  }

  Future<void> setTempJawabanSiswa({
    required String tahunAjaran,
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tipeUser,
    required String kodePaket,
    required String idSoal,
    required Map<String, dynamic> jsonSoalJawabanSiswa,
  }) async {
    await _firebaseFirestore
        .collection(_collectionJawabanSiswa(
            tipeUser: tipeUser,
            idSekolahKelas: idSekolahKelas,
            tahunAjaran: tahunAjaran))
        .doc(noRegistrasi.trim())
        .collection(kodePaket)
        .doc(idSoal)
        .set(jsonSoalJawabanSiswa)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'FIREBASE_HELPER-SetTempJawabanSiswa: ERROR >> $error\n$stackTrace');
      }
    });

    if (kDebugMode) {
      logger.log(
          'FIREBASE_HELPER-SetTempJawabanSiswa: jawaban >> $jsonSoalJawabanSiswa');
    }
  }

  Future<void> updateRaguRagu({
    required String tahunAjaran,
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tipeUser,
    required String kodePaket,
    required String idSoal,
    required bool isRagu,
  }) async {
    try {
      // Get a new write batch
      final batch = _firebaseFirestore.batch();

      var jawabanRef = _firebaseFirestore
          .collection(_collectionJawabanSiswa(
              tipeUser: tipeUser,
              idSekolahKelas: idSekolahKelas,
              tahunAjaran: tahunAjaran))
          .doc(noRegistrasi.trim())
          .collection(kodePaket)
          .doc(idSoal);

      batch.update(jawabanRef, {'isRagu': isRagu});
      batch.commit();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-UpdateRaguRagu: ERROR >> $e');
      }
    }
  }

  Future<void> updateKumpulkanJawabanSiswa({
    required String tahunAjaran,
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tipeUser,
    required String kodePaket,
    required bool isKumpulkan,
    required bool onlyUpdateNull,
  }) async {
    try {
      var snapshots = (onlyUpdateNull)
          ? await _firebaseFirestore
              .collection(_collectionJawabanSiswa(
                  tipeUser: tipeUser,
                  idSekolahKelas: idSekolahKelas,
                  tahunAjaran: tahunAjaran))
              .doc(noRegistrasi.trim())
              .collection(kodePaket)
              .where('jawabanSiswa', isNull: onlyUpdateNull)
              .get()
          : (isKumpulkan)
              ? await _firebaseFirestore
                  .collection(_collectionJawabanSiswa(
                      tipeUser: tipeUser,
                      idSekolahKelas: idSekolahKelas,
                      tahunAjaran: tahunAjaran))
                  .doc(noRegistrasi.trim())
                  .collection(kodePaket)
                  .get()
              : await _firebaseFirestore
                  .collection(_collectionJawabanSiswa(
                      tipeUser: tipeUser,
                      idSekolahKelas: idSekolahKelas,
                      tahunAjaran: tahunAjaran))
                  .doc(noRegistrasi.trim())
                  .collection(kodePaket)
                  .where('jawabanSiswa', isNull: false)
                  .get();

      if (kDebugMode) {
        logger.log(
            'FIREBASE_HELPER-UpdateKumpulkanJawabanSiswa: snapshot >> ${snapshots.docs}');
      }

      for (var document in snapshots.docs) {
        // Jika kumpulkan, maka ubah semua data menjadi dikumpulkan.
        // Jika isKumpulkan false, maka artinya Simpan.
        // Jika simpan, maka hanya soal yang sudah dijawab saja yang dikumpulkan.
        document.reference.update({'sudahDikumpulkan': true}).then((_) {
          if (kDebugMode) {
            logger.log(
                'FIREBASE_HELPER-UpdateKumpulkanJawabanSiswa: after update >> ${document.data()}');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-UpdateKumpulkanJawabanSiswa: ERROR >> $e');
      }
    }
  }

  Future<void> resetRemedialGOA({
    required String tahunAjaran,
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tipeUser,
    required String kodePaket,
    required String namaKelompokUjian,
  }) async {
    try {
      var snapshots = await _firebaseFirestore
          .collection(_collectionJawabanSiswa(
              tipeUser: tipeUser,
              idSekolahKelas: idSekolahKelas,
              tahunAjaran: tahunAjaran))
          .doc(noRegistrasi.trim())
          .collection(kodePaket)
          .where('namaKelompokUjian', isEqualTo: namaKelompokUjian)
          .get();

      if (kDebugMode) {
        logger.log(
            'FIREBASE_HELPER-ResetRemedialGOA: snapshot >> ${snapshots.docs}');
      }

      for (var document in snapshots.docs) {
        // Jika kumpulkan, maka ubah semua data menjadi dikumpulkan.
        // Jika isKumpulkan false, maka artinya Simpan.
        // Jika simpan, maka hanya soal yang sudah dijawab saja yang dikumpulkan.
        document.reference.update({
          'isRagu': false,
          'jawabanSiswa': null,
          'nomorSoalSiswa': 0,
          'sudahDikumpulkan': false,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-ResetRemedialGOA: ERROR >> $e');
      }
    }
  }

  /// Perbaikan flow peserta TO ke firebase
  Future<PesertaTO?> getPesertaTOByKodePaket({
    required String noRegistrasi,
    required String tipeUser,
    required String kodePaket,
  }) async {
    try {
      if (!tipeUser.equalsIgnoreCase('SISWA')) {
        return null;
      }
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-GetPesertaTOByKodePaket: START');
      }
      final snapshots = await _firebaseFirestore
          .collection(_kPesertaTOCollection)
          .doc('${noRegistrasi.trim()}_$kodePaket')
          .get();

      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-GetPesertaTOByKodePaket: '
            'hasil get ${snapshots.exists} >> ${snapshots.data()}');
      }

      PesertaTO? pesertaTOFirebase;
      if (snapshots.exists && snapshots.data() != null) {
        pesertaTOFirebase = PesertaTOModel.fromJson(snapshots.data()!);
      }

      return pesertaTOFirebase;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-GetPesertaTOByKodePaket: ERROR >> $e');
      }
      return null;
    }
  }

  // Perbaikan flow peserta TO firebase
  Future<void> setPesertaTOFirebase({
    required String noRegistrasi,
    required String tipeUser,
    required String kodePaket,
    required PesertaTO pesertaTO,
  }) async {
    if (kDebugMode) {
      logger.log('FIREBASE_HELPER-SetPesertaTOFirebase: START With '
          'Params($noRegistrasi, $tipeUser, $kodePaket, $pesertaTO)');
    }
    if (!tipeUser.equalsIgnoreCase('SISWA')) {
      return;
    }

    if (pesertaTO.keterangan == null) {
      String merekHp, versiOS;
      final appInfo = await PackageInfo.fromPlatform();

      try {
        final deviceInfoPlugin = DeviceInfoPlugin();

        if (Platform.isIOS) {
          final iosDeviceInfo = await deviceInfoPlugin.iosInfo;

          merekHp = '${iosDeviceInfo.model} ${iosDeviceInfo.utsname.machine}';
          versiOS = 'iOS ${iosDeviceInfo.systemVersion}';
        } else {
          final androidDeviceInfo = await deviceInfoPlugin.androidInfo;

          merekHp =
              '${androidDeviceInfo.manufacturer} ${androidDeviceInfo.model}';
          versiOS =
              'Android ${androidDeviceInfo.version.release} SDK ${androidDeviceInfo.version.sdkInt}';
        }
      } catch (_) {
        merekHp = '-';
        versiOS = '-';
      }

      pesertaTO.keterangan = {
        'merk': merekHp,
        'versi_os': versiOS,
        'versi': appInfo.version,
      };
    }

    await _firebaseFirestore
        .collection(_kPesertaTOCollection)
        .doc('${noRegistrasi.trim()}_$kodePaket')
        .set(pesertaTO.toJson())
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'FIREBASE_HELPER-SetPesertaTOFirebase: ERROR >> $error\n$stackTrace');
      }
    });

    if (kDebugMode) {
      logger.log(
          'FIREBASE_HELPER-SetPesertaTOFirebase: peserta TO >> ${pesertaTO.toJson()}');
    }
  }

  Future<bool> updatePesertaTOFirebase({
    required String noRegistrasi,
    required String tipeUser,
    required String kodePaket,
    required String kodeTOB,
    required int idJenisProduk,
  }) async {
    try {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-UpdatePesertaTOFirebase: START With '
            'Params($noRegistrasi, $tipeUser, $kodePaket)');
      }
      if (!tipeUser.equalsIgnoreCase('SISWA')) {
        return true;
      }

      String tanggalMengumpulkan =
          DateTime.now().serverTimeFromOffset.sqlFormat;
      Map<String, dynamic> pilihanSiswa = {
        'jurusanPilihan': {
          "pilihan1": null,
          "pilihan2": null,
        },
        'mapelPilihan': []
      };

      if (idJenisProduk == 25) {
        List<KampusImpian> pilihanJurusanHive =
            await HiveHelper.getDaftarKampusImpian();
        List<Map<String, dynamic>> pilihanJurusan = pilihanJurusanHive
            .map<Map<String, dynamic>>((jurusan) => {
                  'kodejurusan': jurusan.idJurusan,
                  'namajurusan': jurusan.namaJurusan
                })
            .toList();

        List<KelompokUjian> pilihanKelompokUjianHive =
            await HiveHelper.getKonfirmasiTOMerdeka(kodeTOB: kodeTOB);
        List<Map<String, dynamic>> pilihanKelompokUjian =
            pilihanKelompokUjianHive
                .map<Map<String, dynamic>>((mataUji) => {
                      'id': mataUji.idKelompokUjian,
                      'namaKelompokUjian': mataUji.namaKelompokUjian
                    })
                .toList();

        pilihanSiswa = {
          'jurusanPilihan': {
            "pilihan1": (pilihanJurusan.isNotEmpty) ? pilihanJurusan[0] : null,
            "pilihan2": (pilihanJurusan.length > 1) ? pilihanJurusan[1] : null,
          },
          'mapelPilihan': pilihanKelompokUjian
        };
      }

      // Get a new write batch
      final batch = _firebaseFirestore.batch();

      var pesertaRef = _firebaseFirestore
          .collection(_kPesertaTOCollection)
          .doc('${noRegistrasi.trim()}_$kodePaket');

      batch.update(pesertaRef, {'cPilihanSiswa': pilihanSiswa});
      batch.update(pesertaRef, {'cSudahSelesai': 'y'});
      batch.update(pesertaRef, {'cTanggalTO': tanggalMengumpulkan});
      batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FIREBASE_HELPER-UpdatePesertaTOFirebase: ERROR >> $e');
      }
      return false;
    }
  }
}
