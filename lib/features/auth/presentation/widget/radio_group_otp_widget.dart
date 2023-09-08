import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_otp_provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/extensions.dart';

class RadioGroupOtpWidget extends StatelessWidget {
  const RadioGroupOtpWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthOtpProvider auth = context.read<AuthOtpProvider>();
    //
    // if (auth.authRole == AuthRole.tamu)
    //   Radio<OtpVia>(
    //     value: OtpVia.email,
    //     groupValue: otpVia,
    //     onChanged: (value) => auth.otpVia = value!,
    //   ),
    // if (auth.authRole == AuthRole.tamu) _label(context, 'Email'),
    // if (auth.authRole != AuthRole.tamu)
    // Tooltip(
    // triggerMode: TooltipTriggerMode.tap,
    // message: 'Dikirim ke email yang terdaftar pada GO Kreasi',
    // child: Icon(Icons.help_outline_rounded,
    // size: 18, color: context.hintColor),
    // ),
    //
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Kirim Otp Via:',
          style: (context.isMobile)
              ? context.text.bodyMedium
              : context.text.bodySmall?.copyWith(color: context.onBackground),
        ),
        SizedBox(height: (context.isMobile) ? context.dp(4) : 6),
        Padding(
          padding: EdgeInsets.only(
            left: context.dp(16),
            right: context.dp(24),
          ),
          child: ValueListenableBuilder<OtpVia>(
            valueListenable: auth.otpVia,
            builder: (context, otpVia, _) {
              return Row(children: [
                Transform.scale(
                  scale: (!context.isMobile) ? 1.3 : 1,
                  child: Radio<OtpVia>(
                    value: OtpVia.email,
                    groupValue: otpVia,
                    onChanged: (email) => auth.otpVia.value = email!,
                  ),
                ),
                _label(context, 'Email'),
                const Spacer(),
                Transform.scale(
                  scale: (!context.isMobile) ? 1.3 : 1,
                  child: Radio<OtpVia>(
                    value: OtpVia.sms,
                    groupValue: otpVia,
                    onChanged: (sms) => auth.otpVia.value = sms!,
                  ),
                ),
                _label(context, 'SMS'),
                const Spacer(),
                Transform.scale(
                  scale: (!context.isMobile) ? 1.3 : 1,
                  child: Radio<OtpVia>(
                    value: OtpVia.wa,
                    groupValue: otpVia,
                    onChanged: (wa) => auth.otpVia.value = wa!,
                  ),
                ),
                _label(context, 'WA'),
                const Spacer(),
              ]);
            },
          ),
        ),
      ],
    );
  }

  Text _label(BuildContext context, String label) => Text(
        label,
        style: ((!context.isMobile)
                ? context.text.labelSmall
                : context.text.labelLarge)
            ?.copyWith(color: context.hintColor),
      );
}
