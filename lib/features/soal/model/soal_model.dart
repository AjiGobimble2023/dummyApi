import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import 'wacana_model.dart';
import '../entity/soal.dart';

// ignore: must_be_immutable
class SoalModel extends Soal {
  SoalModel({
    required super.idSoal,
    required super.nomorSoal,
    required super.nomorSoalSiswa,
    required super.textSoal,
    required super.tingkatKesulitan,
    required super.tipeSoal,
    required super.opsi,
    required super.kunciJawaban,
    required super.translatorEPB,
    required super.kunciJawabanEPB,
    super.idVideo,
    super.idWacana,
    super.wacana,
    required super.idKelompokUjian,
    required super.namaKelompokUjian,
    super.kodePaket,
    super.idBundle,
    super.kodeBab,
    super.nilai = 0,
    super.kesempatanMenjawab,
    required super.isBookmarked,
    super.isRagu = false,
    required super.sudahDikumpulkan,
    super.jawabanSiswa,
    super.jawabanSiswaEPB,
    super.lastUpdate,
  });

  factory SoalModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('FROM JSON >> SoalModel: $json');
    }
    String? idVideo = json['c_IdVideo'] ?? json['c_idvideo'];
    String? idWacana = json['c_IdWacana'] ?? json['c_idwacana'];
    return SoalModel(
      idSoal: json['c_IdSoal'] ?? json['c_idsoal'],
      nomorSoal: (json['c_NomorSoal'] != null && json['c_NomorSoal'] != '')
          ? int.parse(json['c_NomorSoal'])
          : (json['c_nomorsoal'] != null && json['c_nomorsoal'] != '')
              ? int.parse(json['c_nomorsoal'])
              : 0,
      textSoal: json['c_Soal'] ?? json['c_soal'],
      tingkatKesulitan: (json['c_TingkatKesulitan'] != null)
          ? int.parse(json['c_TingkatKesulitan'])
          : (json['c_tingkatkesulitan'] != null)
              ? int.parse(json['c_tingkatkesulitan'])
              : 0,
      tipeSoal: json['c_TipeSoal'] ?? json['c_tipesoal'],
      opsi: json['c_Opsi'] ?? json['c_opsi'],
      idVideo: ((idVideo?.isEmpty ?? true) || idVideo == '0') ? null : idVideo,
      idWacana:
          ((idWacana?.isEmpty ?? true) || idWacana == '0') ? null : idWacana,
      wacana: (json['wacana']?.isEmpty ?? true)
          ? null
          : WacanaModel.fromJson(jsonDecode(json['wacana'])),
      idKelompokUjian: json['c_IdKelompokUjian'] ?? json['c_idkelompokujian'],
      namaKelompokUjian: json['c_NamaKelompokUjian'] ?? json['c_namakelompokujian'],
      kodePaket: json['c_KodePaket'] ?? json['c_kodepaket'],
      idBundle: json['c_IdBundel'] ?? json['c_idbundel'],
      kodeBab: json['c_KodeBab'],
      nomorSoalSiswa: json['nomorSoalSiswa'],
      nilai: json['nilai'] ?? 0.0,
      jawabanSiswa: json['jawabanSiswa'],
      kunciJawaban: json['kunciJawaban'],
      translatorEPB: json['translatorEPB'],
      jawabanSiswaEPB: json['jawabanSiswaEPB'],
      kunciJawabanEPB: json['kunciJawabanEPB'],
      kesempatanMenjawab: json['kesempatanMenjawab'],
      isBookmarked: json['isBookmarked'] ?? false,
      isRagu: json['isRagu'] ?? false,
      sudahDikumpulkan: json['sudahDikumpulkan'] ?? false,
      lastUpdate: json['lastUpdate'],
    );
  }
}
