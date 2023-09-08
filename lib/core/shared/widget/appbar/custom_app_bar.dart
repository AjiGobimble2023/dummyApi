import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/extensions.dart';
import '../../../config/global.dart';
import '../../provider/log_provider.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(
    BuildContext context, {
    Key? key,
    double? toolbarHeight,
    Color? backgroundColor,
    bool autoImplyLeading = true,
    bool implyLeadingDark = false,
    bool isOnPrimary = true,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool? centerTitle,
    Widget? flexibleSpace,
    ShapeBorder? shape,
    VoidCallback? onWillPop,
    //Variabel untuk menyimpan Log Activity saat keluar
    String? jenisProduk,
    String? keterangan,
  }) : super(
          key: key,
          title: title,
          actions: actions,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: toolbarHeight,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          backgroundColor: backgroundColor ?? Colors.transparent,
          bottom: bottom,
          centerTitle: centerTitle ?? false,
          flexibleSpace: flexibleSpace,
          shape: shape,
          titleTextStyle: context.text.titleLarge?.copyWith(
            fontSize: 20,
            color: isOnPrimary ? context.onPrimary : context.onBackground,
          ),
          leading: autoImplyLeading
              ? IconButton(
                  padding: EdgeInsets.only(
                    left: (context.isMobile) ? min(26, context.dp(24)) : context.dp(6),
                    right: (context.isMobile) ? min(14, context.dp(12)) : context.dp(3),
                  ),
                  color: implyLeadingDark
                      ? context.onBackground
                      : context.onPrimary,
                  onPressed: () {
                    if (jenisProduk != null) {
                      context.read<LogProvider>().saveLog(
                            userId: gNoRegistrasi,
                            userType: "SISWA",
                            menu: jenisProduk,
                            accessType: 'Keluar',
                            info: keterangan,
                          );
                      context.read<LogProvider>().sendLogActivity("SISWA");
                    }
                    if (onWillPop != null) {
                      onWillPop();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                )
              : null,
        );
}
