import 'package:equatable/equatable.dart';

import '../model/laporan_tryout_pilihan_model.dart';

class LaporanTryoutTob extends Equatable {
  /// [kode] Variabel untuk menyimpan data kode TO.
  final String kode;

  /// [nama] Variabel untuk menyimpan data nama TO.
  final String nama;

  /// [penilaian] Variabel untuk menyimpan data jenis penilaian.
  final String penilaian;

  /// [link] Variabel untuk menyimpan data link EPB.
  final String link;

  /// [pilihan] Variabel untuk menyimpan data pilihan PTN.
  final List<LaporanTryoutPilihanModel> pilihan;

  /// [isExists] Variabel untuk menyimpan data isExist EPB.
  final bool isExists;

  /// [tanggalAkhir] Variabel untuk menyimpan data tanggal akhir TO.
  final String tanggalAkhir;
  const LaporanTryoutTob(
      {required this.kode,
      required this.nama,
      required this.penilaian,
      required this.link,
      required this.pilihan,
      required this.isExists,
      required this.tanggalAkhir});

  @override
  List<Object> get props =>
      [kode, nama, penilaian, link, pilihan, isExists, tanggalAkhir];
}
