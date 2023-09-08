import '../entity/laporan_tryout_nilai.dart';

class LaporanTryoutNilaiModel extends LaporanTryoutNilai {
  const LaporanTryoutNilaiModel({
    required String mapel,
    required int benar,
    required int salah,
    required int kosong,
    required int jumlahSoal,
    required String nilai,
    required String nilaiMax,
    required int fullCredit,
    required int halfCredit,
    required int zeroCredit,
    required String kodeSoal,
  }) : super(
          mapel: mapel,
          benar: benar,
          salah: salah,
          kosong: kosong,
          jumlahSoal: jumlahSoal,
          nilai: nilai,
          nilaiMax: nilaiMax,
          fullCredit: fullCredit,
          halfCredit: halfCredit,
          zeroCredit: zeroCredit,
          kodeSoal: kodeSoal,
        );

  factory LaporanTryoutNilaiModel.fromJson(Map<String, dynamic> json) =>
      LaporanTryoutNilaiModel(
        mapel: json['namaKelompokUjian'] ?? '-',
        benar: json['benar'] ?? 0,
        salah: json['salah'] ?? 0,
        kosong: json['kosong'] ?? 0,
        jumlahSoal: json['jumlahSoal'] ?? 0,
        nilai: json['nilai'].toString(),
        nilaiMax: json['nilaiMax'].toString(),
        fullCredit: json['fullCredit'] ?? 0,
        halfCredit: json['halfCredit'] ?? 0,
        zeroCredit: json['zeroCredit'] ?? 0,
        kodeSoal: json['kodeSoal'] ?? "",
      );
}
