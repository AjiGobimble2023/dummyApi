import '../entity/ptn.dart';

class PTNModel extends PTN {
  const PTNModel({
    required super.idPTN,
    required super.namaPTN,
    required super.aliasPTN,
    required super.jenisPTN,
  });

  factory PTNModel.fromJson(Map<String, dynamic> json) => PTNModel(
        idPTN: json['idPTN'],
        namaPTN: json['namaPTN'],
        aliasPTN: json['aliasPTN'],
        jenisPTN: json['jenis'],
      );
}
