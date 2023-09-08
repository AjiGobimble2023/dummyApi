import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'switch_account_list.dart';
import '../../../auth/model/user_model.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/image/profile_picture_widget.dart';

class UserAvatar extends StatelessWidget {
  /// [size] adalah ukuran panjang dan lebar dari UserAvatar.
  final double? size;

  /// [padding] jarak antara border dengan profile image.
  final int padding;
  final UserModel? userData;
  final Anak? anak;
  final bool fromSwitchAccount;
  final Color? borderColor;

  const UserAvatar({
    Key? key,
    this.userData,
    this.size,
    this.padding = 4,
    this.fromSwitchAccount = false,
    this.borderColor,
    this.anak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? radius = (size == null) ? null : (size! / 2).floorToDouble();
    double radiusIcon = ((((size ?? 64) / 4) + 2) / 2).floorToDouble();
    String userType = (anak != null)
        ? 'SISWA'
        : context.select<AuthOtpProvider, String>((auth) => auth.userType);

    bool isOrtu = (userData?.siapa ?? 'no user') == 'ORTU';

    return Hero(
      key: const Key('UserAvatarHero'),
      tag: 'UserAvatarHero',
      transitionOnUserGestures: true,
      child: isOrtu && !fromSwitchAccount
          ? GestureDetector(
              onTap: () => _onClickSwitchAccount(context),
              child: SizedBox(
                width: context.dp(size ?? 64),
                height: context.dp(size ?? 64),
                child: Stack(
                  children: [
                    _buildCircleAvatar(context, radius, userType),
                    _buildSwitchIcon(context, radiusIcon),
                  ],
                ),
              ),
            )
          : _buildCircleAvatar(context, radius, userType),
    );
  }

  void _onClickSwitchAccount(BuildContext context) {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    // Membuka bottom sheet switch account
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.9,
        maxWidth: (context.isMobile) ? context.dw : 650,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        childWidget ??= SwitchAccountList(
          daftarAnak: userData!.daftarAnak,
          noRegistrasiAktif: userData!.noRegistrasi,
        );

        return childWidget!;
      },
    );
  }

  Align _buildSwitchIcon(BuildContext context, double radiusIcon) {
    return Align(
      alignment: Alignment.bottomRight,
      child: CircleAvatar(
        radius: context.dp(radiusIcon),
        backgroundColor: context.secondaryColor,
        child: Icon(
          Icons.cached_rounded,
          size: min(26, context.dp((size ?? 64) / 4)),
          color: context.onSecondary,
        ),
      ),
    );
  }

  CircleAvatar _buildCircleAvatar(
      BuildContext context, double? radius, String userType) {
    return CircleAvatar(
      radius: context.dp(radius ?? 32),
      backgroundColor: borderColor ?? context.secondaryColor,
      child: ProfilePictureWidget.circle(
        key: ValueKey('PHOTO_PROFILE_CIRCLE-'
            '${userData?.noRegistrasi ?? anak?.noRegistrasi}-'
            '${userData?.namaLengkap ?? anak?.namaLengkap ?? 'GOmin'}'),
        name: userData?.namaLengkap ?? anak?.namaLengkap ?? 'GOmin',
        width: context.dp(size ?? 64) -
            min(12, context.dp(padding.roundToDouble())),
        noRegistrasi:
            userData?.noRegistrasi ?? anak?.noRegistrasi ?? 'CaptainGO',
        // userType: userData?.siapa ?? userType,
        isUserLogin: userData != null,
        photoUrl:
            (userData != null || anak != null) ? null : 'CaptainGO'.avatar,
      ),
    );
  }
}
