import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/tob.dart';

class TobModel extends Tob {
  const TobModel({
    required super.kodeTOB,
    required super.namaTOB,
    required super.jenisTOB,
    required super.tanggalMulai,
    required super.tanggalBerakhir,
    required super.jarakAntarPaket,
    super.isFormatTOMerdeka = false,
    super.isBersyarat = false,
    super.isTeaser = false,
  });

  factory TobModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('TOB_MODEL-FromJson: json >> $json');
    }
    return TobModel(
      kodeTOB: json['c_KodeTOB'],
      namaTOB: json['c_NamaTOB'],
      jenisTOB: json['jenisTOB'] ?? 'TryOut',
      tanggalMulai: json['tanggalMulai'],
      tanggalBerakhir: json['tanggalBerakhir'],
      jarakAntarPaket: int.tryParse('${json['jarakAntarPaket']}') ?? 0,
      isFormatTOMerdeka: (json['isTOMerdeka'] == '1') ? true : false,
      isBersyarat: (json['isBersyarat'] == '1') ? true : false,
      isTeaser: json['jenis'] == 'teaser',
    );
  }
}
