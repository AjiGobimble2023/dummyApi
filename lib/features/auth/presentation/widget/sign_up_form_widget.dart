import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';

import 'radio_group_otp_widget.dart';
import '../provider/auth_otp_provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/form_validator.dart';
import '../../../../core/helper/kreasi_shared_pref.dart';
// import '../../../../core/helper/kreasi_secure_storage.dart';
import '../../../../core/shared/widget/form/custom_text_form_field.dart';

class SignUpFormWidget extends StatefulWidget {
  final ValueNotifier<AuthRole> pilihanRoleController;
  final TextEditingController nomorHandphoneController;
  final TextEditingController noRegistrasiController;
  final TextEditingController namaLengkapController;
  final TextEditingController emailController;
  final TextEditingController tanggalLahirController;

  const SignUpFormWidget({
    Key? key,
    required this.pilihanRoleController,
    required this.nomorHandphoneController,
    required this.noRegistrasiController,
    required this.namaLengkapController,
    required this.emailController,
    required this.tanggalLahirController,
  }) : super(key: key);

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  late final NavigatorState _navigator = Navigator.of(context);

  // String? _validateMessagePhoneNumber,
  //     _validateMessageID,
  //     _validateMessageName,
  //     _validateMessageEmail;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthOtpProvider>(
      child: Container(
        width: double.infinity,
        color: context.background,
        alignment: Alignment.topCenter,
        margin: (context.isMobile)
            ? EdgeInsets.only(top: context.dp(24), bottom: context.dp(20))
            : EdgeInsets.only(
                top: (context.dh > 750) ? context.h(100) : 20, bottom: 26),
        child: Text(
          'Daftar GO Yuk',
          style: context.text.headlineLarge?.copyWith(
            fontSize: (context.isMobile) ? 32 : 28,
            color: context.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      builder: (_, authOtp, header) => (context.isMobile)
          ? ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: _buildForm(authOtp, header),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildForm(authOtp, header),
            ),
    );
  }

  List<Widget> _buildForm(AuthOtpProvider authOtp, Widget? header) => [
        header!,
        _buildDaftarSebagai(),
        _buildPilihKelas(),
        _buildNoRegistrasiField(authOtp),
        _buildNamaLengkapField(authOtp),
        _buildEmailField(authOtp),
        _buildPhoneNumberField(authOtp),
        _buildTanggalLahirField(authOtp),
        SizedBox(height: context.dp(20)),
        const RadioGroupOtpWidget()
      ];

