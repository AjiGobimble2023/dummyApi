import 'dart:ui';
import 'dart:developer' as logger show log;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/theme.dart';
import '../../../core/config/extensions.dart';

class RencanaMenu extends Equatable {
  final int idJenisProduk;
  final String namaJenisProduk;
  final String label;
  final Color warna;

  const RencanaMenu({
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.label,
    required this.warna,
  });

  factory RencanaMenu.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('MENU_MODEL-FromJson: Json >> $json');
    }
    return RencanaMenu(
      idJenisProduk: json['idJenisProduk'],
      namaJenisProduk: json['namaJenisProduk'],
      label: json['label'],
      warna: (json['warna'] is String)
          ? '${json['warna']}'.warnaRencana
          : Palette.kTertiarySwatch,
    );
  }

  Map<String, dynamic> toJson() => {
        'idJenisProduk': idJenisProduk,
        'namaJenisProduk': namaJenisProduk,
        'label': label,
        'warna': warna.toString(),
      };

  @override
  List<Object?> get props => [
        idJenisProduk,
        namaJenisProduk,
        label,
        warna,
      ];
}
