import 'package:equatable/equatable.dart';
import '../../../core/config/global.dart';
import '../../../core/util/data_formatter.dart';

class ProdukDibeli extends Equatable {
  final String idKomponenProduk;
  final String idBundling;
  final String namaBundling;
  final String namaProduk;
  final int idJenisProduk;
  final int idSekolahKelas;
  final String namaJenisProduk;
  final DateTime? tanggalBerlaku;
  final DateTime? tanggalKedaluwarsa;

  const ProdukDibeli(
      {required this.idKomponenProduk,
      required this.idBundling,
      required this.namaBundling,
      required this.namaProduk,
      required this.idJenisProduk,
      required this.idSekolahKelas,
      required this.namaJenisProduk,
      required this.tanggalBerlaku,
      required this.tanggalKedaluwarsa});

  bool get isExpired => (tanggalKedaluwarsa == null)
      ? true
      : DateTime.now()
          .add(Duration(milliseconds: gOffsetServerTime ?? 0))
          .isAfter(tanggalKedaluwarsa!);

  factory ProdukDibeli.fromJson(Map<String, dynamic> json) => ProdukDibeli(
      idKomponenProduk: json['c_IdKomponentProduk'],
      idBundling: json['c_IdBundling'] ?? '0',
      namaBundling: json['c_NamaBundling'] ?? 'Undefined',
      namaProduk: json['c_NamaProduk'],
      idSekolahKelas: (json['c_IdSekolahKelas'] != null &&
              json['c_IdSekolahKelas'] is String)
          ? int.parse(json['c_IdSekolahKelas'])
          : (json['c_IdSekolahKelas'] != null &&
                  json['c_IdSekolahKelas'] is int)
              ? json['c_IdSekolahKelas']
              : 0,
      idJenisProduk: (json['c_IdJenisProduk'] != null &&
              json['c_IdJenisProduk'] is String)
          ? int.parse(json['c_IdJenisProduk'])
          : (json['c_IdJenisProduk'] != null && json['c_IdJenisProduk'] is int)
              ? json['c_IdJenisProduk']
              : 0,
      namaJenisProduk: '${json['c_NamaJenisProduk']}'.replaceAll('- ', '-'),
      tanggalBerlaku: (json['c_TanggalAwal'] != null &&
              json['c_TanggalAwal'] != '' &&
              json['c_TanggalAwal'] != '-')
          ? DataFormatter.stringToDate(json['c_TanggalAwal'], 'yyyy-MM-dd')
          : null,
      tanggalKedaluwarsa: (json['c_TanggalAkhir'] != null &&
              json['c_TanggalAkhir'] != '' &&
              json['c_TanggalAkhir'] != '-')
          ? DataFormatter.stringToDate(json['c_TanggalAkhir'], 'yyyy-MM-dd')
          : null);

  Map<String, dynamic> toJson() => {
        'c_IdKomponentProduk': idKomponenProduk,
        'c_IdBundling': idBundling,
        'c_NamaBundling': namaBundling,
        'c_NamaProduk': namaProduk,
        'c_IdJenisProduk': '$idJenisProduk',
        'c_IdSekolahKelas': '$idSekolahKelas',
        'c_NamaJenisProduk': namaJenisProduk,
        'c_TanggalAwal': (tanggalBerlaku != null)
            ? DataFormatter.dateTimeToString(tanggalBerlaku!, 'yyyy-MM-dd')
            : null,
        'c_TanggalAkhir': (tanggalKedaluwarsa != null)
            ? DataFormatter.dateTimeToString(tanggalKedaluwarsa!, 'yyyy-MM-dd')
            : null,
      };

  @override
  List<Object?> get props => [
        idKomponenProduk,
        idBundling,
        namaProduk,
        idJenisProduk,
        namaJenisProduk,
        tanggalBerlaku,
        tanggalKedaluwarsa
      ];
}
