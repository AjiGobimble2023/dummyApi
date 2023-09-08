import '../entity/universitas.dart';
import 'info_model.dart';

class UniversitasModel extends Universitas {
  const UniversitasModel({
    String? ptn,
    String? jurusanId,
    String? jurusan,
    String? kelompok,
    String? rumpun,
    String? pg,
    InfoModel? peminat,
    InfoModel? tampung,
  }) : super(
          ptn: ptn,
          jurusanId: jurusanId,
          jurusan: jurusan,
          kelompok: kelompok,
          rumpun: rumpun,
          pg: pg,
          peminat: peminat,
          tampung: tampung,
        );

  factory UniversitasModel.fromJson(Map<String, dynamic> json) =>
      UniversitasModel(
        ptn: json['ptn'] ?? "",
        jurusanId: json['jurusanId'] ?? "",
        jurusan: json['jurusan'] ?? "",
        kelompok: json['kelompok'] ?? "",
        rumpun: json['rumpun'] ?? "",
        pg: json['pg'] ?? "",
        peminat: InfoModel.fromJson(json['peminat']),
        tampung: InfoModel.fromJson(json['tampung']),
      );
}
