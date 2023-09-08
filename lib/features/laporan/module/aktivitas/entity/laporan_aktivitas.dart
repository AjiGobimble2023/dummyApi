import 'package:equatable/equatable.dart';

class LaporanAktivitas extends Equatable {
  final String id;
  final String menu;
  final String detail;
  final String masuk;
  final String keluar;

  const LaporanAktivitas({
    required this.id,
    required this.menu,
    required this.detail,
    required this.masuk,
    required this.keluar,
  });

  @override
  List<Object> get props => [id, menu, detail, masuk, keluar];
}
