import 'package:equatable/equatable.dart';

class Info extends Equatable {
  final int? jumlah;
  final int? tahun;

  const Info({
    this.jumlah,
    this.tahun,
  });

  @override
  List<Object> get props => [jumlah!, tahun!];
}
