import 'dart:async';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/profile_provider.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/loading/loading_widget.dart';

class HapusAkun extends StatefulWidget {
  const HapusAkun({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  State<HapusAkun> createState() => _HapusAkunState();
}

class _HapusAkunState extends State<HapusAkun> {
  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();
  late final ProfileProvider _profileProvider = context.read<ProfileProvider>();
  String? nomorHp, noRegistrasi;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    if (_authOtpProvider.userData?.siapa == "ORTU") {
      nomorHp = _authOtpProvider.userData?.nomorHpOrtu;
    } else {
      nomorHp = _authOtpProvider.userData?.nomorHp;
    }
    noRegistrasi = _authOtpProvider.userData?.noRegistrasi;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, value, child) => (value.isLoadingDeleteAccount)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(context.pd),
                  child: const LoadingWidget(
                    message:
                        "Mohon tunggu, proses pengahapusan data sedang berlangsung",
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textScaleFactor: context.textScale12,
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Hapus Akun\n\n",
                          style: context.text.titleLarge),
                      TextSpan(
                          text:
                              "Saat sobat menghapus akun, maka data sobat akan dihapus "
                              "dari sistem kami dan sobat tidak akan dapat lagi login "
                              "kembali menggunakan akun ini.\n\n"
                              "Apakah sobat yakin untuk menghapus akun ini?\n",
                          style: context.text.bodyMedium),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      isLoading == true;
                    });
                    bool deleteAccount = await _profileProvider.hapusAkun(
                        nomorHp: nomorHp!, noRegistrasi: noRegistrasi!);
                    if (deleteAccount) {
                      Future.delayed(
                        gDelayedNavigation,
                        () async {
                          var completer = Completer();
                          gNavigatorKey.currentState!.context
                              .showBlockDialog(dismissCompleter: completer);
                          await _authOtpProvider.logout();
                          completer.complete();
                        },
                      );
                    }
                  },
                  child: Container(
                    width: context.dw - context.dp(48),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      "Lanjutkan",
                      style: context.text.bodyMedium
                          ?.copyWith(color: context.background),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
