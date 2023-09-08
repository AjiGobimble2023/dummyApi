import 'package:hive/hive.dart';

part 'detail_jawaban.g.dart';

@HiveType(typeId: 5)
class DetailJawaban extends HiveObject {
  @HiveField(0)
  final String jenisProduk;
  @HiveField(1)
  final String kodePaket;
  @HiveField(2)
  final String idBundel;
  @HiveField(3)
  final String? kodeBab;
  @HiveField(4)
  final String idSoal;
  @HiveField(5)
  final int nomorSoalDatabase;
  @HiveField(6)
  final int nomorSoalSiswa;
  @HiveField(7)
  final String idKelompokUjian;
  @HiveField(8)
  final String namaKelompokUjian;
  @HiveField(9)
  final String tipeSoal;
  @HiveField(10)
  final int tingkatKesulitan;
  @HiveField(11)
  final int? kesempatanMenjawab;
  @HiveField(12)
  final dynamic jawabanSiswa;
  @HiveField(13)
  final dynamic kunciJawaban;
  @HiveField(14)
  final dynamic translatorEPB;
  @HiveField(15)
  final dynamic jawabanSiswaEPB;
  @HiveField(16)
  final dynamic kunciJawabanEPB;
  @HiveField(17)
  final Map<String, dynamic>? infoNilai;
  @HiveField(18)
  final double nilai;
  @HiveField(19)
  final bool isRagu;
  @HiveField(20)
  final bool sudahDikumpulkan;
  @HiveField(21)
  final String? lastUpdate;

  DetailJawaban(
      {required this.jenisProduk,
      required this.kodePaket,
      required this.idBundel,
      this.kodeBab,
      required this.idSoal,
      required this.nomorSoalDatabase,
      required this.nomorSoalSiswa,
      required this.idKelompokUjian,
      required this.namaKelompokUjian,
      required this.tipeSoal,
      required this.tingkatKesulitan,
      this.kesempatanMenjawab,
      required this.jawabanSiswa,
      required this.kunciJawaban,
      required this.translatorEPB,
      required this.jawabanSiswaEPB,
      required this.kunciJawabanEPB,
      required this.infoNilai,
      required this.nilai,
      required this.isRagu,
      required this.sudahDikumpulkan,
      this.lastUpdate});

  factory DetailJawaban.fromJson(Map<String, dynamic> json) => DetailJawaban(
      jenisProduk: json['jenisProduk'],
      kodePaket: json['kodePaket'],
      idBundel: json['idBundel'],
      kodeBab: json['kodeBab'],
      idSoal: json['idSoal'],
      nomorSoalDatabase: json['nomorSoalDatabase'],
      nomorSoalSiswa: json['nomorSoalSiswa'],
      idKelompokUjian: json['idKelompokUjian'],
      namaKelompokUjian: json['namaKelompokUjian'],
      tipeSoal: json['tipeSoal'],
      tingkatKesulitan: json['tingkatKesulitan'],
      kesempatanMenjawab: json['kesempatanMenjawab'],
      jawabanSiswa: json['jawabanSiswa'],
      kunciJawaban: json['kunciJawaban'],
      translatorEPB: json['translatorEPB'],
      jawabanSiswaEPB: json['jawabanSiswaEPB'],
      kunciJawabanEPB: json['kunciJawabanEPB'],
      infoNilai: json['infoNilai'],
      nilai: json['nilai'] ?? 0.0,
      isRagu: json['isRagu'],
      sudahDikumpulkan: json['sudahDikumpulkan'],
      lastUpdate: json['lastUpdate']);

  Map<String, dynamic> additionalJsonSoal() => {
        'nomorSoalSiswa': nomorSoalSiswa,
        'nilai': nilai,
        'jawabanSiswa': jawabanSiswa,
        'kunciJawaban': kunciJawaban,
        'translatorEPB': translatorEPB,
        'jawabanSiswaEPB': jawabanSiswaEPB,
        'kunciJawabanEPB': kunciJawabanEPB,
        'isRagu': isRagu,
        'sudahDikumpulkan': sudahDikumpulkan,
        'kesempatanMenjawab': kesempatanMenjawab,
        'lastUpdate': lastUpdate
      };

  Map<String, dynamic> toJson() => {
        'jenisProduk': jenisProduk,
        'kodePaket': kodePaket,
        'idBundel': idBundel,
        'kodeBab': kodeBab,
        'idSoal': idSoal,
        'nomorSoalDatabase': nomorSoalDatabase,
        'nomorSoalSiswa': nomorSoalSiswa,
        'idKelompokUjian': idKelompokUjian,
        'namaKelompokUjian': namaKelompokUjian,
        'tipeSoal': tipeSoal,
        'tingkatKesulitan': tingkatKesulitan,
        'kesempatanMenjawab': kesempatanMenjawab,
        'jawabanSiswa': jawabanSiswa,
        'kunciJawaban': kunciJawaban,
        'translatorEPB': translatorEPB,
        'jawabanSiswaEPB': jawabanSiswaEPB,
        'kunciJawabanEPB': kunciJawabanEPB,
        'infoNilai': infoNilai,
        'nilai': nilai,
        'isRagu': isRagu,
        'sudahDikumpulkan': sudahDikumpulkan,
        'lastUpdate': lastUpdate
      };

  @override
  String toString() => 'DetailJawaban(\n'
      '    jenisProduk: $jenisProduk,\n'
      '    kodePaket: $kodePaket,\n'
      '    idBundel: $idBundel,\n'
      '    kodeBab: $kodeBab,\n'
      '    idSoal: $idSoal,\n'
      '    nomorSoalDatabase: $nomorSoalDatabase,\n'
      '    nomorSoalSiswa: $nomorSoalSiswa,\n'
      '    idKelompokUjian: $idKelompokUjian,\n'
      '    namaKelompokUjian: $namaKelompokUjian,\n'
      '    tipeSoal: $tipeSoal,\n'
      '    tingkatKesulitan: $tingkatKesulitan,\n'
      '    kesempatanMenjawab: $kesempatanMenjawab,\n'
      '    jawabanSiswa: $jawabanSiswa,\n'
      '    kunciJawaban: $kunciJawaban,\n'
      '    translatorEPB: $translatorEPB,\n'
      '    kunciJawabanEPB: $kunciJawabanEPB,\n'
      '    jawabanSiswaEPB: $jawabanSiswaEPB,\n'
      '    infoNilai: $infoNilai,\n'
      '    nilai: $nilai,\n'
      '    isRagu: $isRagu,\n'
      '    sudahDikumpulkan: $sudahDikumpulkan,\n'
      '    lastUpdate: $lastUpdate\n'
      '),\n';
}
