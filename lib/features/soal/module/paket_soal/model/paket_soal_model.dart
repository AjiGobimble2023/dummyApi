import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/paket_soal.dart';

class PaketSoalModel extends PaketSoal {
  const PaketSoalModel({
    required super.kodeTOB,
    required super.kodePaket,
    required super.deskripsi,
    required super.idJenisProduk,
    required super.idSekolahKelas,
    super.tanggalBerlaku,
    super.tanggalKedaluwarsa,
    required super.jumlahSoal,
    required super.totalWaktu,
    required super.isBlockingTime,
    super.isTeaser = false,
  });

  factory PaketSoalModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('PAKET_SOAL_MODEL-FromJson: json >> $json');
    }
    return PaketSoalModel(
      kodeTOB: json['c_KodeTOB'],
      kodePaket: json['c_KodePaket'],
      deskripsi: json['c_Deskripsi'],
      idJenisProduk: json['idJenisProduk'],
      idSekolahKelas: '${json['idSekolahKelas'] ?? '0'}',
      isBlockingTime: (json['c_IsBlockingTime'] == '1') ? true : false,
      tanggalBerlaku: (json['tanggalBerlaku'] != null ||
              json['tanggalBerlaku'] != '-' ||
              json['tanggalBerlaku'] != '')
          ? json['tanggalBerlaku']
          : null,
      tanggalKedaluwarsa: (json['tanggalKedaluwarsa'] != null ||
              json['tanggalKedaluwarsa'] != '-' ||
              json['tanggalKedaluwarsa'] != '')
          ? json['tanggalKedaluwarsa']
          : null,
      totalWaktu: int.tryParse('${json['totalWaktu']}') ?? 0,
      jumlahSoal: int.parse(json['jumlahSoal']),
      isTeaser: json['jenis'] == 'teaser',
    );
  }
}
