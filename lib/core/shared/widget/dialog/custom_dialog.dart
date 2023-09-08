// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../loading/loading_widget.dart';
import 'base_dialog.dart';

class CustomDialog {
  static Future<dynamic> basicDialog(
    BuildContext context, {
    bool? isDismissable,
    String? title,
    Widget? header,
    Widget? body,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: isDismissable ?? true,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Basic,
        header: header,
        body: body,
        listAction: [
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Outlined,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  static Future<dynamic> successDialog(
    BuildContext context, {
    String? message,
    String? confirmText,
    Function? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Success,
        message: message,
        listAction: [
          BaseDialogAction(
            text: confirmText ?? 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  static Future<dynamic> successDialogOrange(
    BuildContext context, {
    String? message,
    String? confirmText,
    Function? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Warning,
        message: message,
        listAction: [
          BaseDialogAction(
            text: confirmText ?? 'OK',
            type: DialogActionType.Filled,
            onPressed: () => onConfirm!(),
          )
        ],
      ),
    );
  }

  static Future<dynamic> informationDialog(
    BuildContext context, {
    String? message,
    Function? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Info,
        message: message,
        listAction: [
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  static Future<dynamic> warningDialog(
    BuildContext context, {
    String? message,
    Function? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Warning,
        message: message,
        listAction: [
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  static Future<dynamic> dangerDialog(
    BuildContext context, {
    String? message,
    Function? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        message: message,
        listAction: [
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => onConfirm!(),
          )
        ],
      ),
    );
  }

  static Future<dynamic> confirmationDialog(
    BuildContext context, {
    String? title,
    String? message,
    String? confirmText,
    Function? onConfirm,
    String? cancelText,
    Function? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Confirm,
        title: title,
        message: message,
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: confirmText ?? 'Ya',
            type: DialogActionType.Filled,
            onPressed: () => onConfirm!(),
          ),
          BaseDialogAction(
            text: cancelText ?? 'Tidak',
            type: DialogActionType.Outlined,
            onPressed: () => onCancel!(),
          )
        ],
      ),
    );
  }

  static Future<dynamic> diaologtanyabool(
    BuildContext context, {
    String? title,
    String? message,
    String? confirmText,
    Function? onConfirm,
    String? cancelText,
    Function? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Confirm,
        title: title,
        message: message,
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: confirmText ?? 'Ya',
            type: DialogActionType.Filled,
            onPressed: () => onConfirm!(),
          ),
          BaseDialogAction(
            text: cancelText ?? 'Tidak',
            type: DialogActionType.Outlined,
            onPressed: () => onCancel!(),
          )
        ],
      ),
    );
  }

  static Future<dynamic> loadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingWidget(),
    );
  }

  static Future<dynamic> updateDialog(
    BuildContext context, {
    required bool isWajib,
    required String title,
    required String description,
    required String url,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !isWajib,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Basic,
        header: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Image.asset(
                'assets/images/logo_gokreasi.png',
                width: 80,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            )
          ],
        ),
        body: Text(
          description,
          textAlign: TextAlign.center,
        ),
        listAction: <BaseDialogAction>[
          if (!isWajib)
            BaseDialogAction(
              text: 'Tutup',
              type: DialogActionType.Outlined,
              onPressed: () => Navigator.pop(context),
            ),
          BaseDialogAction(
            text: 'Update',
            type: DialogActionType.Filled,
            onPressed: () async {
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          )
        ],
      ),
    );
  }

  static Future<dynamic> connectionExceptionDialogLogin(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        title: 'Tidak ada Jaringan',
        message: 'Cek jaringan internet Anda, lalu coba log in kembali',
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  static Future<dynamic> connectionExceptionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        title: 'Tidak ada Jaringan',
        message:
            'Jaringan internet tidak stabil, cek jaringan internet Anda dan coba beberapa saat lagi',
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  static Future<dynamic> fatalExceptionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        title: 'Terjadi kesalahan',
        message:
            'Jaringan GO Kreasi sedang padat, coba log in beberapa saat lagi',
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> fatalExceptionDialogTOBK(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        title: 'Terjadi kesalahan',
        message:
            'Jaringan GO Kreasi sedang padat, silakan tunggu hingga waktu TO selesai',
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> fatalExceptionDialogBukuSakti(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        title: 'Terjadi kesalahan',
        message:
            'Mohon maaf, saat ini pengguna GO Kreasi sedang padat. Silakan coba beberapa saat lagi',
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> fatalExceptionDialogProfiling(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        title: 'Terjadi kesalahan',
        message:
            'Jaringan GO Kreasi sedang padat, silakan tunggu hingga waktu VAK selesai',
        listAction: <BaseDialogAction>[
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static Future boolDialog(
    BuildContext context, {
    String? message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BaseDialogWidget(
        type: DialogType.Danger,
        message: message,
        listAction: [
          BaseDialogAction(
            text: 'OK',
            type: DialogActionType.Filled,
            onPressed: () => Navigator.pop(context, true),
          )
        ],
      ),
    );
  }
}
