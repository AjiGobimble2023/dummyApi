import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/jurusan.dart';

class JurusanModel extends Jurusan {
  const JurusanModel({
    required super.idPTN,
    required super.idJurusan,
    required super.namaJurusan,
    required super.kelompok,
    required super.rumpun,
    required super.lintas,
    super.passGrade,
    required super.peminat,
    required super.tampung,
    super.deskripsi,
    super.lapanganPekerjaan,
  });

  factory JurusanModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log(
          'JURUSAN_MODEL-FromJson: ${json['idPTN'] is String} || ${json['idJurusan'] is String}');
    }

    return JurusanModel(
      idPTN: json['idPTN'],
      idJurusan: json['idJurusan'],
      namaJurusan: json['namaJurusan'],
      kelompok: json['kelompok'],
      rumpun: json['rumpun'],
      peminat: json['info']?['peminat'] ?? json['peminat'] ?? [],
      tampung: json['info']?['tampung'] ?? json['tampung'] ?? [],
      passGrade: json['passgrade'],
      lintas: (json['lintas'] == 'Y') ? true : false,
      deskripsi: json['deskripsi'],
      lapanganPekerjaan: json['lapker'],
    );
  }
}

class DetailJurusan extends Jurusan {
  final String namaPTN;
  final String alias;

  const DetailJurusan({
    required super.idPTN,
    required this.namaPTN,
    required this.alias,
    required super.idJurusan,
    required super.namaJurusan,
    required super.kelompok,
    required super.rumpun,
    required super.lintas,
    super.passGrade,
    required super.peminat,
    required super.tampung,
    super.deskripsi,
    super.lapanganPekerjaan,
  });

  factory DetailJurusan.fromJson(Map<String, dynamic> json) {
    return DetailJurusan(
      idPTN: json['idPTN'],
      namaPTN: json['namaPTN'],
      alias: json['aliasPTN'],
      idJurusan: json['idJurusan'],
      namaJurusan: json['nama'],
      kelompok: json['kelompok'],
      rumpun: json['rumpun'],
      peminat: json['info']?['peminat'] ?? [],
      tampung: json['info']?['tampung'] ?? [],
      passGrade: json['passgrade'],
      lintas: (json['lintas'] == 'Y') ? true : false,
      deskripsi: json['deskripsi'],
      lapanganPekerjaan: json['lapker'],
    );
  }
}
