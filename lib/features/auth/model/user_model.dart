import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'produk_dibeli_model.dart';
import '../../../core/config/constant.dart';

class Anak extends Equatable {
  final String noRegistrasi;
  final String namaLengkap;
  final String nomorHandphone;

  const Anak({
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.nomorHandphone,
  });

  factory Anak.fromJson(Map<String, dynamic> json) => Anak(
        noRegistrasi: json['noRegistrasi'] ?? 'Undefined',
        namaLengkap: json['namaLengkap'] ?? 'Sobat GO',
        nomorHandphone: json['nomorHp'] ?? '-',
      );

  Map<String, dynamic> toJson() => {
        'noRegistrasi': noRegistrasi,
        'namaLengkap': namaLengkap,
        'nomorHp': nomorHandphone,
      };

  @override
  List<Object?> get props => [noRegistrasi, namaLengkap, nomorHandphone];
}

// ignore: must_be_immutable
class UserModel extends Equatable {
  final String noRegistrasi;
  final String namaLengkap;
  final String email;
  final String emailOrtu;
  final String nomorHp;
  final String nomorHpOrtu;
  final String idSekolahKelas;
  final String namaSekolahKelas;
  final String siapa;
  final List<String> idKelasGO;
  final List<String> namaKelasGO;
  final String tipeKelasGO;
  final String idGedung;
  final String namaGedung;
  final String idKota;
  final String namaKota;
  final String idSekolah;
  final String namaSekolah;
  final String tahunAjaran;
  final String statusBayar;
  final int? idJurusanPilihan1;
  final int? idJurusanPilihan2;
  final String? pekerjaanOrtu;
  final List<ProdukDibeli> daftarProdukDibeli;
  List<Anak> daftarAnak;

  UserModel(
      {required this.noRegistrasi,
      required this.namaLengkap,
      required this.email,
      required this.emailOrtu,
      required this.nomorHp,
      required this.nomorHpOrtu,
      required this.idSekolahKelas,
      required this.namaSekolahKelas,
      required this.siapa,
      required this.idKelasGO,
      required this.namaKelasGO,
      required this.tipeKelasGO,
      required this.idGedung,
      required this.namaGedung,
      required this.idKota,
      required this.namaKota,
      required this.idSekolah,
      required this.namaSekolah,
      required this.tahunAjaran,
      required this.statusBayar,
      this.idJurusanPilihan1,
      this.idJurusanPilihan2,
      this.pekerjaanOrtu,
      required this.daftarAnak,
      required this.daftarProdukDibeli});

  String get tingkatKelas =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['tingkatKelas'] ??
      '0';

  String get tingkat =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['tingkat'] ??
      '0';

  List<int> get dataKampusImpian {
    List<int> data = [];

    if (idJurusanPilihan1 != null) {
      data.add(idJurusanPilihan1!);
      if (idJurusanPilihan2 != null) {
        data.add(idJurusanPilihan2!);
      }
    }

    return data;
  }

  Map<String, List<ProdukDibeli>> get daftarProdukGroupByJenisProduk {
    List<ProdukDibeli> produkDibeli = [...daftarProdukDibeli];
    produkDibeli.sort(
      (a, b) => a.namaJenisProduk.compareTo(b.namaJenisProduk),
    );

    return produkDibeli.fold<Map<String, List<ProdukDibeli>>>({},
        (prev, produk) {
      prev.putIfAbsent(produk.namaJenisProduk, () => []).add(produk);
      return prev;
    });
  }

