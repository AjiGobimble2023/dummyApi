import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/paket_to.dart';
import '../../../../../core/util/data_formatter.dart';

// ignore: must_be_immutable
class PaketTOModel extends PaketTO {
  PaketTOModel({
    required super.kodeTOB,
    required super.kodePaket,
    required super.deskripsi,
    super.idKelompokUjian = 0,
    required super.nomorUrut,
    required super.idJenisProduk,
    required super.idSekolahKelas,
    required super.merekHp,
    required super.totalWaktu,
    required super.jumlahSoal,
    super.tanggalBerlaku,
    super.tanggalKedaluwarsa,
    super.kapanMulaiMengerjakan,
    super.deadlinePengerjaan,
    super.tanggalSiswaSubmit,
    required super.isBlockingTime,
    required super.isRandom,
    required super.isSelesai,
    required super.isWaktuHabis,
    required super.isPernahMengerjakan,
    super.isTeaser = false,
    super.isWajib = true,
  });

  factory PaketTOModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('PAKET_TO_MODEL-FromJson: json >> $json');
    }

    return PaketTOModel(
      kodeTOB: json['kodeTOB'],
      kodePaket: json['kodePaket'],
      deskripsi: json['c_Deskripsi'] ?? json['kodePaket'],
      idKelompokUjian: (json['idKelompokUjian'] == null)
          ? 0
          : (json['idKelompokUjian'] is int)
              ? json['idKelompokUjian']
              : int.tryParse(json['idKelompokUjian']) ?? 0,
      merekHp: json['merk'],
      nomorUrut: int.parse(json['nomorUrut']),
      idJenisProduk: json['idJenisProduk'] ?? '25',
      idSekolahKelas: '${json['idSekolahKelas'] ?? '0'}',
      totalWaktu: int.parse(json['totalWaktu']),
      jumlahSoal: int.parse(json['jumlahSoal']),
      tanggalBerlaku: json['tanggalBerlaku'],
      tanggalKedaluwarsa: json['tanggalKedaluwarsa'],
      kapanMulaiMengerjakan:
          (json['tanggalMulai'] == null || json['tanggalMulai'] == '-')
              ? null
              : DataFormatter.stringToDate(json['tanggalMulai']),
      deadlinePengerjaan:
          (json['tanggalDeadline'] == null || json['tanggalDeadline'] == '-')
              ? null
              : DataFormatter.stringToDate(json['tanggalDeadline']),
      tanggalSiswaSubmit: (json['tanggalMengumpulkan'] == null ||
              json['tanggalMengumpulkan'] == '-')
          ? null
          : DataFormatter.stringToDate(json['tanggalMengumpulkan']),
      isBlockingTime: (json['isBlockingTime'] == '1') ? true : false,
      isRandom: (json['isRandom'] == '1') ? true : false,
      isSelesai: (json['isSelesai'] == 'n') ? false : true,
      isWaktuHabis: (json['waktuHabis'] == 'n') ? false : true,
      isPernahMengerjakan: (json['isPernahMengerjakan'] == 'n') ? false : true,
      isWajib: (json['isWajib'] == '0') ? false : true,
      isTeaser: (json['jenis'] == null)
          ? false
          : (json['jenis'] == 'teaser')
              ? true
              : false,
    );
  }
}
