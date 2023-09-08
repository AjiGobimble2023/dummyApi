import '../entity/laporan_vak.dart';

class LaporanVAKModel extends LaporanVAK {
  const LaporanVAKModel({
    required super.noRegistrasi,
    required super.scoreVisual,
    required super.scoreAuditory,
    required super.scoreKinesthetic,
    required super.kecenderungan,
    required super.initialKecenderungan,
    required super.judul1,
    required super.isi1,
    super.judul2,
    super.isi2,
    super.judul3,
    super.isi3,
  });

  factory LaporanVAKModel.fromJson(Map<String, dynamic> json) =>
      LaporanVAKModel(
        noRegistrasi: json['nis'],
        scoreVisual: json['visual'] ?? '0',
        scoreAuditory: json['auditory'] ?? '0',
        scoreKinesthetic: json['kinestetis'] ?? '0',
        kecenderungan: json['dominan'],
        initialKecenderungan: json['kecenderungan'],
        judul1: json['judul1'],
        isi1: json['isi1'],
        judul2: json['judul2'],
        isi2: json['isi2'],
        judul3: json['judul3'],
        isi3: json['isi3'],
      );
}
