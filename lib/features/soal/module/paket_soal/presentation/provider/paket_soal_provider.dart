// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:kreasi/features/soal/module/timer_soal/model/tob_model.dart';

import '../../../timer_soal/entity/tob.dart';
import '../../entity/paket_soal.dart';
import '../../model/paket_soal_model.dart';
import '../../service/paket_soal_service_api.dart';
import '../../../../entity/soal.dart';
import '../../../../model/soal_model.dart';
import '../../../../entity/detail_jawaban.dart';
import '../../../../service/api/soal_service_api.dart';
import '../../../../service/local/soal_service_local.dart';
import '../../../../presentation/provider/soal_provider.dart';
import '../../../../../bookmark/entity/bookmark.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';
import '../../../../../../core/helper/firebase_helper.dart';

class PaketSoalProvider extends SoalProvider {
  final _apiService = PaketSoalServiceApi();
  final _soalApiService = SoalServiceAPI();
  final _firebaseHelper = FirebaseHelper();
  final _soalServideLocal = SoalServiceLocal();

  /// [_listPaketSoal] merupakan cache paket soal.
  final Map<int, List<PaketSoal>> _listPaketSoal = {};
  final Map<String, List<Tob>> _listTOBBersyarat = {};

  // Local Variable
  bool _isLoadingPaket = true;
  bool _isLoadingSoal = true;
  bool _isJWT = false;
  bool _isSudahDikumpulkanSemua = false;
  DateTime? _serverTime;

  // Getter
  bool get isLoadingPaket => _isLoadingPaket;
  bool get isLoadingSoal => _isLoadingSoal;
  // bool get isSudahDikumpulkanSemua => _isSudahDikumpulkanSemua;
  DateTime get serverTime => _serverTime ?? DateTime.now();

  UnmodifiableListView<Tob> getListDaftarTOBBersyarat(String kodePaket) =>
      UnmodifiableListView(_listTOBBersyarat[kodePaket] ?? []);

  UnmodifiableListView<PaketSoal> getListPaketByJenisProduk(
          int idJenisProduk) =>
      UnmodifiableListView(_listPaketSoal[idJenisProduk] ?? []);

  UnmodifiableListView<Soal> getListSoal({required String kodePaket}) =>
      UnmodifiableListView(listSoal[kodePaket] ?? []);

  bool isSudahDikumpulkanSemua({required String kodePaket}) {
    if (!_isSudahDikumpulkanSemua) {
      _isSudahDikumpulkanSemua =
          (listSoal[kodePaket]?.every((soal) => soal.sudahDikumpulkan) ??
              false);
    }
    return _isSudahDikumpulkanSemua;
  }

  @override
  void disposeValues() {
    _listPaketSoal.clear();
    listSoal.clear();
    super.disposeValues();
  }

  Future<List<Tob>> getDaftarTOBBersyarat({
    required String kodePaket,
  }) async {
    if (_listTOBBersyarat.containsKey(kodePaket) &&
        (_listTOBBersyarat[kodePaket]?.isNotEmpty ?? false)) {
      return getListDaftarTOBBersyarat(kodePaket);
    }

    var completer = Completer();
    gNavigatorKey.currentState!.context
        .showBlockDialog(dismissCompleter: completer);

    try {
      final responseData = await _apiService.fetchDaftarTOBBersyarat(
        kodePaket: kodePaket,
      );

      completer.complete();

      if (kDebugMode) {
        logger.log('PAKET_SOAL_PROVIDER-GetDaftarTOBBersyarat: '
            'responseData >> $responseData');
      }

      if (!_listTOBBersyarat.containsKey(kodePaket)) {
        _listTOBBersyarat[kodePaket] = [];
      }

      if (responseData.isNotEmpty &&
          (_listTOBBersyarat[kodePaket]?.isEmpty ?? false)) {
        for (Map<String, dynamic> tob in responseData) {
          _listTOBBersyarat[kodePaket]!.add(TobModel.fromJson(tob));
        }
      }

      return getListDaftarTOBBersyarat(kodePaket);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDaftarTOBBersyarat: $e');
      }
      completer.complete();
      await gShowTopFlash(
          gNavigatorKey.currentState!.context, gPesanErrorKoneksi);

      return getListDaftarTOBBersyarat(kodePaket);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDaftarTOBBersyarat: $e');
      }
      completer.complete();
      // await gShowTopFlash(gNavigatorKey.currentState!.context, '$e');

