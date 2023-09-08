import 'package:flutter/material.dart';

import 'basic_empty.dart';

class UnderConstructionWidget extends BasicEmpty {
  final String namaFitur;

  const UnderConstructionWidget({
    Key? key,
    required this.namaFitur,
    super.imageWidth,
    super.imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/kreasi-f1f7b.appspot.com/o/ilustrasi%2Filustrasi_under_construction.png?alt=media&token=182dce54-f1a1-4847-ac51-d7211e33a33f',
    super.shrink,
    super.textColor,
  }) : super(
          key: key,
          title: 'Under Construction',
          subTitle: 'Fitur "$namaFitur" sedang dalam pengembangan',
          emptyMessage:
              'Hi Sobat! Mohon maaf atas ketidaknyamanannya karena fitur "$namaFitur" sedang dalam pengembangan oleh tim kami.',
        );
}
