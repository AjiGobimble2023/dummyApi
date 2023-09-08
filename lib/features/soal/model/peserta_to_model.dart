import '../../../core/util/data_formatter.dart';
import '../entity/peserta_to.dart';

// ignore: must_be_immutable
class PesertaTOModel extends PesertaTO {
  PesertaTOModel({
    required super.noRegistrasi,
    required super.kodePaket,
    super.tanggalSiswaSubmit,
    required super.isSelesai,
    required super.isPernahMengerjakan,
    super.kapanMulaiMengerjakan,
    super.deadlinePengerjaan,
    super.keterangan,
    super.pilihanSiswa,
    super.flagFirebase,
    super.persetujuan,
  });

  factory PesertaTOModel.fromJson(Map<String, dynamic> json) => PesertaTOModel(
        noRegistrasi: json['cNoRegister'],
        kodePaket: json['cKodeSoal'],
        tanggalSiswaSubmit:
            (json['cTanggalTO'] == null || json['cTanggalTO'] == '-')
                ? null
                : DataFormatter.stringToDate(json['cTanggalTO']),
        isSelesai: (json['cSudahSelesai'] == 'n') ? false : true,
        isPernahMengerjakan: (json['cOK'] == 'n') ? false : true,
        kapanMulaiMengerjakan:
            (json['cTglMulai'] == null || json['cTglMulai'] == '-')
                ? null
                : DataFormatter.stringToDate(json['cTglMulai']),
        deadlinePengerjaan:
            (json['cTglSelesai'] == null || json['cTglSelesai'] == '-')
                ? null
                : DataFormatter.stringToDate(json['cTglSelesai']),
        keterangan: json['cKeterangan'],
        pilihanSiswa: json['cPilihanSiswa'],
        flagFirebase: json['cFlag'] ?? 0,
        persetujuan: json['cPersetujuan'] ?? 0,
      );
}
