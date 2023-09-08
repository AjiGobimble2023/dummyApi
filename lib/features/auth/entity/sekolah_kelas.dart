import 'package:equatable/equatable.dart';

class SekolahKelas extends Equatable {
  final String id;
  final String namaKelas;

  const SekolahKelas({required this.id, required this.namaKelas});

  @override
  List<Object?> get props => [id, namaKelas];

}