import 'package:equatable/equatable.dart';

class DetailHasil extends Equatable {
  final String? namaKelompokUjian;
  final int benar;
  final int salah;
  final int kosong;

  const DetailHasil({
    required this.namaKelompokUjian,
    required this.benar,
    required this.salah,
    required this.kosong,
  });

  Map<String, dynamic> toJson() => {
        'namaKelompokUjian': namaKelompokUjian,
        'benar': benar,
        'salah': salah,
        'kosong': kosong,
      };

  @override
  List<Object?> get props => [
        namaKelompokUjian,
        benar,
        salah,
        kosong,
      ];
}
