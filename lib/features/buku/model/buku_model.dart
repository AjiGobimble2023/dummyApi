import '../entity/buku.dart';

class BukuModel extends Buku {
  const BukuModel({
    super.imageUrl,
    required super.idKelompokUjian,
    required super.namaKelompokUjian,
    required super.singkatan,
    required super.kodeBuku,
    required super.namaBuku,
    required super.semester,
    required super.kelengkapan,
    required super.idSekolahKelas,
    required super.levelTeori,
    required super.isTeaser,
  });

  factory BukuModel.fromJson({
    String? imageUrl,
    required Map<String, dynamic> json,
  }) =>
      BukuModel(
        imageUrl: imageUrl,
        idKelompokUjian: json['c_IdKelompokUjian'],
        namaKelompokUjian: json['c_NamaKelompokUjian'],
        singkatan: json['c_Singkatan'],
        kodeBuku: json['c_KodeBuku'],
        namaBuku: json['c_NamaBuku'],
        semester: json['c_Semester'],
        kelengkapan: json['kelengkapan'],
        idSekolahKelas: '${json['idSekolahKelas'] ?? '0'}',
        levelTeori: json['levelTeori'],
        isTeaser: (json['jenis'] == null)
            ? false
            : (json['jenis'] == 'reguler')
                ? false
                : true,
      );
}
