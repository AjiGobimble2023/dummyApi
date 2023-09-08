import '../entity/laporan_tryout_tob.dart';
import 'laporan_tryout_pilihan_model.dart';

class LaporanTryoutTobModel extends LaporanTryoutTob {
  const LaporanTryoutTobModel(
      {required String kode,
      required String nama,
      required String penilaian,
      required String link,
      required List<LaporanTryoutPilihanModel> pilihan,
      required bool isExists,
      required String tanggalAkhir})
      : super(
            kode: kode,
            nama: nama,
            penilaian: penilaian,
            link: link,
            pilihan: pilihan,
            isExists: isExists,
            tanggalAkhir: tanggalAkhir);

  factory LaporanTryoutTobModel.fromJson(Map<String, dynamic> json) =>
      LaporanTryoutTobModel(
        kode: json['kodeTOB'],
        nama: json['namaTOB'],
        penilaian: json['penilaian'],
        link: json['link'],
        pilihan: (json['info'] as List)
            .map((val) => LaporanTryoutPilihanModel.fromJson(val))
            .toList(),
        isExists: json['isexists'],
        tanggalAkhir: json['tanggalAkhir'],
      );
}
