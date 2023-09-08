import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../config/extensions.dart';

class CustomQRScanWidget extends StatefulWidget {
  const CustomQRScanWidget({Key? key}) : super(key: key);

  @override
  State<CustomQRScanWidget> createState() => _CustomQRScanWidgetState();
}

class _CustomQRScanWidgetState extends State<CustomQRScanWidget>
    with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
  );

  bool isStarted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                fit: BoxFit.contain,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    if (kDebugMode) {
                      logger.log(
                          "MOBILE_SCANNER-OnDetect: Read result >> ${barcodes.first.rawValue}");
                    }
                    Navigator.pop(context, barcodes[0].rawValue);
                    controller.stop();
                  }
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  color: Colors.black45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 32.0,
                        color: context.background,
                        onPressed: () => controller.toggleTorch(),
                        icon: ValueListenableBuilder(
                          valueListenable: controller.torchState,
                          builder: (_, state, flashOffWidget) {
                            switch (state) {
                              case TorchState.on:
                                return Icon(
                                  Icons.flash_on,
                                  color: context.secondaryColor,
                                );
                              default:
                                return flashOffWidget!;
                            }
                          },
                          child: const Icon(
                            Icons.flash_off,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: context.dw - 200,
                          height: 50,
                          child: FittedBox(
                            child: Text(
                              'Scan QR Code',
                              overflow: TextOverflow.fade,
                              style: context.text.titleSmall
                                  ?.copyWith(color: context.background),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 32.0,
                        color: context.background,
                        onPressed: () => controller.switchCamera(),
                        icon: ValueListenableBuilder(
                          valueListenable: controller.cameraFacingState,
                          builder: (context, state, child) {
                            switch (state) {
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                              default:
                                return const Icon(Icons.camera_front);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
