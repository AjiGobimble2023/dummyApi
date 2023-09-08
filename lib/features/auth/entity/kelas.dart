import 'package:equatable/equatable.dart';

class Kelas extends Equatable {
  final String id;
  final String namaKelas;
  final String tahunAjaran;
  final String type;

  const Kelas(
      {required this.id,
      required this.namaKelas,
      required this.tahunAjaran,
      required this.type});

  @override
  List<Object?> get props => [id, namaKelas, tahunAjaran, type];
}
