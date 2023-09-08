import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../provider/auth_otp_provider.dart';
import '../../../../core/config/extensions.dart';

class OtpTimerCountDownWidget extends StatefulWidget {
  final VoidCallback onResendTimer;
  final CountdownController countdownController;

  const OtpTimerCountDownWidget({
    Key? key,
    required this.onResendTimer,
    required this.countdownController,
  }) : super(key: key);

  @override
  State<OtpTimerCountDownWidget> createState() =>
      _OtpTimerCountDownWidgetState();
}

class _OtpTimerCountDownWidgetState extends State<OtpTimerCountDownWidget> {
  @override
  Widget build(BuildContext context) {
    return Selector<AuthOtpProvider, String>(
      selector: (_, authOtp) => authOtp.otp,
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, otp, __) {
        final padding = EdgeInsets.only(
          top: (context.isMobile) ? context.dp(14) : context.dp(10),
          bottom: (context.isMobile) ? context.dp(14) : context.dp(10),
        );

        var otpExpireTime = context
            .select<AuthOtpProvider, int>((authOtp) => authOtp.otpExpireTime);
        Duration durasiResend = Duration(seconds: otpExpireTime);

        if (kDebugMode) {
          logger.log('OTP_TIMER_COUNTDOWN-Selector: Sisa Waktu >> '
              '${durasiResend.inMinutes} menit ${durasiResend.inSeconds % 60} detik');
        }

        return Countdown(
          controller: widget.countdownController,
          seconds: durasiResend.inSeconds,
          interval: const Duration(seconds: 1),
          build: (context, time) {
            int hours = (time / 3600).floor();
            int minutes = ((time % 3600) / 60).floor();
            int seconds = (time % 60).floor();

            String displayTime =
                '${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';

            if (durasiResend.inHours >= 1) {
              displayTime =
                  '$hours : ${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';
            }

            return AnimatedSwitcher(
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              duration: const Duration(milliseconds: 600),
              child: (time == 0)
                  ? TextButton(
                      onPressed: widget.onResendTimer,
                      style: TextButton.styleFrom(
                        foregroundColor: context.onPrimary,
                        textStyle: context.text.labelLarge,
                      ),
                      child: const Text('Kirim Ulang'),
                    )
                  : Padding(
                      padding: padding,
                      child: Text(displayTime,
                          style: context.text.labelLarge
                              ?.copyWith(color: context.onPrimary)),
                    ),
            );
          },
        );
      },
    );
  }
}
