import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/bab_soal.dart';

class BabSoalModel extends BabSoal {
  const BabSoalModel({
    required super.kodeBab,
    required super.namaBab,
    required super.idBundel,
    required super.jumlahSoal,
  });

  factory BabSoalModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('BAB_SOAL_MODEL-FromJson: json >> $json');
    }
    return BabSoalModel(
      kodeBab: json['c_KodeBab'],
      namaBab: json['c_NamaBab'],
      idBundel: json['c_IdBundel'],
      jumlahSoal: json['c_JumlahSoal'],
    );
  }
}

class BabUtamaSoalModel extends BabUtamaSoal {
  const BabUtamaSoalModel(
      {required super.namaBabUtama, required super.daftarBab});

  factory BabUtamaSoalModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('BAB_UTAMA_SOAL_MODEL-FromJson: json >> $json');
    }
    List<BabSoalModel> daftarBabSubBab = [];

    if (json['info'] != null) {
      for (Map<String, dynamic> dataBab in json['info']) {
        daftarBabSubBab.add(BabSoalModel.fromJson(dataBab));
      }
      daftarBabSubBab.sort((a, b) => a.kodeBab.compareTo(b.kodeBab));
    }
    return BabUtamaSoalModel(
      namaBabUtama: json['babUtama'],
      daftarBab: daftarBabSubBab,
    );
  }
}
