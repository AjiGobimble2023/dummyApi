import 'package:equatable/equatable.dart';

class CapaianDetailScore extends Equatable {
  final String label;
  final int benar;
  final int salah;
  final int? kosong;
  final int? score;

  int get total => benar + salah + (kosong ?? 0);

  const CapaianDetailScore({
    required this.label,
    required this.benar,
    required this.salah,
    this.kosong,
    this.score,
  });

  factory CapaianDetailScore.fromJson(Map<String, dynamic> json) =>
      CapaianDetailScore(
        label: json['label'],
        benar: json['benar'],
        salah: json['salah'],
        score: json['score'],
      );

  @override
  List<Object?> get props => [label, benar, salah, score];
}
