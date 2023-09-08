import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user_info_widget.dart';
import '../../../auth/model/user_model.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../pembayaran/presentation/widget/appbar/info_pembayaran_widget.dart';
import '../../../kehadiran/presentation/widget/appbar/kehadiran_minggu_ini_widget.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/kreasi_shared_pref.dart';
// import '../../../../core/helper/kreasi_secure_storage.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';

class UserInfoAppBar extends StatefulWidget {
  final UserModel? userData;

  const UserInfoAppBar({Key? key, this.userData}) : super(key: key);

  @override
  State<UserInfoAppBar> createState() => _UserInfoAppBarState();
}

class _UserInfoAppBarState extends State<UserInfoAppBar> {
  @override
  Widget build(BuildContext context) {
    return _generateAppBar(context);
  }

  void _onClickPilihSekolahKelas() {
    final navigator = Navigator.of(context);
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
          maxChildSize: 0.9,
          builder: (context, controller) {
            AuthOtpProvider auth = context.read<AuthOtpProvider>();
            childWidget ??= SingleChildScrollView(
              controller: controller,
              child: Container(
                padding: EdgeInsets.only(
                  right: context.dp(18),
                  left: context.dp(18),
                  top: context.dp(24),
                  bottom: context.dp(24),
                ),
                decoration: BoxDecoration(
                  color: context.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ValueListenableBuilder<String?>(
                  valueListenable: auth.idSekolahKelas,
                  builder: (context, idSekolahKelas, _) {
                    return Wrap(
                      children: Constant.kDataSekolahKelas
                          .map<Widget>(
                            (kelas) => _buildOptionKelas(
                              context,
                              // TODO: Saat ganti kelas, ganti juga konten Teaser dengan kelas sesuai pilihan.
                              () async {
                                await KreasiSharedPref().setPilihanKelas(kelas);
                                auth.idSekolahKelas.value = kelas['id']!;
                                navigator.pop();
                              },
                              kelas['kelas']!,
                              kelas['id']! == idSekolahKelas,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            );
            return childWidget!;
          },
        ),
      ),
    );
  }

  /// NOTE: Tempat menyimpan widget method pada class ini------------------------
  // Build App Bar
  Widget _generateAppBar(BuildContext context) {
    if (widget.userData.isLogin) {
      var backgroundUrl = 'header_sma.webp'.imgUrl;
      bool isOther = widget.userData?.tingkat == 'Other';

      switch (widget.userData?.tingkat) {
        case 'SD':
          backgroundUrl = 'header_sd.webp'.imgUrl;
          break;
        case 'SMP':
          backgroundUrl = 'header_smp.webp'.imgUrl;
          break;
        default:
          break;
      }

      return Stack(
        fit: StackFit.loose,
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: (context.isMobile)
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              end: (context.isMobile)
                  ? Alignment.bottomCenter
                  : Alignment.centerRight,
              colors: (context.isMobile)
                  ? [
                      Colors.black,
                      Colors.black87,
                      Colors.black12,
                      Colors.black26
                    ]
                  : [Colors.black12, Colors.black87],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height)),
            blendMode: BlendMode.dstIn,
            child: isOther
                ? ClipRRect(
                    borderRadius: (context.isMobile)
                        ? BorderRadius.vertical(
                            bottom: Radius.circular(context.dp(32)))
                        : BorderRadius.zero,
                    child: Image.asset(
                      'assets/img/header_default.png',
                      fit: BoxFit.cover,
                      height: double.infinity,
                      alignment: Alignment.centerRight,
                    ),
                  )
                : CustomImageNetwork.rounded(
                    backgroundUrl,
                    key: ValueKey('header_sma.webp'.imgUrl),
                    height: double.infinity,
                    alignment: Alignment.centerRight,
                    borderRadius: (context.isMobile)
                        ? BorderRadius.vertical(
                            bottom: Radius.circular(context.dp(32)))
                        : null,
                  ),
          ),
          _buildAppBar(context),
        ],
      );
    }
    return _buildAppBar(context);
  }

  Widget _buildAppBar(BuildContext context) => Padding(
        padding: (context.isMobile)
            ? EdgeInsets.only(
                right: context.dp(8),
                left: context.dp(24),
                top: context.dp(20) + context.statusBarHeight,
                bottom: context.dp(8),
              )
            : EdgeInsets.only(
                top: 26 + context.statusBarHeight,
              ),
        child: Column(
          children: [
            UserInfoWidget(userData: widget.userData),
            if (!widget.userData.isLogin)
              _buildPilihKelasDanAuthButton(context),
            const Spacer(),
            if (widget.userData != null &&
                widget.userData.isLogin &&
                !widget.userData.isTamu)
              _buildKehadiranPembayaran(),
            const Spacer(),
          ],
        ),
      );

  Widget _buildKehadiranPembayaran() => (context.isMobile)
      ? Row(children: [
          KehadiranMingguIniWidget(userData: widget.userData!),
          InfoPembayaranWidget(userData: widget.userData!),
        ])
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: context.outline)),
              child: KehadiranMingguIniWidget(userData: widget.userData!),
            ),
            Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: context.outline)),
              child: InfoPembayaranWidget(userData: widget.userData!),
            ),
          ],
        );

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

  Widget _buildPilihKelasDanAuthButton(BuildContext context) {
    AuthOtpProvider auth = context.read<AuthOtpProvider>();

    List<Widget> children = [
      TextButton(
          onPressed: () {
            if (kDebugMode) {
              logger.log('USER_INFO_APP_BAR: On Click Navigate to Auth Screen');
            }
            Navigator.pushNamed(
              context,
              Constant.kRouteAuthScreen,
              arguments: {'authMode': AuthMode.login},
            );
          },
          child: const Text('Daftar / Masuk')),
      (context.isMobile) ? const Spacer() : const SizedBox(height: 16),
      InkWell(
        onTap: _onClickPilihSekolahKelas,
        child: Container(
          padding: EdgeInsets.only(
            top: context.dp(4),
            bottom: context.dp(4),
            left: context.dp(8),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.dp(12)),
            border: Border.all(color: context.disableColor),
          ),
          child: ValueListenableBuilder<String?>(
            valueListenable: auth.idSekolahKelas,
            builder: (context, idSekolahKelas, iconDropDown) => Row(
              children: [
                FittedBox(
                  child: Text(
                      Constant.kDataSekolahKelas.singleWhere((kelas) =>
                              kelas['id'] == idSekolahKelas)['kelas'] ??
                          'N/A',
                      style: context.text.bodySmall),
                ),
                if (!context.isMobile) const Spacer(),
                iconDropDown!
              ],
            ),
            child: const Icon(Icons.arrow_drop_down_rounded),
          ),
        ),
      ),
      (context.isMobile)
          ? SizedBox(width: context.dp(16))
          : const SizedBox(height: 24),
    ];

    return (context.isMobile)
        ? Row(children: children)
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: children.reversed.toList(),
          );
  }
}
