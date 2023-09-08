import '../entity/pembayaran.dart';
import '../../../core/util/data_formatter.dart';

class PembayaranModel extends Pembayaran {
  const PembayaranModel({
    required String id,
    required String total,
    required String current,
    required String remaining,
    required String status,
    String? message,
    DateTime? jatuhTempo,
  }) : super(
          id: id,
          total: total,
          current: current,
          remaining: remaining,
          status: status,
          message: message,
          jatuhTempo: jatuhTempo,
        );

  factory PembayaranModel.fromJson(Map<String, dynamic> json) =>
      PembayaranModel(
        id: json['id'] ?? json['c_idpembelian'],
        total: json['total'] ?? '0',
        current: json['current'] ?? '0',
        remaining: json['remaining'] ?? '0',
        status: json['status'],
        message: json['message'],
        jatuhTempo: (json['c_jatuhtempo'] != null && json['c_jatuhtempo'] != '')
            ? DataFormatter.stringToDate(json['c_jatuhtempo'], 'yyy-MM-dd')
            : null,
      );
}
