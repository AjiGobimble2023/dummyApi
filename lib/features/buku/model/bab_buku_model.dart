import '../entity/bab_buku.dart';

class BabUtamaBukuModel extends BabUtamaBuku {
  const BabUtamaBukuModel({
    required super.namaBabUtama,
    required super.daftarBab,
  });

  factory BabUtamaBukuModel.fromJson(Map<String, dynamic> json) {
    List<BabBuku> daftarBab = [];

    if (json['info'] != null) {
      for (var dataBab in json['info']) {
        daftarBab.add(BabBukuModel.fromJson(dataBab));
      }
      daftarBab.sort((a, b) => a.kodeBab.compareTo(b.kodeBab));
    }

    return BabUtamaBukuModel(
      namaBabUtama: json['babUtama'] ?? 'Undefined',
      daftarBab: daftarBab,
    );
  }

  // toJson
  Map<String, dynamic> toJson() => {
        'babUtama': namaBabUtama,
        'info':
            daftarBab.map<Map<String, dynamic>>((bab) => bab.toJson()).toList(),
      };
}

class BabBukuModel extends BabBuku {
  const BabBukuModel({
    required super.namaBab,
    required super.kodeBab,
    required super.idTeoriBab,
  });

  factory BabBukuModel.fromJson(Map<String, dynamic> json) => BabBukuModel(
        namaBab: json['c_NamaBab'] ?? 'Undefined',
        kodeBab: json['c_KodeBab'] ?? '00.00',
        idTeoriBab: json['c_IdTeoriBab'] ?? '',
      );
}
