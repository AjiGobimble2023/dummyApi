import 'package:equatable/equatable.dart';

class Simulasi extends Equatable {
  final String id;
  final String label;
  final bool prevStep;

  const Simulasi({
    required this.id,
    required this.label,
    required this.prevStep,
  });

  @override
  List<Object> get props => [id, label, prevStep];
}
