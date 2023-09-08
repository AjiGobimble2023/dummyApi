import '../entity/laporan_list_tryout.dart';

class LaporanListTryoutModel extends LaporanListTryout {
  const LaporanListTryoutModel(
      {required String kode,
      required String nama,
      required String tanggalAkhir,
      required String penilaian,
      required String link,
      required bool isExists})
      : super(
            kode: kode,
            nama: nama,
            tanggalAkhir: tanggalAkhir,
            penilaian: penilaian,
            link: link,
            isExists: isExists);

  factory LaporanListTryoutModel.fromJson(Map<String, dynamic> json) =>
      LaporanListTryoutModel(
          kode: json['kodeTOB'],
          nama: json['namaTOB'],
          tanggalAkhir: json['tanggalAkhir'],
          penilaian: json['penilaian'],
          link: json['link'],
          isExists: json['isexists']);
}
