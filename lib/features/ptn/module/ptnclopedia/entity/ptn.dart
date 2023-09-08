import 'package:equatable/equatable.dart';

class PTN extends Equatable {
  final int idPTN;
  final String namaPTN;
  final String aliasPTN;
  final String jenisPTN;

  const PTN({
    required this.idPTN,
    required this.namaPTN,
    required this.aliasPTN,
    required this.jenisPTN,
  });

  @override
  List<Object> get props => [idPTN, namaPTN, jenisPTN];
}
