import 'package:equatable/equatable.dart';

import '../../../core/config/constant.dart';

class Buku extends Equatable {
  final String idKelompokUjian;
  final String namaKelompokUjian;
  final String singkatan;
  final String kodeBuku;
  final String namaBuku;
  final String semester;
  final String kelengkapan;
  final String idSekolahKelas;
  final String levelTeori;
  final bool isTeaser;

  /// [imageUrl] merupakan url icon Mapel.
  /// Value di set saat pembentukan Object, bukan dari response API.
  final String? imageUrl;

  const Buku({
    this.imageUrl,
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
    required this.singkatan,
    required this.kodeBuku,
    required this.namaBuku,
    required this.semester,
    required this.kelengkapan,
    required this.idSekolahKelas,
    required this.levelTeori,
    required this.isTeaser,
  });

  String get sekolahKelas {
    String value = Constant.kDataSekolahKelas.singleWhere(
          (sekolah) => sekolah['id'] == idSekolahKelas,
          orElse: () => {
            'id': '0',
            'kelas': 'Undefined',
            'tingkat': 'Other',
            'tingkatKelas': '0'
          },
        )['kelas'] ??
        'Undefined';
    return value;
  }

  int get tingkatKelas {
    String tingkatKelas = Constant.kDataSekolahKelas.singleWhere(
          (sekolah) => sekolah['id'] == idSekolahKelas,
      orElse: () => {
        'id': '0',
        'kelas': 'Undefined',
        'tingkat': 'Other',
        'tingkatKelas': '0'
      },
    )['tingkatKelas'] ??
        '0';

    return int.tryParse(tingkatKelas) ?? 0;
  }

  @override
  List<Object> get props => [
        idKelompokUjian,
        namaKelompokUjian,
        singkatan,
        kodeBuku,
        namaBuku,
        semester,
        kelengkapan,
        levelTeori,
        idSekolahKelas,
        isTeaser
      ];
}
