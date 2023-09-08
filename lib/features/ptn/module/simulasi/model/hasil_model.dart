import 'universitas_model.dart';

class HasilModel {
  final String prioritas;
  final String total;
  final String saran;
  final UniversitasModel universitasModel;

  HasilModel({
    required this.prioritas,
    required this.total,
    required this.saran,
    required this.universitasModel,
  });

  factory HasilModel.fromJson(Map<String, dynamic> json) => HasilModel(
        prioritas: json['prioritas'] ?? "",
        total: json['total'] ?? "",
        saran: json['saran'] ?? "",
        universitasModel: UniversitasModel.fromJson({
          'ptn': json['ptn'] ?? "",
          'jurusanId': json['jurusanId'] ?? "",
          'jurusan': json['jurusan'] ?? "",
          'rumpun': json['rumpun'] ?? "",
          'pg': json['pg'] ?? "",
          'peminat': json['peminat'] ?? "",
          'tampung': json['tampung'] ?? "",
        }),
      );
}
