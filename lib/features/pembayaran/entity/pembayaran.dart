import 'dart:developer' as logger show log;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/util/data_formatter.dart';

class Pembayaran extends Equatable {
  final String id;
  final String total;
  final String current;
  final String remaining;
  final String status;
  final String? message;
  final DateTime? jatuhTempo;

  const Pembayaran({
    required this.id,
    required this.total,
    required this.current,
    required this.remaining,
    required this.status,
    this.message,
    this.jatuhTempo,
  });

  String get displayJatuhTempo {
    if (kDebugMode) {
      logger.log('PEMBAYARAN-DisplayJatuhTempo: Jatuh Tempo >> $jatuhTempo');
    }
    if (jatuhTempo != null) {
      return DataFormatter.dateTimeToString(jatuhTempo!, 'dd MMMM yyyy');
    }
    return (status == 'LUNAS') ? 'Sudah Lunas' : 'n/a';
  }

  String get hargaBimbelFinal => DataFormatter.formatIDR(int.parse(total));

  String get sudahBayar => DataFormatter.formatIDR(int.parse(current));

  String get sisaPembayaran => DataFormatter.formatIDR(int.parse(remaining));

  @override
  List<Object> get props => [id, total, current, remaining, status];
}