  Map<String, Map<String, List<ProdukDibeli>>> get daftarProdukGroupByBundel {
    List<ProdukDibeli> produkDibeli = [...daftarProdukDibeli];
    produkDibeli.sort(
      (a, b) {
        int tingkatKelas = a.idSekolahKelas.compareTo(b.idSekolahKelas);
        if (tingkatKelas == 0) {
          // '-' for descending
          int namaBundling = a.namaBundling.compareTo(b.namaBundling);
          if (namaBundling == 0) {
            int jenisProduk = a.namaJenisProduk.compareTo(b.namaJenisProduk);
            if (jenisProduk == 0) {
              int panjangProduk = a.namaProduk.length.compareTo(b.namaProduk.length);
              if (panjangProduk == 0) {
                return a.namaProduk.compareTo(b.namaProduk);
              }
              return panjangProduk;
            }
            return jenisProduk;
          }
          return namaBundling;
        }
        return tingkatKelas;
      },
    );

    var groupByBundle = produkDibeli
        .fold<Map<String, Map<String, List<ProdukDibeli>>>>({}, (prev, produk) {
      prev
          .putIfAbsent(produk.namaBundling,
              () => SplayTreeMap<String, List<ProdukDibeli>>())
          .putIfAbsent(produk.namaJenisProduk, () => [])
          .add(produk);
      if (kDebugMode) {
        logger.log('PRODUK-FOLD-BUNDLE: $prev');
      }
      return prev;
    });

    var groupByBundle2 = produkDibeli
        .fold<Map<String, Map<String, List<ProdukDibeli>>>>({}, (prev, produk) {
      prev.putIfAbsent(produk.namaBundling, () => {}).update(
            produk.namaJenisProduk,
            (value) => [...value, produk],
            ifAbsent: () => [produk],
          );
      if (kDebugMode) {
        logger.log('PRODUK-FOLD-BUNDLE-Method2: $prev');
      }
      return prev;
    });

    if (kDebugMode) {
      logger.log('PRODUK-FOLD-BUNDLE: Final Result 1 >> $groupByBundle');
      logger.log('PRODUK-FOLD-BUNDLE: Final Result 2 >> $groupByBundle2');
    }

    return groupByBundle;
  }

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    List<ProdukDibeli>? daftarProduk,
    List<Anak>? daftarAnak,
    int? idJurusanPilihan1,
    int? idJurusanPilihan2,
    String? pekerjaanOrtu,
  }) {
    // final List<String> keyNotNullable = [
    //   'jenisKelas',
    //   'idSekolah',
    //   'namaSekolah',
    //   'tahunAjaran',
    //   'c_Statusbayar'
    // ];
    // json.forEach((key, value) {
    //   if (keyNotNullable.contains(key) && value == null) {
    //     throw DataException(message: 'Oops! Data $key kosong');
    //   }
    // });

    return UserModel(
      noRegistrasi: json['noRegistrasi'],
      namaLengkap: json['namaLengkap'],
      email: json['email'] ?? 'Email belum terdata',
      emailOrtu: json['emailOrtu'] ?? 'Email ortu belum terdata',
      nomorHp: json['nomorHp'],
      nomorHpOrtu: json['nomorHpOrtu'] ?? 'Nomor handphone ortu belum terdata',
      idSekolahKelas: json['idSekolahKelas'],
      namaSekolahKelas: json['namaSekolahKelas'],
      siapa: json['siapa'],
      idKelasGO: (json['idKelas'] == null)
          ? const ['0']
          : (json['idKelas'] as String).split(','),
      namaKelasGO: (json['namaKelas'] == null)
          ? const ['Undefined']
          : (json['namaKelas'] as String).split(','),
      tipeKelasGO: json['jenisKelas'] ?? 'Undefined',
      idGedung: (json['idGedung'] == null || json['idGedung'].isEmpty)
          ? '2'
          : json['idGedung'],
      namaGedung: json['namaGedung'] ?? "PW 36-B",
      idKota: (json['idKota'] == null || json['idKota'].isEmpty)
          ? '1'
          : json['idKota'],
      namaKota: (json['namaKota'] == null || json['namaKota'].isEmpty)
          ? 'BANDUNG'
          : json['namaKota'],
      idSekolah: json['idSekolah'] ?? '-',
      namaSekolah: json['namaSekolah'] ?? 'Asal sekolah belum terdata',
      tahunAjaran: json['tahunAjaran'] ?? 'Undefined',
      statusBayar: json['c_Statusbayar'] ?? 'Undefined',
      idJurusanPilihan1: idJurusanPilihan1 ?? json['idJurusanPilihan1'],
      idJurusanPilihan2: idJurusanPilihan2 ?? json['idJurusanPilihan2'],
      pekerjaanOrtu: (pekerjaanOrtu?.isEmpty ?? true)
          ? null
          : pekerjaanOrtu ?? json['pekerjaanOrtu'],
      // json['daftarAnak'] merupakan json dari Kreasi Secure Storage.
      // Jika dari API maka akan menggunakan daftarAnak
      daftarAnak: daftarAnak ??
          json['daftarAnak'].map<Anak>((anak) => Anak.fromJson(anak)).toList(),
      // json['produkDibeli'] merupakan json dari Kreasi Secure Storage.
      // Jika dari API maka akan menggunakan daftarProduk
      daftarProdukDibeli: daftarProduk ??
          json['produkDibeli']
              .map<ProdukDibeli>(
                  (produkJson) => ProdukDibeli.fromJson(produkJson))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'noRegistrasi': noRegistrasi,
        'namaLengkap': namaLengkap,
        'idSekolahKelas': idSekolahKelas,
        'namaSekolahKelas': namaSekolahKelas,
        'siapa': siapa,
        'idKelas': idKelasGO.join(','),
        'namaKelas': namaKelasGO.join(','),
        'jenisKelas': tipeKelasGO,
        'idGedung': idGedung,
        'namaGedung': namaGedung,
        'idKota': idKota,
        'namaKota': namaKota,
        'idSekolah': idSekolah,
        'namaSekolah': namaSekolah,
        'tahunAjaran': tahunAjaran,
        'c_Statusbayar': statusBayar,
        'email': email,
        'nomorHp': nomorHp,
        'nomorHpOrtu': nomorHpOrtu,
        'idJurusanPilihan1': idJurusanPilihan1,
        'idJurusanPilihan2': idJurusanPilihan2,
        'pekerjaanOrtu': pekerjaanOrtu,
        'daftarAnak': daftarAnak.map((anak) => anak.toJson()).toList(),
        'produkDibeli':
            daftarProdukDibeli.map((produk) => produk.toJson()).toList()
      };

  @override
  List<Object?> get props => [
        noRegistrasi,
        namaLengkap,
        idSekolahKelas,
        namaSekolahKelas,
        siapa,
        idKelasGO,
        namaKelasGO,
        tipeKelasGO,
        idGedung,
        namaGedung,
        idKota,
        namaKota,
        idSekolah,
        namaSekolah,
        tahunAjaran,
        statusBayar,
        email,
        nomorHp,
        nomorHpOrtu,
        idJurusanPilihan1,
        idJurusanPilihan2,
        pekerjaanOrtu,
        daftarProdukDibeli
      ];
}
