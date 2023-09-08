import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../profile/entity/kelompok_ujian.dart';
import '../../../../ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../../../../core/helper/api_helper.dart';
import '../../../../../core/helper/hive_helper.dart';
import '../../../../../core/util/app_exceptions.dart';

class TOBServiceApi {
  final _apiHelper = ApiHelper();

  static final TOBServiceApi _instance = TOBServiceApi._internal();

  factory TOBServiceApi() => _instance;

  TOBServiceApi._internal();

  Future<List<dynamic>> fetchDaftarTOB({
    String? noRegistrasi,
    required String idSekolahKelas,
    required String idJenisProduk,
    required String roleTeaser,
    required bool isProdukDibeli,
  }) async {
    final Map<String, dynamic> response = await _apiHelper.requestPost(
        jwt: noRegistrasi != null,
        pathUrl: '/tryout/$idJenisProduk',
        bodyParams: {
          'noRegistrasi': noRegistrasi,
          'teaserRole': roleTeaser,
          'idSekolahKelas': idSekolahKelas,
          'diBeli': isProdukDibeli,
        });

    if (kDebugMode) {
      logger.log('TOB_SERVICE_API-FetchDaftarTOB: response >> $response');
    }

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'];
  }

  Future<Map<String, dynamic>> cekBolehTO({
    String? noRegistrasi,
    required String kodeTOB,
    required String namaTOB,
  }) async {
    final Map<String, dynamic> response = await _apiHelper.requestPost(
      pathUrl: '/tryout/syarat/$kodeTOB/$noRegistrasi',
      bodyParams: {'namaTOB': namaTOB},
    );

    if (kDebugMode) {
      logger.log('TOB_SERVICE_API-CekBolehTO: response >> $response');
    }

    return response;
  }

  /// Jika User belum login, maka [noRegistrasi] diisi dengan imei device.
  Future<List<dynamic>> fetchDaftarPaketTO({
    String? noRegistrasi,
    String? kodeTOB,
    String? idJenisProduk,
    String? teaserRole,
    String? idSekolahKelas,
    bool isProdukDibeli = false,
    required bool isTryout,
  }) async {
    final Map<String, dynamic> response = await _apiHelper.requestPost(
      pathUrl: isTryout
          ? '/tryout/paket/$kodeTOB'
          : '/bukusoal/paket/timer/$idJenisProduk',
      bodyParams: isTryout
          ? {'noRegistrasi': noRegistrasi}
          : {
              'noRegistrasi': noRegistrasi,
              'teaserRole': teaserRole,
              'idSekolahKelas': idSekolahKelas,
              'diBeli': isProdukDibeli,
            },
    );

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  Future<List<dynamic>> fetchKisiKisi({required String kodePaket}) async {
    final Map<String, dynamic> response = await _apiHelper.requestPost(
        pathUrl: '/tryout/kisikisipaket', bodyParams: {'kodepaket': kodePaket});

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  Future<List<dynamic>> fetchDetailWaktu({required String kodePaket}) async {
    final Map<String, dynamic> response = await _apiHelper.requestPost(
        pathUrl: '/tryout/detailwaktu', bodyParams: {'kodepaket': kodePaket});

    if (!response['status']) throw DataException(message: response['message']);

    return response['data'] ?? [];
  }

  /// [isRemedialGOA] menandakan GOA ini remedial atau tidak, untuk selain GOA isi dengan false.<br>
  /// [jenisStart] (awal / lanjutan). Menandakan apakah Siswa mengerjakan
  /// dari awal atau melanjutkan.<br>
  /// [waktu] pengerjaan soal didapat dari totalWaktu paket.<br>
  /// [tanggalSelesai] merupakan tanggal seharusnya siswa selesai mengerjakan,
  /// didapat dari response saat get paket. (format: 2022-07-14 13:00:00 | yyyy-MM-dd HH:mm:ss)<br>
  /// [tanggalKedaluwarsaTOB] didapat dari Object TOB. (format: 2022-07-14 13:00:00 | yyyy-MM-dd HH:mm:ss)
  Future<Map<String, dynamic>> fetchDaftarSoalTO({
    required String kodeTOB,
    required bool isRemedialGOA,
    String? noRegistrasi,
    required String kodePaket,
    required String jenisStart,
    required String waktu,
    String? tanggalSelesai,
    String? tanggalSiswaSubmit,
    required String tanggalKedaluwarsaTOB,
  }) async {
    String merekHp, versiOS;
    final appInfo = await PackageInfo.fromPlatform();
    var params = {
      'isremedial': isRemedialGOA,
      'kodepaket': kodePaket,
      'jenisstart': jenisStart,
      'nis': noRegistrasi,
      'waktu': waktu,
      'tanggalTO': tanggalSiswaSubmit,
      'tanggalselesai': tanggalSelesai,
      'tanggalbatasakhir': tanggalKedaluwarsaTOB,
      'versi': '${appInfo.version}(${appInfo.buildNumber})',
    };

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isIOS) {
        final iosDeviceInfo = await deviceInfoPlugin.iosInfo;

        merekHp = '${iosDeviceInfo.model} ${iosDeviceInfo.utsname.machine}';
        versiOS = 'iOS ${iosDeviceInfo.systemVersion}';
      } else {
        final androidDeviceInfo = await deviceInfoPlugin.androidInfo;

        merekHp =
            '${androidDeviceInfo.manufacturer} ${androidDeviceInfo.brand} ${androidDeviceInfo.model}';
        versiOS =
            'Android ${androidDeviceInfo.version.release} SDK ${androidDeviceInfo.version.sdkInt}';
      }
    } catch (_) {
      merekHp = '-';
      versiOS = '-';
    }
    params.putIfAbsent('merk', () => merekHp);
    params.putIfAbsent('versi_os', () => versiOS);

    // Belum ada di update 1.1.2
    if (kodePaket.contains('TO')) {
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
      List<Map<String, dynamic>> pilihanKelompokUjian = pilihanKelompokUjianHive
          .map<Map<String, dynamic>>((mataUji) => {
                'id': mataUji.idKelompokUjian,
                'namaKelompokUjian': mataUji.namaKelompokUjian
              })
          .toList();

      params.putIfAbsent(
          'keterangan',
          () => {
                'jurusanPilihan': {
                  "pilihan1":
                      (pilihanJurusan.isNotEmpty) ? pilihanJurusan[0] : null,
                  "pilihan2":
                      (pilihanJurusan.length > 1) ? pilihanJurusan[1] : null,
                },
                'mapelPilihan': pilihanKelompokUjian
              });
    }

    final Map<String, dynamic> response = await _apiHelper.requestPost(
        pathUrl: '/tryout/daftarsoalto', bodyParams: params);

    if (!response['status']) throw DataException(message: response['message']);

    return {
      'sisaWaktu': response['sisawaktu'],
      'data': response['data'] ?? [],
    };
  }

