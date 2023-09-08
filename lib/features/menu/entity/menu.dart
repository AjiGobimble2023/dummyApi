import 'package:equatable/equatable.dart';

class Menu extends Equatable {
  final int idJenis;
  final String label;
  final String namaJenisProduk;
  final String? iconPath;
  final List<String>? permission;

  const Menu({
    required this.idJenis,
    required this.label,
    required this.namaJenisProduk,
    this.iconPath,
    this.permission,
  });

  @override
  List<Object> get props => [idJenis, label, namaJenisProduk];
}
