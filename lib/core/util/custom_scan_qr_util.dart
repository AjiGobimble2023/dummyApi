import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'app_exceptions.dart';
import 'data_formatter.dart';
import '../config/extensions.dart';
import '../shared/widget/qr_scanner/custom_qr_scan_widget.dart';
import '../../features/profile/entity/scanner_type.dart';

class CustomScanQrUtils {
  static bool _qrValidator(String resultQR) {
    try {
      utf8.decode(base64.decode(resultQR));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map> scanBarcode(
      BuildContext context, ScannerType scannerPilihan) async {
    final navigator = Navigator.of(context);

    logger.log('SCAN_BARCODE START');

    String? barcodeScanRes;

    switch (scannerPilihan) {
      case ScannerType.flutterBarcodeScanner:
        // Implementasi flutter_barcode_scanner.
        String hexPrimary =
            '#${context.primaryColor.value.toRadixString(16).substring(2)}';

        logger.log('SCAN_BARCODE: Primary Color Hex >> $hexPrimary');

        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            hexPrimary, 'Batal', true, ScanMode.QR);
        break;
      default:
        // Default scanner akan menggunakan package mobile_scanner
        barcodeScanRes = await navigator.push(MaterialPageRoute(
            builder: (context) => const CustomQRScanWidget()));
        break;
    }

    if (kDebugMode) {
      logger.log('SCAN_BARCODE: Scan Result >> $barcodeScanRes');
    }

    if (barcodeScanRes == null ||
        barcodeScanRes.isEmpty ||
        barcodeScanRes == '-1') {
      throw QRException(
          message:
              'QR Code tidak terbaca|Mohon pastikan QR Code dalam keadaan jelas dan coba kembali');
    }

    if (!_qrValidator(barcodeScanRes)) {
      throw QRException(message: 'QR Code tidak valid, Coba lagi!');
    }

    return DataFormatter.decodeBarcode(barcodeScanRes);
  }
}
