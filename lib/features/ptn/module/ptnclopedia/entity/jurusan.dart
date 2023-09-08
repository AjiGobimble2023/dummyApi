import 'package:equatable/equatable.dart';

/// NOT:
/// DB=>GO ICONS
/// Table = t_PerguruanTinggi, t_Jurusan, t_TransJurusan
///
/// t_PerguruanTinggi =>
///   c_IdPerguruanTinggi, c_IdDistrict (t_Idn_District), c_NamaPerguruanTinggi, c_Jenis
///
/// t_Jurusan =>
///   c_IdJurusan, c_IdPerguruanTinggi, c_NamaJurusan, c_Kelompok (0302 = SOSHUM dan 0301 = SAINTEK),
///   c_Rumpun (c_Kode di t_TransJurusan), c_Keterangan (json peminat dan tampung),
///   c_PG (Passing Grade), c_PGUM (Passing Grade Ujian Mandiri), c_PLUM (Prediksi Lulus Ujian Mandiri),
///   c_LintasJurusan, c_IsSBMPTN, c_IsUM (Ujian Mandiri)
///
/// t_TransJurusan =>
///   c_Kode, c_Deskripsi, c_Upline, c_Keterangan (bobot, mapel, kelompok)
///
/// t_Idn_District => (Kabupaten / Kota)
///   c_IdDistrict, c_IdProvinsi, c_District, c_PhoneCode
///
/// t_Idn_Provinsi =>
///   c_IdProvinsi, c_Provinsi
///
/// DB => GO Learn -> GO Icons
/// Table = t_Jurusan, t_JurusanDeskripsi
///
/// t_JurusanDeskripsi =>
///   c_IdJurusan, c_Deskripsi, c_LapanganKerja
///
/// [id] merupakan c_IdJurusan pada t_Jurusan.<br>
/// [namaJurusan] merupakan c_NamaJurusan pada t_Jurusan.<br>
/// [kelompok] merupakan c_Kelompok pada t_Jurusan (0302 = SOSHUM dan 0301 = SAINTEK).<br>
/// [rumpun] merupakan c_Deskripsi pada t_TransJurusan JOIN t_Jurusan c_Rumpun = c_Kode.<br>
/// [peminat] merupakan jumlah peminat, ada di json c_Keterangan pada t_Jurusan.<br>
/// [dayaTampung] merupakan jumlah tampung, ada di json c_Keterangan pada t_Jurusan.<br>
/// [deskripsi] merupakan c_Deskripsi pada t_JurusanDeskripsi.<br>
/// [lapanganPekerjaan] merupakan c_LapanganKerja pada t_JurusanDeskripsi.<br>
/// [namaPerguruanTinggi] merupakan c_NamaPerguruanTinggi pada t_PerguruanTinggi.<br>
/// [jenisPerguruanTinggi] merupakan c_Jenis pada t_PerguruanTinggi.<br>
/// [lokasi] merupakan gabungan Distric dan Provinsi dari t_Idn_District dan t_Idn_Provinsi.<br>
/// [isLintasJurusan] merupakan c_LintasJurusan pada t_Jurusan.
class Jurusan extends Equatable {
  final int idPTN;
  final int idJurusan;
  final String namaJurusan;
  final String kelompok;
  final String rumpun;
  final List peminat;
  final List tampung;
  final bool lintas;
  final String? passGrade;
  final String? deskripsi;
  final String? lapanganPekerjaan;

  const Jurusan({
    required this.idPTN,
    required this.idJurusan,
    required this.namaJurusan,
    required this.kelompok,
    required this.rumpun,
    required this.peminat,
    required this.tampung,
    this.passGrade,
    required this.lintas,
    this.deskripsi,
    this.lapanganPekerjaan,
  });

  @override
  List<Object> get props => [
        idPTN,
        idJurusan,
        namaJurusan,
        kelompok,
        rumpun,
        lintas,
      ];
}
