import '../../../core/util/data_formatter.dart';

import '../entity/jadwal_siswa.dart';

class InfoJadwalModel extends InfoJadwal {
  const InfoJadwalModel({
    required super.tanggal,
    required super.daftarJadwalSiswa,
  });

  factory InfoJadwalModel.fromJson(Map<String, dynamic> json) {
    List<JadwalSiswa> daftarJadwal = [];

    if (json['listJadwal'].isNotEmpty) {
      for (var jadwal in json['listJadwal']) {
        daftarJadwal.add(JadwalSiswaModel.fromJson(jadwal));
      }
    }

    return InfoJadwalModel(
      tanggal: DataFormatter.dateTimeToString(
          DataFormatter.stringToDate(json['tanggal'], 'yyyy-MM-dd'),
          'dd MMMM yyyy'),
      daftarJadwalSiswa: daftarJadwal,
    );
  }
}

class JadwalSiswaModel extends JadwalSiswa {
  const JadwalSiswaModel({
    required super.tanggal,
    required super.jamMulai,
    required super.jamSelesai,
    required super.idKelasGO,
    required super.mataPelajaran,
    required super.nikPengajar,
    required super.namaPengajar,
    required super.infoKegiatan,
    required super.kegiatan,
    required super.idRencana,
    required super.namaGedung,
    required super.feedbackPermission,
    required super.sesi,
  });

  factory JadwalSiswaModel.fromJson(Map<String, dynamic> json) =>
      JadwalSiswaModel(
        tanggal: json['date'],
        jamMulai: json['start'],
        jamSelesai: json['finish'],
        idKelasGO: json['classId'],
        mataPelajaran: json['lesson'] ?? "-",
        nikPengajar: json['id'],
        namaPengajar: json['fullName'],
        infoKegiatan: '${json['info'] ?? '-'} ${json['package'] ?? '-'}',
        kegiatan: json['activity'] ?? "",
        idRencana: json['planId'],
        namaGedung: json['placeName'],
        feedbackPermission: json['feedbackPermission'],
        sesi: json['session'],
      );
}
