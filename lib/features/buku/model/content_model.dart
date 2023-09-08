import 'package:equatable/equatable.dart';

class ContentModel extends Equatable {
  /// [uraian] merupakan isi dari teori / rumus
  /// pada bab tersebut dengan format HTML.
  final String uraian;
  final String idTeoriBab;

  const ContentModel({
    required this.idTeoriBab,
    required this.uraian,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) => ContentModel(
        idTeoriBab: json['c_idteoribab'],
        uraian: json['c_Uraian'],
      );

  @override
  List<Object> get props => [idTeoriBab, uraian];
}
