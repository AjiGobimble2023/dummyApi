import 'package:equatable/equatable.dart';

class Nilai extends Equatable {
  final String kodeTob;
  final String tob;
  final bool isSelected;
  final bool isFix;
  final Map<String, dynamic> detailNilai;

  const Nilai({
    required this.kodeTob,
    required this.tob,
    required this.isSelected,
    required this.isFix,
    required this.detailNilai,
  });

  @override
  List<Object> get props => [
        kodeTob,
        tob,
        isSelected,
        isFix,
        detailNilai,
      ];
}
