import 'package:equatable/equatable.dart';

class LaporanTryoutNilai extends Equatable {
  /// [mapel] Variabel ini digunakan untuk menyimpan nama mata pelajaran.
  final String mapel;

  /// [benar] Variabel yang digunakan untuk menyimpan jumlah pertanyaan yang dijawab dengan benar.
  final int benar;

  /// [salah] Variabel ini digunakan untuk menyimpan jumlah pertanyaan yang salah dijawab.
  final int salah;

  /// [kosong] Variabel ini digunakan untuk menyimpan jumlah pertanyaan yang tidak dijawab.
  final int kosong;

  /// [jumlahSoal] Variabel ini digunakan untuk menyimpan jumlah pertanyaan.
  final int jumlahSoal;

  /// [nilai] Variabel ini digunakan untuk menyimpan nilai skor.
  final String nilai;

  /// [nilaiMax] Variabel ini digunakan untuk menyimpan nilai maksimum skor.
  final String nilaiMax;

  /// [fullCredit] Variabel ini digunakan untuk menyimpan jumlah pertanyaan yang dijawab dengan benar.
  final int fullCredit;

  /// [halfCredit] Digunakan untuk menyimpan jumlah pertanyaan yang bernilai setengah.
  final int halfCredit;

  /// [zeroCredit] Variabel ini digunakan untuk menyimpan jumlah pertanyaan yang tidak dijawab.
  final int zeroCredit;

  /// [kodeSoal] Variabel yang digunakan untuk menyimpan kode pertanyaan.
  final String kodeSoal;

  const LaporanTryoutNilai({
    required this.mapel,
    required this.benar,
    required this.salah,
    required this.kosong,
    required this.jumlahSoal,
    required this.nilai,
    required this.nilaiMax,
    required this.fullCredit,
    required this.halfCredit,
    required this.zeroCredit,
    required this.kodeSoal,
  });

  @override
  List<Object> get props => [
        mapel,
        benar,
        salah,
        kosong,
        jumlahSoal,
        nilai,
        fullCredit,
        halfCredit,
        zeroCredit,
        kodeSoal,
      ];
}
