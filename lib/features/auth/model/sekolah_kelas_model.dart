import '../entity/sekolah_kelas.dart';

class SekolahKelasModel extends SekolahKelas {
  const SekolahKelasModel({
    required String id,
    required String namaKelas,
  }) : super(id: id, namaKelas: namaKelas);

  factory SekolahKelasModel.fromJson(Map<String, dynamic> json) =>
      SekolahKelasModel(
        id: json['classLevelId'],
        namaKelas: json['classLevelName'],
      );
}
