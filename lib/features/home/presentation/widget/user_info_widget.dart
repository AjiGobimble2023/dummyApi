import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/model/user_model.dart';
import '../../../profile/presentation/widget/user_avatar.dart';
// import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../notifikasi/presentation/provider/notifikasi_provider.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';

class UserInfoWidget extends StatefulWidget {
  final UserModel? userData;

  const UserInfoWidget({Key? key, this.userData}) : super(key: key);

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  /// [authProvider] merupakan variabel provider untuk memanggil data login user
  // late final AuthOtpProvider authProvider = context.read<AuthOtpProvider>();

  /// variable untuk menampung data no registrasi user
  String? userId;
  bool isLogin = false;

  @override
  void initState() {
    isLogin = widget.userData.isLogin;
    if (isLogin) {
      userId = widget.userData!.noRegistrasi;
      _loadNotification(userId!);
    }
    super.initState();
  }

  Future<void> _loadNotification(String userId) async {
    await Future.delayed(Duration.zero, () async {
      context.read<NotificationProvider>().loadNotification(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLogin)
          ? () {
              Navigator.pushNamed(context, Constant.kRouteProfileScreen);
            }
          : null,
      child: Consumer<NotificationProvider>(
        builder: (ctxNotif, value, child) => Row(
          children: [
            UserAvatar(
              userData: widget.userData,
              size: (context.isMobile) ? 64 : 32,
              padding: 4,
            ),
            SizedBox(width: min(12, context.dp(8))),
            _buildNamaLengkap(context, widget.userData),
            Selector<NotificationProvider, int>(
              selector: (_, notif) => notif.notificationCount,
              builder: (context, notifCount, _) => ElevatedButton(
                onPressed: () => (isLogin)
                    ? Navigator.pushNamed(
                        context,
                        Constant.kRouteNotifikasi,
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: context.background,
                    fixedSize:
                        Size(min(52, context.dp(32)), min(52, context.dp(32))),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: notifCount == 0
                    ? _buildNotificationIcon(context)
                    : Stack(
                        children: <Widget>[
                          _buildNotificationIcon(context),
                          if (isLogin) _buildNotificationBadge(notifCount)
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _buildNotificationBadge(int notifCount) {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(
          minWidth: 14,
          minHeight: 14,
        ),
        child: Text(
          '$notifCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Image _buildNotificationIcon(BuildContext context) {
    return Image.asset(
      'assets/icon/ic_notification.webp',
      width: min(38, context.dp(24)),
      fit: BoxFit.fitWidth,
    );
  }

  Expanded _buildNamaLengkap(BuildContext context, UserModel? userData) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'Nama-Lengkap-User',
            key: const Key('Nama-Lengkap-User'),
            transitionOnUserGestures: true,
            child: RichText(
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: context.textScale14,
              text: TextSpan(
                text:
                    'Halo${(userData == null) ? '' : (userData.siapa.equalsIgnoreCase('ORTU') ? 'Bpk/Ibu dari' : '')},\n',
                children: [
                  TextSpan(
                    text: userData?.namaLengkap ?? 'Sobat GO',
                    style: context.text.titleMedium?.copyWith(
                      fontSize: (context.isMobile) ? 18 : 12,
                      height: 1.0556,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                style: context.text.titleSmall?.copyWith(
                  fontSize: (context.isMobile) ? 14 : 10,
                  height: 1.07,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Hero(
            tag: 'No-Registrasi-User',
            transitionOnUserGestures: true,
            key: const Key('No-Registrasi-User'),
            child: Text(
              (userData != null)
                  ? '${userData.noRegistrasi} (${userData.siapa.toUpperCase()})'
                  : 'Cobain fitur gratis di GO yuk',
              style: context.text.bodyMedium?.copyWith(
                fontSize: (context.isMobile) ? 14 : 10,
                color: context.hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
