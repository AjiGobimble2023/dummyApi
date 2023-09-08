import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/form/custom_text_form_field.dart';
import '../../../../core/util/form_validator.dart';
import '../provider/auth_otp_provider.dart';
import 'radio_group_otp_widget.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController nomorHandphoneTextController;

  const LoginFormWidget({
    Key? key,
    required this.nomorHandphoneTextController,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  late final AuthOtpProvider _authOtpProvider = context.read<AuthOtpProvider>();

  @override
  void setState(VoidCallback fn) => (mounted) ? super.setState(fn) : fn();

  @override
  Widget build(BuildContext context) {
    return (context.isMobile)
        ? ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: _buildForm(),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildForm(),
          );
  }

  List<Widget> _buildForm() => [
        Container(
          color: context.background,
          margin: EdgeInsets.only(
            top: (context.isMobile)
                ? context.dp(24)
                : (context.dh > 650)
                    ? context.h(140)
                    : 16,
            bottom: (context.isMobile) ? context.dp(10) : 14,
          ),
          child: Text(
            'Hi Sobat GO',
            style: context.text.headlineLarge?.copyWith(
              fontSize: (context.isMobile) ? 32 : 28,
              color: context.onBackground,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dp(10)),
          child: Text(
            'Masukkan nomor handphone yang terdaftar untuk masuk kedalam aplikasi.',
            style: context.text.bodyMedium?.copyWith(
              color: context.hintColor,
              fontSize: (context.isMobile) ? 14 : 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (context.isMobile) ? context.dp(10) : 12,
            vertical: (context.isMobile) ? context.dp(20) : 36,
          ),
          child: CustomTextFormField(
            enabled: true,
            controller: widget.nomorHandphoneTextController,
            onFieldSubmitted: (nomorHandphone) {
              logger.log('Login Form Widget Nomor Handphone: '
                  '${_authOtpProvider.nomorHp} | $nomorHandphone');
            },
            keyboardType: TextInputType.phone,
            prefixText: '+62',
            hintText: 'Masukkan nomor handphone',
            inputFormatters: [LengthLimitingTextInputFormatter(13)],
            validator: (phoneNumber) =>
                FormValidator.validatePhoneNumber(phoneNumber, false),
          ),
        ),
        const RadioGroupOtpWidget(),
      ];
}
