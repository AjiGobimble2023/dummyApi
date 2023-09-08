import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../provider/auth_otp_provider.dart';
import '../widget/otp_timer_countdown_widget.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/firebase_helper.dart';
import '../../../../core/helper/kreasi_shared_pref.dart';
import '../../../../core/shared/screen/custom_will_pop_scope.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';

class OtpScreen extends StatefulWidget {
  final bool isLogin;

  const OtpScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final CountdownController _countdownController =
      CountdownController(autoStart: true);

  final TextEditingController _code1Controller = TextEditingController();
  final TextEditingController _code2Controller = TextEditingController();
  final TextEditingController _code3Controller = TextEditingController();
  final TextEditingController _code4Controller = TextEditingController();
  final TextEditingController _code5Controller = TextEditingController();
  final TextEditingController _code6Controller = TextEditingController();

  late TextEditingController _currController = _code1Controller;

  late final AuthOtpProvider _authOtpProvider =
      context.watch<AuthOtpProvider>();

  @override
  void dispose() {
    _code1Controller.dispose();
    _code2Controller.dispose();
    _code3Controller.dispose();
    _code4Controller.dispose();
    _code5Controller.dispose();
    _code6Controller.dispose();
    // _currController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mounted) {
      logger.log('OTP SCREEN Nomor Handphone: ${_authOtpProvider.nomorHp}');
    }
    return CustomWillPopScope(
      onWillPop: () async {
        logger.log('ON_WILL_POP_OTP: isResend >> ${_authOtpProvider.isResend}');
        if (_authOtpProvider.isResend) {
          logger.log(
              'ON_WILL_POP_OTP: IF isResend >> ${_authOtpProvider.isResend}');
          return gShowBottomDialog(context,
              title: 'Konfirmasi',
              message:
                  'Apakah kamu yakin akan meninggalkan proses One-Time Password?',
              dialogType: DialogType.warning);
        } else {
          gShowBottomDialogInfo(context,
              message:
                  'Mohon tunggu hingga waktu pengiriman One-Time Password habis',
              dialogType: DialogType.info);
          return Future.value(false);
        }
      },
      onDragRight: () async {
        logger.log('ON_WILL_POP_OTP: isResend >> ${_authOtpProvider.isResend}');
        if (_authOtpProvider.isResend) {
          logger.log(
              'ON_WILL_POP_OTP: IF isResend >> ${_authOtpProvider.isResend}');
          gShowBottomDialog(context,
                  title: 'Konfirmasi',
                  message:
                      'Apakah kamu yakin akan meninggalkan proses One-Time Password?',
                  dialogType: DialogType.warning)
              .then((isKeluar) => isKeluar ? Navigator.pop(context) : null);
        } else {
          gShowBottomDialogInfo(context,
              message:
                  'Mohon tunggu hingga waktu pengiriman One-Time Password habis',
              dialogType: DialogType.info);
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primaryColor,
                  context.secondaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.16, 0.76],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: (context.isMobile)
                  ? Column(children: _buildBodyOTP(context))
                  : Row(children: _buildBodyOTP(context)),
            ),
          ),
        ),
      ),
    );
  }

  /// Fungsi Resend OTP.
  Future<void> _resendOtp() async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);

    if (kDebugMode) {
      logger.log('RESEND_OTP: START ${_authOtpProvider.otp}');
    }
    await _authOtpProvider.resendOTP().then(
      (message) {
        if (kDebugMode) {
          logger.log('RESEND_OTP: FINNISH');
        }
        completer.complete();
        gShowTopFlash(context, message,
            dialogType: (message == 'Gagal mengirim OTP, coba lagi')
                ? DialogType.error
                : DialogType.success);

        if (message != 'Gagal mengirim OTP, coba lagi') {
          logger.log(
              'RESEND_OTP: Restart Timer isCompleted(${_countdownController.isCompleted})');
          _countdownController.isCompleted = false;
          _countdownController.restart();
          _countdownController.start();
        }
      },
    );
  }

  /// Fungsi untuk verifikasi OTP code.
  void _verificationOtp() async {
    String getOtp = _authOtpProvider.otp;

    if (kDebugMode) {
      logger.log("OTP_SCREEN-VERIFICATION_OTP: Input OTP >> $getOtp");
    }
    String otp = _code1Controller.text +
        _code2Controller.text +
        _code3Controller.text +
        _code4Controller.text +
        _code5Controller.text +
        _code6Controller.text;

    if (getOtp != otp) {
      gShowTopFlash(context, "OTP tidak valid", dialogType: DialogType.error);
      return;
    }

    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    final navigator = Navigator.of(context);

    if (!widget.isLogin) {
      // Dari form registrasi
      bool isSimpanRegistrasiBerhasil =
          await _authOtpProvider.simpanRegistrasi();
      if (isSimpanRegistrasiBerhasil) {
        await KreasiSharedPref().simpanDataLokal();
        completer.complete();
        // Menggunakan delayed karena ada Exception caught by animation library
        // Tried to remove a willPop callback from a route that is not currently in the tree.
        Future.delayed(gDelayedNavigation).then((_) {
          navigator.popUntil((route) => route.isFirst);
          Future.delayed(gDelayedNavigation).then((value) {
            var context = gNavigatorKey.currentContext!;
            final userData = context.read<AuthOtpProvider>().userData;
            // Stream check login firebase
            FirebaseHelper().streamCheckLogin(
              noRegistrasi: userData?.noRegistrasi,
              userType: userData?.siapa ?? '',
              deviceId: (gAkunTester.contains((userData?.isOrtu ?? false)
                      ? '${userData?.nomorHpOrtu}'
                      : '${userData?.nomorHp}'))
                  ? gStaticImei
                  : gDeviceID,
              logout: () async =>
                  await context.read<AuthOtpProvider>().logout(),
            );
          });
        });
      }
      if (!completer.isCompleted) completer.complete();
    } else {
      // Dari form login
      bool isSimpanLoginBerhasil = await _authOtpProvider.simpanLogin();
      if (isSimpanLoginBerhasil) {
        await KreasiSharedPref().simpanDataLokal();
        completer.complete();
        // Menggunakan delayed karena ada Exception caught by animation library
        // Tried to remove a willPop callback from a route that is not currently in the tree.
        Future.delayed(gDelayedNavigation).then((_) {
          navigator.popUntil((route) => route.isFirst);
          Future.delayed(gDelayedNavigation).then((value) {
            var context = gNavigatorKey.currentContext!;
            final userData = context.read<AuthOtpProvider>().userData;
            // Stream check login firebase
            FirebaseHelper().streamCheckLogin(
              noRegistrasi: userData?.noRegistrasi,
              userType: userData?.siapa ?? '',
              deviceId: (gAkunTester.contains((userData?.isOrtu ?? false)
                      ? '${userData?.nomorHpOrtu}'
                      : '${userData?.nomorHp}'))
                  ? gStaticImei
                  : gDeviceID,
              logout: () async =>
                  await context.read<AuthOtpProvider>().logout(),
            );
          });
        });
      }
      if (!completer.isCompleted) completer.complete();
    }
  }

  /// Fungsi untuk menuliskan otp code pada text field.
  void _inputTextToField(String str) {
    if (_currController == _code1Controller) {
      _code1Controller.text = str;
      _currController = _code2Controller;
    } else if (_currController == _code2Controller) {
      _code2Controller.text = str;
      _currController = _code3Controller;
    } else if (_currController == _code3Controller) {
      _code3Controller.text = str;
      _currController = _code4Controller;
    } else if (_currController == _code4Controller) {
      _code4Controller.text = str;
      _currController = _code5Controller;
    } else if (_currController == _code5Controller) {
      _code5Controller.text = str;
      _currController = _code6Controller;
    } else if (_currController == _code6Controller) {
      _code6Controller.text = str;
      _currController = _code6Controller;
    }
    setState(() {});
  }

  /// Fungsi untuk menghapus karakter otp pada text field.
  void _deleteTextFromField() {
    setState(() {
      if (_currController.text.isNotEmpty) {
        _currController.text = '';
        _currController = _code6Controller;
        return;
      }

      if (_currController == _code1Controller) {
        _code1Controller.text = '';
      } else if (_currController == _code2Controller) {
        _code1Controller.text = '';
        _currController = _code1Controller;
      } else if (_currController == _code3Controller) {
        _code2Controller.text = '';
        _currController = _code2Controller;
      } else if (_currController == _code4Controller) {
        _code3Controller.text = '';
        _currController = _code3Controller;
      } else if (_currController == _code5Controller) {
        _code4Controller.text = '';
        _currController = _code4Controller;
      } else if (_currController == _code6Controller) {
        _code5Controller.text = '';
        _currController = _code5Controller;
      }
    });
  }

  List<Widget> _buildBodyOTP(BuildContext context) => (context.isMobile)
      ? [
          const Spacer(flex: 3),
          if (context.dh > 599)
            CustomImageNetwork(
              'ilustrasi_otp.png'.illustration,
              // height: context.h(160),
              height: min(context.dh * 0.16, context.h(160)),
              fit: BoxFit.fitHeight,
            ),
          SizedBox(height: context.h(20)),
          _buildTitleHeader(context),
          OtpTimerCountDownWidget(
              countdownController: _countdownController,
              onResendTimer: _resendOtp),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildListTextFieldOTP(),
          ),
          const Spacer(flex: 2),
          _buildOtpNumPad(context)
        ]
      : [
          Expanded(
            child: Column(
              children: [
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    CustomImageNetwork(
                      'ilustrasi_otp.png'.illustration,
                      // height: context.h(160),
                      width: (context.isMobile)
                          ? null
                          : min(context.dh * 0.16, context.h(160)),
                      height: min(context.dh * 0.16, context.h(160)),
                      fit: BoxFit.fitHeight,
                    ),
                    _buildTitleHeader(context),
                    const Spacer(flex: 2),
                  ],
                ),
                OtpTimerCountDownWidget(
                    countdownController: _countdownController,
                    onResendTimer: _resendOtp),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildListTextFieldOTP(),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: _buildOtpNumPad(context),
          ),
        ];

  /// Widget Title OTP
  Widget _buildTitleHeader(BuildContext context) => RichText(
        textAlign: TextAlign.center,
        textScaleFactor: context.textScale12,
        text: TextSpan(
          text: 'Verifikasi Nomor Anda\n',
          style: context.text.headlineSmall?.copyWith(
              color: context.onPrimary,
              fontWeight: FontWeight.w600,
              height: 2.6),
          children: [
            TextSpan(
                text: _authOtpProvider.otpVia.value == OtpVia.email
                    ? 'Mohon masukkan kode OTP yang dikirim\nke email anda. '
                    : 'Mohon masukkan kode OTP yang dikirim\nke nomor ',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.onPrimary)),
            TextSpan(
                text: _authOtpProvider.otpVia.value == OtpVia.email
                    ? ""
                    : _authOtpProvider.nomorHp,
                style: context.text.labelLarge?.copyWith(
                    color: context.onPrimary, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  /// List of Widget TextFormField OTP
  List<Widget> _buildListTextFieldOTP() => [
        _buildTextFieldOTP(controller: _code1Controller),
        _buildTextFieldOTP(controller: _code2Controller),
        _buildTextFieldOTP(controller: _code3Controller),
        _buildTextFieldOTP(controller: _code4Controller),
        _buildTextFieldOTP(controller: _code5Controller),
        _buildTextFieldOTP(controller: _code6Controller),
      ];

  /// Widget TextFormField OTP
  Widget _buildTextFieldOTP({required TextEditingController controller}) {
    double sizeInputOTP = (context.isMobile)
        ? (context.dw - context.dp(100)) / 6
        : (context.dw * 0.38) / 6;

    return Container(
      width: sizeInputOTP,
      height: sizeInputOTP,
      margin: EdgeInsets.symmetric(
          vertical: (context.isMobile) ? context.dp(40) : context.dp(14),
          horizontal: (context.isMobile) ? 3 : 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        enabled: false,
        autofocus: false,
        readOnly: true,
        controller: controller,
        inputFormatters: [LengthLimitingTextInputFormatter(1)],
        style:
            context.text.headlineSmall?.copyWith(color: context.onBackground),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Number Pad Button
  Widget _buildNumberPad(int num) => SizedBox(
        height: (context.isMobile) ? context.h(70) : context.h(100),
        child: TextButton(
          onPressed: () => _inputTextToField('$num'),
          style: TextButton.styleFrom(
            foregroundColor: context.onBackground,
            padding: EdgeInsets.all(
              (context.isMobile) ? context.dp(14) : 12,
            ),
          ),
          child: FittedBox(child: Text('$num')),
        ),
      );

  /// Action Button pada Numpad
  Widget _buildActionButton(
          {required IconData icon, VoidCallback? onPressed, Color? color}) =>
      SizedBox(
        height: (context.isMobile) ? context.h(70) : context.h(100),
        child: IconButton(
          onPressed: onPressed,
          icon: FittedBox(child: Icon(icon)),
          color: color,
          disabledColor: context.disableColor,
        ),
      );

  /// Widget Keyboard Numpad
  Container _buildOtpNumPad(BuildContext context) {
    return Container(
      margin: (context.isMobile)
          ? null
          : EdgeInsets.only(
              left: context.dp(6),
              right: context.dp(14),
            ),
      padding: (context.isMobile)
          ? EdgeInsets.only(
              bottom: min(22, context.bottomBarHeight),
            )
          : null,
      constraints: BoxConstraints(
        minHeight: context.dh * 0.3,
        maxHeight: (context.isMobile) ? context.dh * 0.48 : context.dh * 0.8,
      ),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: (context.isMobile)
            ? const BorderRadius.vertical(top: Radius.circular(30))
            : BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: context.onBackground.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
            verticalInside: BorderSide(
                width: 1, color: context.onBackground.withOpacity(0.34)),
            horizontalInside: BorderSide(
                width: 1, color: context.onBackground.withOpacity(0.34))),
        children: [
          TableRow(
            children:
                List<Widget>.generate(3, (index) => _buildNumberPad(index + 1)),
          ),
          TableRow(
            children:
                List<Widget>.generate(3, (index) => _buildNumberPad(index + 4)),
          ),
          TableRow(
            children:
                List<Widget>.generate(3, (index) => _buildNumberPad(index + 7)),
          ),
          TableRow(
            children: [
              _buildActionButton(
                  onPressed: (_code1Controller.text.isNotEmpty &&
                          _code2Controller.text.isNotEmpty &&
                          _code3Controller.text.isNotEmpty &&
                          _code4Controller.text.isNotEmpty &&
                          _code5Controller.text.isNotEmpty &&
                          _code6Controller.text.isNotEmpty)
                      ? _verificationOtp
                      : null,
                  icon: Icons.check_circle_outline_rounded,
                  color: Palette.kSuccessSwatch[500]),
              _buildNumberPad(0),
              _buildActionButton(
                  onPressed: _deleteTextFromField,
                  icon: Icons.backspace_rounded,
                  color: Palette.kErrorSwatch[600])
            ],
          ),
        ],
      ),
    );
  }
}
