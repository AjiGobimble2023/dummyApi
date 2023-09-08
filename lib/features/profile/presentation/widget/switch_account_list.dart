import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'user_avatar.dart';
import '../../../auth/model/user_model.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/form_validator.dart';
import '../../../../core/shared/widget/form/custom_text_form_field.dart';

class SwitchAccountList extends StatefulWidget {
  final String noRegistrasiAktif;
  final List<Anak> daftarAnak;

  const SwitchAccountList({
    Key? key,
    required this.daftarAnak,
    required this.noRegistrasiAktif,
  }) : super(key: key);

  @override
  State<SwitchAccountList> createState() => _SwitchAccountListState();
}

class _SwitchAccountListState extends State<SwitchAccountList> {
  final _noRegistrasiTextController = TextEditingController();

  late final _authOtpProvider = context.read<AuthOtpProvider>();
  // final TextEditingController _textEditingController = TextEditingController();
  List<Anak> _daftarAnak = [];

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: context.textScale12),
      child: Selector<AuthOtpProvider, List<Anak>>(
        selector: (_, auth) => auth.userData?.daftarAnak ?? _daftarAnak,
        shouldRebuild: (prev, next) =>
            prev.length != next.length ||
            next.any(
              (nextAnak) => prev.any(
                (prevAnak) =>
                    (prevAnak.namaLengkap == nextAnak.namaLengkap &&
                        prevAnak.noRegistrasi != nextAnak.noRegistrasi) ||
                    (prevAnak.namaLengkap != nextAnak.namaLengkap &&
                        prevAnak.noRegistrasi == nextAnak.noRegistrasi),
              ),
            ),
        builder: (context, daftarAnak, formTambahAkun) {
          _daftarAnak = daftarAnak;
          return ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  min(24, context.dp(18)),
            ),
            itemCount: daftarAnak.length + 2,
            separatorBuilder: (_, index) => (index == 0)
                ? const SizedBox.shrink()
                : const Divider(indent: 64),
            itemBuilder: (_, index) {
              bool akunAktif = false;
              if (index > 0 && index <= daftarAnak.length) {
                akunAktif = (daftarAnak[index - 1].noRegistrasi ==
                    widget.noRegistrasiAktif);
                if (kDebugMode) {
                  logger.log(
                      'SWITCH_ACCOUNT_LIST: Akun ${(daftarAnak[index - 1].namaLengkap)}'
                      ' Aktif >> $akunAktif');
                }
              }
              return (index == 0)
                  ? Center(
                      child: Container(
                        width: min(84, context.dp(80)),
                        height: min(10, context.dp(8)),
                        margin: EdgeInsets.symmetric(
                            vertical: min(10, context.dp(8))),
                        decoration: BoxDecoration(
                            color: context.disableColor,
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    )
                  : (index > daftarAnak.length)
                      ? formTambahAkun!
                      : Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: min(16, context.dp(12))),
                          decoration: BoxDecoration(
                              color: (akunAktif)
                                  ? context.secondaryContainer
                                  : null,
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            onTap: (akunAktif)
                                ? null
                                : () => _onSwitchAkun(
                                    daftarAnak[index - 1].noRegistrasi),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: min(12, context.dp(8))),
                            title: Text(daftarAnak[index - 1].namaLengkap),
                            subtitle: Text(daftarAnak[index - 1].noRegistrasi),
                            leading: UserAvatar(
                                key: ValueKey(
                                    'SWITCH_USER_AVATAR-${daftarAnak[index - 1].noRegistrasi}'
                                    '-${daftarAnak[index - 1].namaLengkap}'),
                                anak: daftarAnak[index - 1],
                                size: (context.isMobile) ? 54 : 32,
                                borderColor: akunAktif
                                    ? context.secondaryContainer
                                    : context.hintColor,
                                fromSwitchAccount: true),
                          ),
                        );
            },
          );
        },
        child: ListTile(
          title: CustomTextFormField(
            controller: _noRegistrasiTextController,
            onFieldSubmitted: (noRegistrasi) => _onTambahAkun(noRegistrasi),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.power_input_rounded),
            hintText: 'Masukkan No Registrasi putra/putri anda',
            validator: (noRegistrasi) =>
                FormValidator.validateId(noRegistrasi, true),
          ),
          trailing: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _noRegistrasiTextController,
            builder: (context, noRegistrasi, _) => ElevatedButton(
              onPressed: (noRegistrasi.text.isEmpty || noRegistrasi.text.length < 11)
                  ? null
                  : () => _onTambahAkun(noRegistrasi.text),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                foregroundColor: Colors.white70,
                surfaceTintColor: Colors.transparent,
                backgroundColor: Palette.kSuccessSwatch[500],
              ),
              child: const Icon(Icons.add_circle_outline_rounded),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTambahAkun(String noRegistrasi) async {
    // Switch Account Anak
    bool isBerhasil = await _authOtpProvider.switchAccount(
      isTambahAkun: true,
      noRegistrasi: noRegistrasi,
    );

    if (isBerhasil) {
      // update list data
      logger.log(
          // ignore: use_build_context_synchronously
          'Daftar Anak Baru >> ${context.read<AuthOtpProvider>().userData!.daftarAnak}');
      setState(() =>
          _daftarAnak = context.read<AuthOtpProvider>().userData!.daftarAnak);
    }
  }

  Future<void> _onSwitchAkun(String noRegistrasi) async {
    // Switch Account Anak
    await _authOtpProvider.switchAccount(
      isTambahAkun: false,
      noRegistrasi: noRegistrasi,
    );
  }
}