  GestureDetector _buildDaftarSebagai() {
    return GestureDetector(
      onTap: () => showAdaptiveActionSheet(
        context: context,
        title: Text('Daftar Sebagai', style: context.text.headlineSmall),
        androidBorderRadius: (context.isMobile) ? 24 : 32,
        actions: AuthRole.values
            .map<BottomSheetAction>(
              (role) => BottomSheetAction(
                  title: Text(role.name.capitalize(),
                      style: context.text.bodyLarge),
                  onPressed: (_) {
                    widget.pilihanRoleController.value = role;
                    Navigator.pop(context);
                  }),
            )
            .toList(),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.dp(10),
        ),
        padding: (context.isMobile)
            ? EdgeInsets.all(context.dp(12))
            : EdgeInsets.all(context.dp(8)),
        decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(context.dp(10)),
            border: Border.all(color: context.hintColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Sebagai',
              style: context.text.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            ValueListenableBuilder<AuthRole>(
              valueListenable: widget.pilihanRoleController,
              builder: (context, pilihanRole, _) => Text(
                AuthRole.values
                    .singleWhere((role) => role == pilihanRole)
                    .name
                    .capitalize(),
                style: context.text.labelLarge
                    ?.copyWith(color: context.disableColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionKelas(BuildContext context, VoidCallback onClick,
          String label, bool isActive) =>
      InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(max(8, context.dp(8))),
        child: Container(
          margin: EdgeInsets.all((context.isMobile) ? context.dp(6) : 8),
          padding: EdgeInsets.symmetric(
            vertical: (context.isMobile) ? context.dp(10) : context.dp(6),
            horizontal: (context.isMobile) ? context.dp(12) : context.dp(8),
          ),
          decoration: BoxDecoration(
              color: isActive ? context.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(max(8, context.dp(8))),
              border: Border.all(
                  color: isActive ? Colors.transparent : context.onBackground)),
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              fontSize: (context.isMobile) ? 12 : 10,
              color: isActive ? context.onPrimary : context.onBackground,
            ),
          ),
        ),
      );

  Future<void> _pilihKelasBottomSheet() async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 1,
          builder: (context, controller) {
            AuthOtpProvider auth = context.read<AuthOtpProvider>();
            childWidget ??= SingleChildScrollView(
              controller: controller,
              child: Container(
                padding: EdgeInsets.only(
                  right: context.dp(18),
                  left: context.dp(18),
                  top: context.dp(18),
                  bottom: context.dp(24),
                ),
                decoration: BoxDecoration(
                  color: context.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pilih Kelas', style: context.text.headlineSmall),
                    SizedBox(height: context.dp(10)),
                    ValueListenableBuilder<String?>(
                      valueListenable: auth.idSekolahKelas,
                      builder: (context, idSekolahKelas, _) {
                        return Wrap(
                          children: Constant.kDataSekolahKelas
                              .map<Widget>(
                                (kelas) => _buildOptionKelas(
                                  context,
                                  () async {
                                    await KreasiSharedPref()
                                        .setPilihanKelas(kelas);
                                    auth.idSekolahKelas.value = kelas['id']!;
                                    _navigator.pop();
                                  },
                                  kelas['kelas']!,
                                  kelas['id']! == idSekolahKelas,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );

            return childWidget!;
          },
        ),
      ),
    );
  }

  Widget _buildPilihKelas() {
    return ValueListenableBuilder<AuthRole>(
      valueListenable: widget.pilihanRoleController,
      builder: (context, pilihanRole, child) => Visibility(
        visible: pilihanRole == AuthRole.tamu,
        replacement: const SizedBox(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _pilihKelasBottomSheet(),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: context.dp(10),
                  vertical: min(22, context.dp(12)),
                ),
                padding: (context.isMobile)
                    ? EdgeInsets.all(context.dp(12))
                    : EdgeInsets.all(context.dp(8)),
                decoration: BoxDecoration(
                    color: context.background,
                    borderRadius: BorderRadius.circular(context.dp(10)),
                    border: Border.all(color: context.hintColor)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Kelas',
                      style: context.text.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable:
                          context.read<AuthOtpProvider>().idSekolahKelas,
                      builder: (context, idSekolahKelas, _) => Text(
                        Constant.kDataSekolahKelas.singleWhere((element) =>
                            element['id'] == idSekolahKelas)['kelas']!,
                        style: context.text.labelLarge
                            ?.copyWith(color: context.disableColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRegistrasiField(AuthOtpProvider authOtp) {
    return ValueListenableBuilder<AuthRole>(
      valueListenable: widget.pilihanRoleController,
      builder: (context, pilihanRole, _) => Visibility(
        visible: pilihanRole != AuthRole.tamu,
        replacement: const SizedBox(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dp(10),
            vertical: min(22, context.dp(12)),
          ),
          child: CustomTextFormField(
            controller: widget.noRegistrasiController,
            onChanged: (value) {
              if (kDebugMode) {
                logger.log('SIGN_UP_FORM_WIDGET-NO_REGISTRASI_TEXTFIELD: '
                    'onChange >> ${widget.noRegistrasiController.text} = $value');
              }
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.power_input_rounded),
            hintText: authOtp.authRole == AuthRole.ortu
                ? 'Masukkan No Registrasi putra/putri anda'
                : 'Masukkan No Registrasi kamu',
            validator: (noRegistrasi) => FormValidator.validateId(
                noRegistrasi, pilihanRole == AuthRole.ortu),
          ),
        ),
      ),
    );
  }

  Widget _buildNamaLengkapField(AuthOtpProvider authOtp) {
    return ValueListenableBuilder<AuthRole>(
      valueListenable: widget.pilihanRoleController,
      builder: (context, pilihanRole, _) => Visibility(
        visible: pilihanRole == AuthRole.tamu,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dp(10),
          ),
          child: CustomTextFormField(
            controller: widget.namaLengkapController,
            onChanged: (value) {
              if (kDebugMode) {
                logger.log('SIGN_UP_FORM_WIDGET-NAMA_LENGKAP_TEXTFIELD: '
                    'onChange >>  ${widget.namaLengkapController.text} = $value');
              }
            },
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.perm_identity_rounded),
            hintText: 'Masukkan nama lengkap',
            validator: (namaLengkap) =>
                FormValidator.validateNamaSiswa(namaLengkap),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(AuthOtpProvider authOtp) {
    return ValueListenableBuilder<AuthRole>(
      valueListenable: widget.pilihanRoleController,
      builder: (context, pilihanRole, _) => Visibility(
        visible: pilihanRole == AuthRole.tamu,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dp(10),
            vertical: min(22, context.dp(12)),
          ),
          child: CustomTextFormField(
            controller: widget.emailController,
            onChanged: (value) {
              if (kDebugMode) {
                logger.log('SIGN_UP_FORM_WIDGET-EMAIL_TEXTFIELD: '
                    'onChange >> ${widget.emailController.text} = $value');
              }
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
            hintText: 'Masukkan email',
            validator: (email) => FormValidator.validateEmail(email),
          ),
        ),
      ),
    );
  }

  Padding _buildPhoneNumberField(AuthOtpProvider authOtp) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dp(10),
      ),
      child: ValueListenableBuilder<AuthRole>(
        valueListenable: widget.pilihanRoleController,
        builder: (context, pilihanRole, _) => CustomTextFormField(
          controller: widget.nomorHandphoneController,
          onChanged: (value) {
            authOtp.nomorHp = value;
            if (kDebugMode) {
              logger.log('SIGN_UP_FORM_WIDGET-NO_HP_TEXTFIELD: '
                  'onChange >> ${authOtp.nomorHp} = $value\n'
                  'Controller >> ${widget.nomorHandphoneController.text}');
            }
          },
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          prefixText: '+62',
          hintText: 'Masukkan nomor handphone',
          inputFormatters: [LengthLimitingTextInputFormatter(13)],
          validator: (nomorHp) => FormValidator.validatePhoneNumber(
            nomorHp,
            pilihanRole == AuthRole.ortu,
          ),
        ),
      ),
    );
  }

  Widget _buildTanggalLahirField(AuthOtpProvider authOtp) {
    return ValueListenableBuilder<AuthRole>(
      valueListenable: widget.pilihanRoleController,
      builder: (context, pilihanRole, _) => Visibility(
        visible: pilihanRole == AuthRole.tamu,
        child: Padding(
          padding: EdgeInsets.only(
            left: context.dp(10),
            right: context.dp(10),
            top: min(22, context.dp(12)),
          ),
          child: CustomTextFormField(
            readOnly: true,
            controller: widget.tanggalLahirController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.event_rounded),
            hintText: 'Masukkan tanggal lahir',
            onTap: () async {
              int? year, month, day;
              String tanggalLahir = widget.tanggalLahirController.text;

              if (tanggalLahir.isNotEmpty) {
                List<String> ttl = tanggalLahir.split('-');
                year = int.parse(ttl[0]);
                month = int.parse(ttl[1]);
                day = int.parse(ttl[2]);
              }
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(year ?? 2000, month ?? 1, day ?? 1),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                if (kDebugMode) {
                  // pickedDate output format => 2021-03-10 00:00:00.000
                  logger.log(
                      'SIGN_UP_FORM_WIDGET-DatePiker-Tanggal-Lahir: Picked date >> $pickedDate');
                }

                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                String formattedDateDisplay =
                    DateFormat('dd MMM yyyy', 'ID').format(pickedDate);

                widget.tanggalLahirController.text = formattedDateDisplay;
                if (kDebugMode) {
                  // formatted date output using intl package =>  2021-03-16
                  logger.log(
                      'SIGN_UP_FORM_WIDGET-DatePiker-Tanggal-Lahir: Formatted date >> $formattedDate');
                }
              } else {
                if (!mounted) return;
                gShowTopFlash(context, 'Gagal mengambil tanggal. Coba ulangi!');
              }
            },
          ),
        ),
      ),
    );
  }
}
