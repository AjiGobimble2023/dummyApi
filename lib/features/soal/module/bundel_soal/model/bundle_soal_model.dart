import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/bundel_soal.dart';
import '../../../../../core/config/extensions.dart';

class BundleSoalModel extends BundelSoal {
  const BundleSoalModel({
    required super.idBundel,
    required super.kodeTOB,
    required super.kodePaket,
    required super.idSekolahKelas,
    required super.idKelompokUjian,
    required super.namaKelompokUjian,
    required super.initialKelompokUjian,
    required super.deskripsi,
    super.waktuPengerjaan,
    required super.jumlahSoal,
    super.isTeaser = false,
    required super.opsiUrut,
  });

  factory BundleSoalModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('FROM JSON >> BundleSoalModel: $json');
    }
    return BundleSoalModel(
      idBundel: json['c_IdBundel'],
      kodeTOB: json['c_KodeTOB'],
      kodePaket: json['c_KodePaket'],
      idSekolahKelas: '${json['idSekolahKelas'] ?? '0'}',
      idKelompokUjian: int.tryParse('${json['c_IdKelompokUjian']}') ?? 0,
      namaKelompokUjian: json['c_NamaKelompokUjian'],
      initialKelompokUjian: json['c_Singkatan'],
      deskripsi: json['c_Deskripsi'],
      waktuPengerjaan: (json['c_WaktuPengerjaan'] != null)
          ? int.tryParse('${json['c_WaktuPengerjaan']}')
          : null,
      jumlahSoal: (json['c_JumlahSoal'] != null)
          ? int.tryParse('${json['c_JumlahSoal']}') ?? 0
          : 0,
      isTeaser: json['jenis'] == 'teaser',
      opsiUrut: ('${json['c_OpsiUrut']}'.equalsIgnoreCase('Nomor'))
          ? OpsiUrut.nomor
          : OpsiUrut.bab,
    );
  }
}
