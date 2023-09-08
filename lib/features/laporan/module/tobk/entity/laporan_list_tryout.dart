import 'package:equatable/equatable.dart';

class LaporanListTryout extends Equatable {
  ///  [kode] Variabel yang digunakan untuk menyimpan kode TO.
  final String kode;

  /// [nama] Variabel yang digunakan untuk menyimpan nama TO.
  final String nama;

  /// [tanggalAkhir] Variabel yang digunakan untuk menyimpan tanggal akhir TO.
  final String tanggalAkhir;

  /// [penilaian] Variabel yang digunakan untuk menyimpan jenis penilaian.
  final String penilaian;

  /// [link] Variabel untuk menyimpan data link EPB.
  final String link;

  /// [isExists] Variabel untuk menyimpan data isExist EPB.
  final bool isExists;

  const LaporanListTryout(
      {required this.kode,
      required this.nama,
      required this.tanggalAkhir,
      required this.penilaian,
      required this.isExists,
      required this.link});

  @override
  List<Object> get props =>
      [kode, nama, tanggalAkhir, penilaian, link, isExists];
}
