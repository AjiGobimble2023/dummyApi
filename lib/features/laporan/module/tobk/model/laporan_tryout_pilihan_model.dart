import '../entity/laporan_tryout_pilihan.dart';

class LaporanTryoutPilihanModel extends LaporanTryoutPilihan {
  const LaporanTryoutPilihanModel(
      {required String kelompok,
      required String namaKelompok,
      required String ptn,
      required String jurusan,
      required String pg,
      required String nilai})
      : super(
            kelompok: kelompok,
            namakelompok: namaKelompok,
            ptn: ptn,
            jurusan: jurusan,
            pg: pg,
            nilai: nilai);

  factory LaporanTryoutPilihanModel.fromJson(Map<String, dynamic> json) =>
      LaporanTryoutPilihanModel(
          kelompok: json['kelompok'] ?? '-',
          namaKelompok: json['namakelompok'] ?? '-',
          ptn: json['ptn'] ?? '-',
          jurusan: json['jurusan'] ?? '-',
          pg: json['pg'].toString(),
          nilai: json['nilai'].toString());
}