      return getListDaftarTOBBersyarat(kodePaket);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDaftarTOBBersyarat: ${e.toString()}');
      }
      completer.complete();
      await gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);

      return getListDaftarTOBBersyarat(kodePaket);
    }
  }

  Future<void> toggleRaguRagu({
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    required String kodePaket,
  }) async {
    // Toggle soal ragu-ragu
    soal.isRagu = !soal.isRagu;

    if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
      await _firebaseHelper.updateRaguRagu(
        tahunAjaran: tahunAjaran,
        noRegistrasi: noRegistrasi,
        idSekolahKelas: idSekolahKelas,
        tipeUser: tipeUser,
        kodePaket: kodePaket,
        idSoal: soal.idSoal,
        isRagu: soal.isRagu,
      );
    } else {
      await _soalServideLocal.updateRaguRagu(
        kodePaket: kodePaket,
        idSoal: soal.idSoal,
        isRagu: soal.isRagu,
      );
    }
    notifyListeners();
  }

  Future<void> setTempJawaban({
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    required String kodePaket,
    required String jenisProduk,
    Soal? soalTemp,
    dynamic jawabanSiswa,
  }) async {
    try {
      if (kDebugMode) {
        logger.log(
            'PAKET_SOAL_PROVIDER-SetTempJawaban: params($tahunAjaran, $noRegistrasi, $tipeUser, $kodePaket, $jenisProduk, $jawabanSiswa)');
      }
      if (soalTemp == null) {
        setNilai(jawabanSiswa: jawabanSiswa);

        soal.jawabanSiswa = (jawabanSiswa == '') ? null : jawabanSiswa;
        soal.jawabanSiswaEPB = setJawabanEPB(
          soal.tipeSoal,
          soal.jawabanSiswa,
          soal.translatorEPB,
        );
        soal.lastUpdate = lastUpdateNowFormatted;
      } else {
        final Map<String, dynamic> jsonOpsi = jsonDecode(soalTemp.opsi);
        var nilai = jsonOpsi['nilai']['zerocredit'];

        soalTemp.nilai = (nilai is double)
            ? nilai
            : (int.tryParse('$nilai'.trim()) ?? 0).toDouble();
        soalTemp.lastUpdate = lastUpdateNowFormatted;
        soalTemp.jawabanSiswa = (jawabanSiswa == '') ? null : jawabanSiswa;
        soalTemp.jawabanSiswaEPB = setJawabanEPB(
          soalTemp.tipeSoal,
          soalTemp.jawabanSiswa,
          soalTemp.translatorEPB,
        );
      }

      DetailJawaban detailJawabanSiswa = DetailJawaban(
          jenisProduk: jenisProduk,
          kodePaket: kodePaket,
          idBundel: (soalTemp ?? soal).idBundle!,
          kodeBab: null,
          idSoal: (soalTemp ?? soal).idSoal,
          nomorSoalDatabase: (soalTemp ?? soal).nomorSoal,
          nomorSoalSiswa: (soalTemp ?? soal).nomorSoalSiswa,
          idKelompokUjian: (soalTemp ?? soal).idKelompokUjian,
          namaKelompokUjian: (soalTemp ?? soal).namaKelompokUjian,
          tipeSoal: (soalTemp ?? soal).tipeSoal,
          tingkatKesulitan: (soalTemp ?? soal).tingkatKesulitan,
          jawabanSiswa: (jawabanSiswa == '') ? null : jawabanSiswa,
          kunciJawaban:
              (soalTemp == null) ? soal.kunciJawaban : soalTemp.kunciJawaban,
          translatorEPB:
              (soalTemp == null) ? soal.translatorEPB : soalTemp.translatorEPB,
          kunciJawabanEPB: (soalTemp == null)
              ? soal.kunciJawabanEPB
              : soalTemp.kunciJawabanEPB,
          jawabanSiswaEPB: (soalTemp == null)
              ? soal.jawabanSiswaEPB
              : soalTemp.jawabanSiswaEPB,
          infoNilai: (soalTemp == null)
              ? jsonOpsi['nilai'] as Map<String, dynamic>
              : jsonDecode(soalTemp.opsi)['nilai'],
          nilai: (soalTemp ?? soal).nilai,
          isRagu: (soalTemp ?? soal).isRagu,
          sudahDikumpulkan: false,
          lastUpdate: (soalTemp ?? soal).lastUpdate);

      if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
        // Penyimpanan untuk SISWA dan TAMU.
        await _firebaseHelper.setTempJawabanSiswa(
          tahunAjaran: tahunAjaran,
          idSekolahKelas: idSekolahKelas,
          noRegistrasi: noRegistrasi,
          tipeUser: tipeUser,
          kodePaket: kodePaket,
          idSoal: (soalTemp ?? soal).idSoal,
          jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
        );
      } else {
        // Penyimpanan untuk Teaser No User dan Ortu.
        await _soalServideLocal.setTempJawabanSiswa(
          kodePaket: kodePaket,
          idSoal: (soalTemp ?? soal).idSoal,
          jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
        );
      }
      // notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('PAKETSOAL-FatalException-SetTempJawaban: $e');
      }
    }
  }

  Future<List<DetailJawaban>> _getDetailJawabanSiswa({
    required String kodePaket,
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    required bool kumpulkanSemua,
  }) async {
    // Jika user login
    if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
      // Penyimpanan untuk SISWA dan TAMU.
      return await _firebaseHelper.getJawabanSiswaByKodePaket(
        tahunAjaran: tahunAjaran,
        noRegistrasi: noRegistrasi,
        tipeUser: tipeUser,
        kodePaket: kodePaket,
        idSekolahKelas: idSekolahKelas,
        kumpulkanSemua: kumpulkanSemua,
      );
    } else {
      // Penyimpanan untuk Teaser No User dan Ortu.
      return await _soalServideLocal.getJawabanSiswaByKodePaket(
        kodePaket: kodePaket,
        kumpulkanSemua: kumpulkanSemua,
      );
    }
  }

  Future<void> getDaftarPaketSoal({
    String? noRegistrasi,
    required String idSekolahKelas,
    required int idJenisProduk,
    String roleTeaser = 'No User',
    bool isProdukDibeli = false,
    bool isRefresh = false,
  }) async {
    // Jika tidak refresh dan data sudah ada di cache [_listPaketSoal]
    // maka return List dari [_listPaketSoal].
    if (!isRefresh && (_listPaketSoal[idJenisProduk]?.isNotEmpty ?? false)) {
      return;
    }
    if (isRefresh) {
      _isLoadingPaket = true;
      notifyListeners();
      _listPaketSoal[idJenisProduk]?.clear();
    }
    try {
      // Untuk jwt request soal
      _isJWT = noRegistrasi != null;

      final responseData = await _apiService.fetchDaftarPaketSoal(
          noRegistrasi: noRegistrasi,
          idSekolahKelas: idSekolahKelas,
          idJenisProduk: '$idJenisProduk',
          roleTeaser: roleTeaser,
          isProdukDibeli: isProdukDibeli);

      // Jika [_listPaketSoal] tidak memiliki key idJenisProduk tertentu maka buat key valuenya dulu;
      if (!_listPaketSoal.containsKey(idJenisProduk)) {
        _listPaketSoal[idJenisProduk] = [];
      }
      // Cek apakah response data memiliki data atau tidak
      if (responseData.isNotEmpty) {
        for (Map<String, dynamic> dataPaket in responseData) {
          // Konversi dataPaket menjadi PaketSoalModel dan store ke cache [_listPaketSoal]
          _listPaketSoal[idJenisProduk]!
              .add(PaketSoalModel.fromJson(dataPaket));
        }
      }

      _isLoadingPaket = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDaftarPaketSoal: $e');
      }
      _isLoadingPaket = false;
      notifyListeners();
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDaftarPaketSoal: $e');
      }
      _isLoadingPaket = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDaftarPaketSoal: ${e.toString()}');
      }
      _isLoadingPaket = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getDaftarSoal(
      {required String kodePaket,
      required String jenisProduk,
      required String tahunAjaran,
      required String idSekolahKelas,
      String? noRegistrasi,
      String? tipeUser,
      bool isKumpulkan = false,
      bool isRefresh = false,
      bool isKedaluwarsa = false,
      int nomorSoalAwal = 1}) async {
    if (!_isLoadingSoal) {
      _isLoadingSoal = true;
      notifyListeners();
    }
    // Update Server Time untuk cek empati wajib
    _serverTime = await gGetServerTime();
    // Set value indexSoal dan cacheKey pada soal_provider.dart
    cacheKey = kodePaket;
    indexSoal = (nomorSoalAwal > 0) ? nomorSoalAwal - 1 : 0;
    // Jika tidak refresh dan data sudah ada di cache [listSoal]
    // maka return List dari [listSoal].
    if (!isRefresh && (listSoal[kodePaket]?.isNotEmpty ?? false)) {
      if (isKedaluwarsa) {
        for (var soal in listSoal[kodePaket]!) {
          soal.sudahDikumpulkan = true;
        }
      }

      // Jika semua soal sudah di jawab, maka _isSudahDikumpulkanSemua = true
      _isSudahDikumpulkanSemua = isKedaluwarsa ||
          (listSoal[kodePaket]?.every((soal) => soal.sudahDikumpulkan) ??
              false);

      if (kDebugMode) {
        logger.log('SUDAH DIKUMPULKAN SEMUA: $_isSudahDikumpulkanSemua');
      }

      // Mengambil seluruh data bookmark dari hive
      List<BookmarkMapel> daftarBookmarkMapel =
          await HiveHelper.getDaftarBookmarkMapel();

      for (var soal in listSoal[kodePaket]!) {
        soal.isBookmarked = daftarBookmarkMapel.any(
          (bookmarkMapel) => bookmarkMapel.listBookmark.any((bookmarkSoal) =>
              bookmarkSoal.kodePaket == kodePaket &&
              bookmarkSoal.idSoal == soal.idSoal),
        );
      }

      _isLoadingSoal = false;
      notifyListeners();
      return;
    }
    if (isRefresh) {
      listSoal[kodePaket]?.clear();
    } else {
      notifyListeners();
    }
    try {
      final responseData = await _apiService.fetchDaftarSoal(
          isJWT: _isJWT, kodePaket: kodePaket);

      // Mengambil jawaban siswa yang ada di firebase.
      // Jika belum login atau Akun Ortu maka akan mengambil jawaban dari Hive.
      final List<DetailJawaban> jawabanFirebase = await _getDetailJawabanSiswa(
        kodePaket: kodePaket,
        tahunAjaran: tahunAjaran,
        idSekolahKelas: idSekolahKelas,
        noRegistrasi: noRegistrasi,
        tipeUser: tipeUser,
        kumpulkanSemua: true,
      );

      if (kDebugMode) {
        logger.log(
            'PAKET_SOAL_PROVIDER-GetDaftarSoal: responseData >> $responseData');
        logger.log(
            'PAKET_SOAL_PROVIDER-GetDaftarSoal: jawabanFirebase >> $jawabanFirebase');
      }
      // Jika [listSoal] tidak memiliki key idBundel tertentu maka buat key valuenya dulu.
      if (!listSoal.containsKey(kodePaket)) {
        listSoal[kodePaket] = [];
      }
      // Cek apakah response data memiliki data atau tidak
      if (responseData.isNotEmpty) {
        int nomorSoalSiswa = 1;

        // Jika box bookmark belum terbuka, maka open the box.
        if (!HiveHelper.isBoxOpen<BookmarkMapel>(
            boxName: HiveHelper.kBookmarkMapelBox)) {
          await HiveHelper.openBox<BookmarkMapel>(
              boxName: HiveHelper.kBookmarkMapelBox);
        }
        // Mengambil seluruh data bookmark dari hive
        List<BookmarkMapel> daftarBookmarkMapel =
            await HiveHelper.getDaftarBookmarkMapel();

        for (Map<String, dynamic> dataSoal in responseData) {
          // Mengambil jawaban firebase berdasarkan id soal.
          // FirstWhere dan SingleWhere throw error jika tidak ada yang cocok, sehingga merusak UI.
          final List<DetailJawaban> detailJawabanSiswa = jawabanFirebase
              .where((jawaban) => jawaban.idSoal == dataSoal['c_IdSoal'])
              .toList();

          // if (kDebugMode) {
          //   logger.log(
          //       'PAKET_SOAL_PROVIDER-GetDaftarSoalTO: Detail Jawaban >> ${detailJawabanSiswa.first}');
          //   logger.log(
          //       'PAKET_SOAL_PROVIDER-GetDaftarSoalTO: Additional json >> ${detailJawabanSiswa.first.additionalJsonSoal()}');
          // }
          // Menambahkan informasi json SoalModel
          if (detailJawabanSiswa.isNotEmpty) {
            dataSoal.addAll(detailJawabanSiswa.first.additionalJsonSoal());
          }
          // Jika paket kedaluwarsa, maka akan dianggap sudah mengumpulkan.
          if (isKedaluwarsa) {
            dataSoal['sudahDikumpulkan'] = true;
          }
          // Menambahkan nomor soal jika data nomor soal tidak ada dari firebase.
          if (!dataSoal.containsKey('nomorSoalSiswa') ||
              dataSoal['nomorSoalSiswa'] == null) {
            dataSoal['nomorSoalSiswa'] = nomorSoalSiswa;
          }
          // Menambahkan kunci jawaban jika data kunci tidak ada dari firebase.
          if (!dataSoal.containsKey('kunciJawaban') ||
              dataSoal['kunciJawaban'] == null) {
            dataSoal['kunciJawaban'] = setKunciJawabanSoal(
                dataSoal['c_TipeSoal'], jsonDecode(dataSoal['c_Opsi']));
          }
          // Menambahkan Translator EPB untuk menjadi translator format jawaban Siswa pada EPB.
          if (!dataSoal.containsKey('translatorEPB') ||
              dataSoal['translatorEPB'] == null) {
            dataSoal['translatorEPB'] = setTranslatorEPB(
                dataSoal['c_TipeSoal'], jsonDecode(dataSoal['c_Opsi']));
          }
          // Menambahkan Kunci Jawaban EPB untuk menjadi display jawaban Siswa pada EPB.
          if (!dataSoal.containsKey('kunciJawabanEPB') ||
              dataSoal['kunciJawabanEPB'] == null) {
            dataSoal['kunciJawabanEPB'] = setJawabanEPB(
              dataSoal['c_TipeSoal'],
              dataSoal['kunciJawaban'],
              dataSoal['translatorEPB'],
            );
          }

          // Mencari data bookmark dataSoal pada Hive.
          // Jika ada, maka bookmark = true
          dataSoal['isBookmarked'] = daftarBookmarkMapel.any(
            (bookmarkMapel) => bookmarkMapel.listBookmark.any((bookmarkSoal) =>
                bookmarkSoal.kodePaket == kodePaket &&
                bookmarkSoal.idSoal == dataSoal['c_IdSoal']),
          );

          if (kDebugMode) {
            logger.log(
                'PAKET_SOAL_PROVIDER-GetDaftarSoal: bookmark hive >> ${daftarBookmarkMapel.toString()}');
            logger.log(
                'PAKET_SOAL_PROVIDER-GetDaftarSoal: soal bookmark >> ${dataSoal['c_IdSoal']} | ${dataSoal['isBookmarked']}');
          }

          // Konversi dataSoal menjadi SoalModel dan store ke cache [listSoal]
          listSoal[kodePaket]!.add(SoalModel.fromJson(dataSoal));
          nomorSoalSiswa++;
        }

        // Jika semua soal sudah di jawab, maka _isSudahDikumpulkanSemua = true
        if (listSoal[kodePaket]!.every((soal) => soal.sudahDikumpulkan)) {
          _isSudahDikumpulkanSemua = true;
        }

        if (kDebugMode) {
          logger.log('SUDAH DIKUMPULKAN SEMUA: $_isSudahDikumpulkanSemua');
        }
      }

      // Jika Paket merupakan jenis yang harus dikumpulkan keseluruhan,
      // maka set temp jawaban siswa di seluruh soal.
      if (isKumpulkan && jawabanFirebase.isEmpty) {
        // ignore: unused_local_variable
        for (var soal in listSoal[kodePaket]!) {
          await setTempJawaban(
              idSekolahKelas: idSekolahKelas,
              tahunAjaran: tahunAjaran,
              jenisProduk: jenisProduk,
              tipeUser: tipeUser,
              kodePaket: kodePaket,
              jawabanSiswa: null,
              noRegistrasi: noRegistrasi);
        }
      }

      if (kDebugMode) {
        logger.log(
            'PAKET_SOAL_PROVIDER-GetDaftarSoal: list soal >> ${listSoal[kodePaket]}');
      }

      _isLoadingSoal = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDaftarSoal: $e');
      }
      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);
      _isLoadingSoal = false;
      notifyListeners();
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDaftarSoal: $e');
      }
      await gShowTopFlash(
          gNavigatorKey.currentState!.context,
          ('$e'.contains('tidak ditemukan'))
              ? 'Yaah, soal paket $kodePaket belum disiapkan Sobat. '
                  'Coba hubungi cabang GO terdekat untuk info lebih lanjut yaa!'
              : '$e',
          dialogType: DialogType.error,
          duration: const Duration(seconds: 2));
      _isLoadingSoal = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDaftarSoal: ${e.toString()}');
      }
      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyiapkanSoal,
          dialogType: DialogType.error, duration: const Duration(seconds: 2));
      _isLoadingSoal = false;
      notifyListeners();
    }
  }

  Future<bool> kumpulkanJawabanSiswa({
    required bool isKumpulkan,
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    String? idKota,
    String? idGedung,
    required int idJenisProduk,
    required String namaJenisProduk,
    required String kodeTOB,
    required String kodePaket,
  }) async {
    if (kDebugMode) {
      logger.log('PAKET_SOAL_PROVIDER-KumpulkanJawabanSiswa: START');
    }
    List<String> soalYangDiSimpan = [];
    listSoal[cacheKey]?.forEach((soal) {
      if (!soal.sudahDikumpulkan) {
        soalYangDiSimpan.add(soal.idSoal);
      }
      if (soal.jawabanSiswa != null) {
        soal.sudahDikumpulkan = true;
      } else {
        if (isKumpulkan) {
          setTempJawaban(
            soalTemp: soal,
            tahunAjaran: tahunAjaran,
            noRegistrasi: noRegistrasi,
            tipeUser: tipeUser,
            idSekolahKelas: idSekolahKelas,
            kodePaket: kodePaket,
            jenisProduk: namaJenisProduk,
            jawabanSiswa: null,
          );
        }
      }
    });

    try {
      if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
        final List<DetailJawaban> daftarDetailJawaban =
            await _getDetailJawabanSiswa(
          kodePaket: kodePaket,
          tahunAjaran: tahunAjaran,
          idSekolahKelas: idSekolahKelas,
          noRegistrasi: noRegistrasi,
          tipeUser: tipeUser,
          kumpulkanSemua: isKumpulkan,
        );

        if (kDebugMode) {
          logger.log(
              'PAKET_SOAL_PROVIDER-SimpanJawaban: Jawaban Firebase >> $daftarDetailJawaban');
        }

        // Kumpulkan / Simpan jawaban di server,
        // jika berhasil save ke server, baru save ke firebase.
        final bool isBerhasilSimpan = await _soalApiService.simpanJawaban(
          tahunAjaran: tahunAjaran,
          noRegistrasi: noRegistrasi,
          idSekolahKelas: idSekolahKelas,
          tipeUser: tipeUser,
          idKota: idKota!,
          idGedung: idGedung!,
          kodeTOB: kodeTOB,
          kodePaket: kodePaket,
          idJenisProduk: idJenisProduk,
          jumlahSoal: jumlahSoal,
          detailJawaban: daftarDetailJawaban
              .map<Map<String, dynamic>>(
                  (detailJawaban) => detailJawaban.toJson())
              .toList(),
        );

        // Jika berhasil simpan ke server, maka update status sudah di kumpulkan yang jawabannya null
        if (isBerhasilSimpan) {
          if (isKumpulkan) {
            listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);

            await _firebaseHelper.updateKumpulkanJawabanSiswa(
              tahunAjaran: tahunAjaran,
              noRegistrasi: noRegistrasi,
              idSekolahKelas: idSekolahKelas,
              tipeUser: tipeUser,
              isKumpulkan: true,
              onlyUpdateNull: false,
              kodePaket: kodePaket,
            );
          } else {
            // Update firebase dulu jika jawaban siswa not null, baru ke server
            await _firebaseHelper.updateKumpulkanJawabanSiswa(
                tahunAjaran: tahunAjaran,
                noRegistrasi: noRegistrasi,
                idSekolahKelas: idSekolahKelas,
                tipeUser: tipeUser,
                isKumpulkan: false,
                kodePaket: kodePaket,
                onlyUpdateNull: false);
          }

          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil disimpan Sobat',
              dialogType: DialogType.success);
          notifyListeners();
        } else {
          listSoal[cacheKey]?.forEach((soal) {
            if (soalYangDiSimpan.contains(soal.idSoal)) {
              soal.sudahDikumpulkan = false;
            }
          });

          await gShowTopFlash(
              gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
              dialogType: DialogType.error,
              duration: const Duration(seconds: 2));
        }
        return isBerhasilSimpan;
      } else {
        bool isBerhasilSimpan = false;

        if (isKumpulkan) {
          listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);

          isBerhasilSimpan =
              await _soalServideLocal.updateKumpulkanJawabanSiswa(
            kodePaket: kodePaket,
            isKumpulkan: true,
            onlyUpdateNull: false,
          );
        } else {
          // Update firebase dulu jika jawaban siswa not null, baru ke server
          isBerhasilSimpan =
              await _soalServideLocal.updateKumpulkanJawabanSiswa(
            kodePaket: kodePaket,
            isKumpulkan: false,
            onlyUpdateNull: false,
          );
        }

        // Jika berhasil simpan ke server, maka update status sudah di kumpulkan yang jawabannya null
        if (isBerhasilSimpan) {
          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil disimpan Sobat',
              dialogType: DialogType.success);
        } else {
          listSoal[cacheKey]?.forEach((soal) {
            if (soalYangDiSimpan.contains(soal.idSoal)) {
              soal.sudahDikumpulkan = false;
            }
          });

          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Gagal menyimpan jawaban Sobat, coba lagi!',
              dialogType: DialogType.error);
        }
        return isBerhasilSimpan;
      }
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-KumpulkanJawabanSiswa: $e');
      }
      listSoal[cacheKey]?.forEach((soal) {
        if (soalYangDiSimpan.contains(soal.idSoal)) {
          soal.sudahDikumpulkan = false;
        }
      });

      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);
      return false;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-KumpulkanJawabanSiswa: $e');
      }
      listSoal[cacheKey]?.forEach((soal) {
        if (soalYangDiSimpan.contains(soal.idSoal)) {
          soal.sudahDikumpulkan = false;
        }
      });

      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
          dialogType: DialogType.error, duration: const Duration(seconds: 2));
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-KumpulkanJawabanSiswa: ${e.toString()}');
      }
      listSoal[cacheKey]?.forEach((soal) {
        if (soalYangDiSimpan.contains(soal.idSoal)) {
          soal.sudahDikumpulkan = false;
        }
      });

      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
          dialogType: DialogType.error, duration: const Duration(seconds: 2));
      return false;
    }
  }
}