  Future<bool> updatePesertaTO({
    String? noRegistrasi,
    required String kodePaket,
    required String tahunAjaran,
    required int idJenisProduk,
    required String kodeTOB,
  }) async {
    try {
      Map<String, dynamic> params = {
        'noRegistrasi': noRegistrasi,
        'kodePaket': kodePaket,
        'tahunAjaran': tahunAjaran,
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

        params.putIfAbsent(
            'keterangan',
            () => {
                  'jurusanPilihan': {
                    "pilihan1":
                        (pilihanJurusan.isNotEmpty) ? pilihanJurusan[0] : null,
                    "pilihan2":
                        (pilihanJurusan.length > 1) ? pilihanJurusan[1] : null,
                  },
                  'mapelPilihan': pilihanKelompokUjian
                });
      }

      final Map<String, dynamic> response = await _apiHelper.requestPost(
        pathUrl: '/tryout/peserta/update',
        bodyParams: params,
      );

      return response['status'];
    } catch (e) {
      if (kDebugMode) {
        logger.log('TOB_SERVICE_API-UpdatePesertaTO: $e');
      }
      return false;
    }
  }

  // Untuk sementara API ini hanya di gunakan untuk GOA saja.
  // Untuk timer selain GOA di pindahkan ke updatePesertaTO
  Future<bool> simpanJawabanTO({
    String? noRegistrasi,
    String? tipeUser,
    required String tingkatKelas,
    required String idSekolahKelas,
    required String idKota,
    required String idGedung,
    required String kodeTOB,
    required String kodePaket,
    required String tahunAjaran,
    required int idJenisProduk,
    required List<Map<String, dynamic>> detailJawaban,
  }) async {
    Map<String, dynamic> params = {
      'nis': noRegistrasi,
      'role': tipeUser,
      'idpenanda': idKota,
      'idgedung': idGedung,
      'idsekolahkelas': idSekolahKelas,
      'idtingkatkelas': tingkatKelas,
      'tahunajaran': tahunAjaran,
      'jenisproduk': idJenisProduk,
      'kodetob': kodeTOB,
      'kodepaket': kodePaket,
      'detailJawaban': detailJawaban
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

      // params.putIfAbsent(
      //     'jurusanpilihan',
      //     () => {
      //           "pilihan1": pilihanJurusan[0],
      //           "pilihan2": pilihanJurusan[1],
      //         });

      List<KelompokUjian> pilihanKelompokUjianHive =
          await HiveHelper.getKonfirmasiTOMerdeka(kodeTOB: kodeTOB);
      List<Map<String, dynamic>> pilihanKelompokUjian = pilihanKelompokUjianHive
          .map<Map<String, dynamic>>((mataUji) => {
                'id': mataUji.idKelompokUjian,
                'namaKelompokUjian': mataUji.namaKelompokUjian
              })
          .toList();

      // params.putIfAbsent('mapelpilihan', () => pilihanKelompokUjian);
      params.putIfAbsent(
          'keterangan',
          () => {
                'jurusanPilihan': {
                  "pilihan1":
                      (pilihanJurusan.isNotEmpty) ? pilihanJurusan[0] : null,
                  "pilihan2":
                      (pilihanJurusan.length > 1) ? pilihanJurusan[1] : null,
                },
                'mapelPilihan': pilihanKelompokUjian
              });
    }

    // idJenisProduk 12 adalah e-GOA
    final Map<String, dynamic> response = await _apiHelper.requestPost(
        pathUrl: '/${(idJenisProduk == 12) ? 'profiling' : 'tryout'}'
            '/simpanjawaban',
        bodyParams: params);

    if (kDebugMode) {
      logger.log('Kumpulkan Jawaban TO-GOA response >> $response');
    }

    return response['status'];
  }

  Future<dynamic> fetchLaporanGOA({
    String? noRegistrasi,
    required String kodePaket,
  }) async {
    // idJenisProduk 12 adalah e-GOA
    final Map<String, dynamic> response = await _apiHelper.requestPost(
        jwt: noRegistrasi != null,
        pathUrl: '/profiling/laporanlulus',
        bodyParams: {
          'nis': noRegistrasi,
          'kodepaket': kodePaket,
        });

    return response['data'];
  }
}
