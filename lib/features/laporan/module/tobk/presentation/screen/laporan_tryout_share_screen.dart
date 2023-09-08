import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';

class LaporanTryoutShareScreen extends StatefulWidget {
  const LaporanTryoutShareScreen({
    Key? key,
    required this.chart,
    required this.pilihan,
  }) : super(key: key);
  final Widget chart;
  final Widget pilihan;

  @override
  State<LaporanTryoutShareScreen> createState() =>
      _LaporanTryoutShareScreenState();
}

class _LaporanTryoutShareScreenState extends State<LaporanTryoutShareScreen> {
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  final screenshotController = ScreenshotController();
  late final NavigatorState navigator = Navigator.of(context);

  String? userFullName, userCity;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    userFullName = _authProvider.userData!.namaLengkap;
    userCity = _authProvider.userData!.namaKota;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            buildTemplate(),
            const Spacer(),
            buildSelectStyle(),
            buildActionButton(context)
          ],
        ),
      ),
    );
  }

  Container buildSelectStyle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: List.generate(
            2,
            (index) => buildStyle(index),
          ),
        ),
      ),
    );
  }

  Container buildActionButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              try {
                // CustomDialog.loadingDialog(context);
                final image = await screenshotController.capture();
                final directory = await getApplicationDocumentsDirectory();
                final imagePath =
                    await File('${directory.path}/image.png').create();
                await imagePath.writeAsBytes(image!);
                const caption =
                    "[FLEXING TRYOUT]\nHai guys, saya dapat nilai tryout segini loh!\nJangan mau kalah ya Sobat";
                //! Deprecated
                // ignore: deprecated_member_use
                Share.shareFiles([imagePath.path], text: caption);
                // navigator.pop();
              } catch (_) {
                navigator.pop();
                gShowTopFlash(context,
                    "Yaah, jaringan GO Kreasi sedang padat Sobat, coba beberapa saat lagi ya");
              }
            },
          ),
        ],
      ),
    );
  }

  SizedBox buildTemplate() {
    return SizedBox(
      height: context.dh * 0.65,
      child: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/bg-tobk.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/img/logo.webp',
                          width: 120,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text("Nama",
                                    style: context.text.bodyMedium),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  ': ${userFullName ?? '-'}',
                                  style: context.text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text("Kota",
                                    style: context.text.bodyMedium),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  ': ${userCity ?? '-'}',
                                  style: context.text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: selectedStyle(selected),
                    ),
                    const SizedBox(height: 15)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget selectedStyle(int index) {
    switch (index) {
      case 0:
        return Align(
          alignment: Alignment.center,
          child: widget.chart,
        );
      case 1:
        return Column(children: [
          widget.chart,
          const SizedBox(height: 15),
          widget.pilihan,
        ]);
      default:
        return Container();
    }
  }

  GestureDetector buildStyle(int index) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: index == selected
              ? Border.all(
                  color: context.primaryColor,
                  width: 1,
                )
              : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(Icons.style, color: Colors.white),
            const SizedBox(height: 10),
            Text("Style ${index + 1}",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onTap: () => setState(() => selected = index),
    );
  }
}
