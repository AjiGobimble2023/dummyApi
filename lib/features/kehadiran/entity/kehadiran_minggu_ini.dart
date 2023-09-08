import 'package:equatable/equatable.dart';

class KehadiranMingguIni extends Equatable {
  final int jumlahHadir;
  final int jumlahPertemuan;

  const KehadiranMingguIni({
    required this.jumlahHadir,
    required this.jumlahPertemuan,
  });

  @override
  List<Object?> get props => [jumlahHadir, jumlahPertemuan];
}
