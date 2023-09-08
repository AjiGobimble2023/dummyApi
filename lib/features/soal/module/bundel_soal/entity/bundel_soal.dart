import 'package:equatable/equatable.dart';

import '../../../../../core/config/constant.dart';

enum OpsiUrut { bab, nomor }

/// [BundelSoal] merupakan model dari tabel t\_BundelSoal pada db\_banksoalV2.<br>
/// Kumpulan [BundelSoal] didapat berdasarkan c\_KodePaket dari db\_banksoalV2.t\_PaketDanBundel.<br><br>
///
/// Module Soal yang menggunakan [BundelSoal]:<br>
/// 1. Latihan Extra (id: 76).<br>
/// 2. Paket Intensif (id: 77).<br>
/// 3. Paket Soal Koding (id: 78).<br>
/// 4. Pendalaman Materi (id: 79).<br>
/// 5. Soal Referensi (id: 82).
class BundelSoal extends Equatable {
  final String idBundel;
  final String kodeTOB;
  final String kodePaket;
  final String idSekolahKelas;
  final int idKelompokUjian;
  final String namaKelompokUjian;
  final String initialKelompokUjian;
  final String deskripsi;

  /// [waktuPengerjaan] waktu dalam satuan menit
  final int? waktuPengerjaan;
  final int jumlahSoal;
  final bool isTeaser;

  final OpsiUrut opsiUrut;

  const BundelSoal({
    required this.kodeTOB,
    required this.kodePaket,
    required this.idBundel,
    required this.idSekolahKelas,
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
    required this.initialKelompokUjian,
    required this.deskripsi,
    this.waktuPengerjaan,
    required this.jumlahSoal,
    this.isTeaser = false,
    required this.opsiUrut,
  });

  String get sekolahKelas =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == idSekolahKelas,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['kelas'] ??
      'Undefined';

  int get tingkatKelas {
    String tingkatKelas = Constant.kDataSekolahKelas.singleWhere(
          (sekolah) => sekolah['id'] == idSekolahKelas,
          orElse: () => {
            'id': '0',
            'kelas': 'Undefined',
            'tingkat': 'Other',
            'tingkatKelas': '0'
          },
        )['tingkatKelas'] ??
        '0';

    return int.tryParse(tingkatKelas) ?? 0;
  }

  @override
  List<Object?> get props => [
        idBundel,
        kodeTOB,
        kodePaket,
        idSekolahKelas,
        idKelompokUjian,
        namaKelompokUjian,
        initialKelompokUjian,
        deskripsi,
        waktuPengerjaan,
        jumlahSoal,
        isTeaser,
        opsiUrut,
      ];
}
