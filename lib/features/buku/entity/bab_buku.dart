import 'package:equatable/equatable.dart';

class BabUtamaBuku extends Equatable {
  final String namaBabUtama;
  final List<BabBuku> daftarBab;

  const BabUtamaBuku({
    required this.namaBabUtama,
    required this.daftarBab,
  });

  @override
  List<Object> get props => [namaBabUtama, daftarBab];
}

class BabBuku extends Equatable {
  final String namaBab;
  final String kodeBab;
  final String idTeoriBab;
  // final List<String> listIdTeoriBab;

  const BabBuku({
    required this.namaBab,
    required this.kodeBab,
    required this.idTeoriBab,
    // required this.listIdTeoriBab,
  });

  Map<String, dynamic> toJson() => {
        'c_NamaBab': namaBab,
        'c_KodeBab': kodeBab,
        'c_IdTeoriBab': idTeoriBab,
        // 'c_IdTeoriBab': listIdTeoriBab.join(','),
      };

  @override
  List<Object> get props => [namaBab, kodeBab, idTeoriBab];
}
