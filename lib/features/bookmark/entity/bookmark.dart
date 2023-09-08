import 'package:hive/hive.dart';
import '../../../core/config/constant.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 1)
class BookmarkMapel extends HiveObject {
  @HiveField(0)
  final String idKelompokUjian;
  @HiveField(1)
  final String namaKelompokUjian;
  @HiveField(2, defaultValue: null)
  String? iconMapel;
  @HiveField(4, defaultValue: [])
  List<BookmarkSoal> listBookmark;

  BookmarkMapel({
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
    this.iconMapel,
    this.listBookmark = const [],
  });

  String get initial {
    int id = int.parse(idKelompokUjian);

    return Constant.kInitialKelompokUjian.entries
            .singleWhere(
              (kelompokUjian) => kelompokUjian.key == id,
              orElse: () =>
                  const MapEntry(0, {'nama': 'Undefined', 'initial': 'N/a'}),
            )
            .value['initial'] ??
        'N/a';
  }

  factory BookmarkMapel.fromJson(Map<String, dynamic> json) => BookmarkMapel(
        idKelompokUjian: json['idKelompokUjian'],
        namaKelompokUjian: json['namaKelompokUjian'],
        iconMapel: json['iconMapel'],
        listBookmark: List<BookmarkSoal>.generate(
          (json['listBookmark'] as List).length,
          (index) => BookmarkSoal.fromJson(json['listBookmark'][index]),
        ),
      );

  Map<String, dynamic> toJson() => {
        'idKelompokUjian': idKelompokUjian,
        'namaKelompokUjian': namaKelompokUjian,
        'iconMapel': iconMapel,
        'listBookmark':
            listBookmark.map<Map<String, dynamic>>((e) => e.toJson()).toList()
      };

  @override
  String toString() => 'BookmarkMapel('
      '\nidKelompokUjian: $idKelompokUjian, namaKelompokUjian: $namaKelompokUjian, iconMapel: $iconMapel,'
      '\nlistBookmark: $listBookmark\n), ';
}

@HiveType(typeId: 2)
class BookmarkSoal extends HiveObject {
  @HiveField(0)
  final String idSoal;
  @HiveField(1)
  final int nomorSoal;
  @HiveField(2)
  final int nomorSoalSiswa;
  @HiveField(3)
  final String kodeTOB;
  @HiveField(4)
  final String kodePaket;
  @HiveField(5)
  final String idBundel;
  @HiveField(6)
  final String? kodeBab;
  @HiveField(7)
  final String? namaBab;
  @HiveField(8)
  final int idJenisProduk;
  @HiveField(9)
  final String namaJenisProduk;
  @HiveField(10)
  final String? tanggalKedaluwarsa;
  @HiveField(11)
  final bool isPaket;
  @HiveField(12)
  final bool isSimpan;
  @HiveField(13)
  String lastUpdate;

  BookmarkSoal(
      {required this.idSoal,
      required this.nomorSoal,
      required this.nomorSoalSiswa,
      required this.idBundel,
      required this.kodeTOB,
      required this.kodePaket,
      this.kodeBab,
      this.namaBab,
      required this.idJenisProduk,
      required this.namaJenisProduk,
      this.tanggalKedaluwarsa,
      required this.isPaket,
      required this.isSimpan,
      required this.lastUpdate});

  factory BookmarkSoal.fromJson(Map<String, dynamic> json) => BookmarkSoal(
        idSoal: json['idSoal'],
        nomorSoal: (json['nomorSoal'] is int)
            ? json['nomorSoal']
            : int.parse(json['nomorSoal'].toString()),
        nomorSoalSiswa: (json['nomorSoalSiswa'] is int)
            ? json['nomorSoalSiswa']
            : int.parse(json['nomorSoalSiswa'].toString()),
        idBundel: json['idBundel'],
        kodeTOB: json['kodeTOB'],
        kodePaket: json['kodePaket'],
        kodeBab: json['kodeBab'],
        namaBab: json['namaBab'],
        isPaket: json['isPaket'],
        isSimpan: json['isSimpan'],
        idJenisProduk: json['idJenisProduk'],
        namaJenisProduk: json['namaJenisProduk'],
        tanggalKedaluwarsa: json['tanggalKedaluwarsa'],
        lastUpdate: json['lastUpdate'],
      );

  Map<String, dynamic> toJson() => {
        'idSoal': idSoal,
        'nomorSoal': nomorSoal,
        'nomorSoalSiswa': nomorSoalSiswa,
        'idBundel': idBundel,
        'kodeTOB': kodeTOB,
        'kodePaket': kodePaket,
        'kodeBab': kodeBab,
        'namaBab': namaBab,
        'idJenisProduk': idJenisProduk,
        'namaJenisProduk': namaJenisProduk,
        'tanggalKedaluwarsa': tanggalKedaluwarsa,
        'isPaket': isPaket,
        'isSimpan': isSimpan,
        'lastUpdate': lastUpdate,
      };

  int compareTo(BookmarkSoal b) {
    if (kodePaket == b.kodePaket) {
      return nomorSoalSiswa.compareTo(b.nomorSoalSiswa);
    } else {
      return kodePaket.compareTo(b.kodePaket);
    }
  }

  @override
  String toString() => ' BookmarkMapel('
      'idSoal: $idSoal, '
      'nomorSoal: $nomorSoal, '
      'nomorSoalSiswa $nomorSoalSiswa, '
      'idBundel: $idBundel, '
      'kodeTOB: $kodeTOB, '
      'kodePaket: $kodePaket, '
      'kodeBab: $kodeBab, '
      'namaBab: $namaBab, '
      'idJenisProduk: $idJenisProduk, '
      'namaJenisProduk: $namaJenisProduk, '
      'tanggalKedaluwarsa: $tanggalKedaluwarsa, '
      'isPaket: $isPaket, '
      'isSimpan: $isSimpan, '
      'lastUpdate: $lastUpdate), ';
}
