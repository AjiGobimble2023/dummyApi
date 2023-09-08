import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../../core/config/extensions.dart';
import '../../module/timer_soal/presentation/provider/tob_provider.dart';

class SoalCountdownTimer extends StatefulWidget {
  final bool isBlockingTime;
  final String kodePaket;
  final VoidCallback onEndTimer;
  final CountdownController? countdownController;

  const SoalCountdownTimer({
    Key? key,
    required this.isBlockingTime,
    required this.onEndTimer,
    this.countdownController,
    required this.kodePaket,
  }) : super(key: key);

  @override
  State<SoalCountdownTimer> createState() => _SoalCountdownTimerState();
}

class _SoalCountdownTimerState extends State<SoalCountdownTimer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.dp(6)),
      child: Selector<TOBProvider, Duration>(
        selector: (_, tob) => tob.sisaWaktu,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, sisaWaktuPengerjaan, child) {
          if (kDebugMode) {
            logger.log('SOAL_COUNTDOWN_TIMER-Selector: Sisa Waktu >> '
                '${sisaWaktuPengerjaan.inMinutes} menit ${sisaWaktuPengerjaan.inSeconds % 60} detik');
          }

          return Countdown(
            controller: widget.countdownController,
            seconds: sisaWaktuPengerjaan.inSeconds,
            interval: const Duration(seconds: 1),
            onFinished: widget.onEndTimer,
            build: (context, time) {
              int hours = (time / 3600).floor();
              int minutes = ((time % 3600) / 60).floor();
              int seconds = (time % 60).floor();

              String displayTime =
                  '${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';
              Color textColor = context.onPrimary;

              if (sisaWaktuPengerjaan.inHours >= 1) {
                displayTime =
                    '$hours : ${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';
              }

              if (time < 11) {
                bool isOdd = time.round().isOdd;
                textColor = isOdd ? context.onPrimary : context.secondaryColor;
                displayTime += '  ';

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTime,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor),
                    ),
                    Text(
                      'Waktu akan habis',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style:
                          context.text.labelSmall?.copyWith(color: textColor),
                    ),
                  ],
                );
              }

              return Text(
                displayTime,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              );
            },
          );
        },
      ),
    );
  }
}
