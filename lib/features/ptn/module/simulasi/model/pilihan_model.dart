import 'universitas_model.dart';

class PilihanModel {
  final String? prioritas;
  final String? status;
  final UniversitasModel? universitasModel;

  PilihanModel({
    this.prioritas,
    this.status,
    this.universitasModel,
  });

  factory PilihanModel.fromJson(Map<String, dynamic> json) => PilihanModel(
        prioritas: json['prioritas'],
        status: json['status'],
        universitasModel: UniversitasModel.fromJson({
          'ptn': json['ptn'],
          'pg': json['pg'],
          'jurusanId': json['jurusanId'],
          'jurusan': json['jurusan'],
          'peminat': json['peminat'],
          'tampung': json['tampung'],
        }),
      );
}
