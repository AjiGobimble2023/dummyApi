import '../entity/detail_bundel.dart';

class DetailBundelModel extends DetailBundel {
  const DetailBundelModel({
    required super.idBundel,
    required super.namaKelompokUjian,
    required super.jumlahSoal,
    required super.indexSoalPertama,
    required super.indexSoalTerakhir,
    required super.waktuPengerjaan,
  });

  factory DetailBundelModel.fromJson({
    required Map<String, dynamic> json,
    required int indexSoalPertama,
    required int indexSoalTerakhir,
  }) =>
      DetailBundelModel(
        idBundel: json['c_idbundel'] ?? '',
        namaKelompokUjian: json['c_namakelompokujian'] ?? '',
        jumlahSoal: (json['c_jumlahsoal'] == null)
            ? 0
            : (json['c_jumlahsoal'] is int)
                ? json['c_jumlahsoal']
                : int.parse(json['c_jumlahsoal'].toString()),
        indexSoalPertama: indexSoalPertama,
        indexSoalTerakhir: indexSoalTerakhir,
        waktuPengerjaan: (json['c_waktupengerjaan'] == null)
            ? 0
            : (json['c_waktupengerjaan'] is int)
                ? json['c_waktupengerjaan']
                : int.parse(json['c_waktupengerjaan'].toString()),
      );
}
