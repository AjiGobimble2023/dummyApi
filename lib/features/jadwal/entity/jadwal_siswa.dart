import 'package:equatable/equatable.dart';

class InfoJadwal extends Equatable {
  final String tanggal;
  final List<JadwalSiswa> daftarJadwalSiswa;

  const InfoJadwal({required this.tanggal, required this.daftarJadwalSiswa});

  @override
  List<Object?> get props => [tanggal, daftarJadwalSiswa];

}

class JadwalSiswa extends Equatable {
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String idKelasGO;
  final String mataPelajaran;
  final String nikPengajar;
  final String namaPengajar;

  /// [infoKegiatan] merupakan informasi mengenai paket yang diajarkan.<br>
  /// Merupakan gabungan dari response['info'] + response['package']<br>
  /// response['info'] => Jika id kegiatannya berawal dengan '0201',
  /// maka itu artinya adalah kegiatan KBM. Jika kegiatan KBM, maka value info adalah 'Paket Ke'.
  /// Selain itu value-nya adalah 'Sekolah'<br>
  /// response['package'] => Diambil dari c_Info3 pada db_IsianDPPV3.t_RencanaKerja
  final String infoKegiatan;
  final String kegiatan;
  final String idRencana;
  final String namaGedung;
  final bool feedbackPermission;

  /// [sesi] merupakan sesi / pertemuan ke berapa.
  final int sesi;

  const JadwalSiswa({
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.idKelasGO,
    required this.mataPelajaran,
    required this.nikPengajar,
    required this.namaPengajar,
    required this.infoKegiatan,
    required this.kegiatan,
    required this.idRencana,
    required this.namaGedung,
    required this.feedbackPermission,
    required this.sesi,
  });

  @override
  List<Object> get props => [
        tanggal,
        jamMulai,
        jamSelesai,
        idKelasGO,
        mataPelajaran,
        nikPengajar,
        namaPengajar,
        infoKegiatan,
        kegiatan,
        idRencana,
        namaGedung,
        feedbackPermission,
        sesi,
      ];
}