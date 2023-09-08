import 'package:equatable/equatable.dart';

class Wacana extends Equatable {
  final int idWacana;
  final String judulWacana;
  final String wacanaText;

  const Wacana(
      {required this.idWacana,
      required this.judulWacana,
      required this.wacanaText});

  @override
  List<Object?> get props => [idWacana, judulWacana, wacanaText];
}
