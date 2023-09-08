import 'package:flutter/material.dart';

import 'basic_empty.dart';

class NoDataFoundWidget extends BasicEmpty {
  const NoDataFoundWidget({
    Key? key,
    super.imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/kreasi-f1f7b.appspot.com/o/ilustrasi%2Filustrasi_data_not_found.png?alt=media',
    super.shrink,
    super.imageWidth,
    super.textColor,
    super.isLandscape,
    required super.subTitle,
    required super.emptyMessage,
  }) : super(key: key, title: 'Oops!!');
}
