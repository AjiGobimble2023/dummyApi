import '../entity/kelas.dart';

class KelasModel extends Kelas {
  const KelasModel({
    required String id,
    required String namaKelas,
    required String tahunAjaran,
    required String type,
  }) : super(
            id: id, namaKelas: namaKelas, tahunAjaran: tahunAjaran, type: type);

  factory KelasModel.fromJson(Map<String, dynamic> json) => KelasModel(
        id: json['classId'],
        namaKelas: json['className'],
        tahunAjaran: json['ta'],
        type: json['classType'],
      );
}
