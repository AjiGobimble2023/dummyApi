import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/user_avatar.dart';
import '../widget/profile_widget.dart';
import '../widget/profile_menu_widget.dart';
import '../../entity/scanner_type.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AuthOtpProvider _authOtpProvider =
      context.watch<AuthOtpProvider>();

  @override
  void dispose() {
    if (HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      HiveHelper.closeBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    super.dispose();
  }

  Future<bool> _openSettingBox() async {
    if (!HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      await HiveHelper.openBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    return HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: Column(
            children: [
              _buildHeaderMenu(),
              _buildProfileHeader(),
              const ProfileWidget(),
            ],
          ),
          tablet: ProfileWidget(
            headerMenu: _buildHeaderMenu(),
            profileHeader: _buildProfileHeader(),
          ),
        ),
      ),
    );
  }

  void _onClickUbahProfil() {
    Navigator.pushNamed(
      context,
      Constant.kRouteEditProfileScreen,
    );
  }

  void _showProfileMenuBottomSheet() {
    showModalBottomSheet(
      context: context,
      elevation: 4,
      isDismissible: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      backgroundColor: context.background,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ProfileMenuWidget(),
    );
  }

  Padding _buildHeaderMenu() => Padding(
        padding: EdgeInsets.only(
          top: min(24, context.dp(20)),
          bottom: min(16, context.dp(12)),
          right: min(24, context.dp(20)),
          left: min(24, context.dp(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(300),
                child: const Icon(Icons.chevron_left_rounded, size: 32)),
            Image.asset('assets/img/logo.webp',
                height: min(52, context.dp(48)), fit: BoxFit.fitHeight),
            FutureBuilder(
              future: _openSettingBox(),
              builder: (context, snapshot) =>
                  (snapshot.connectionState == ConnectionState.waiting)
                      ? ShimmerWidget.rounded(
                          width: 32,
                          height: 32,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : InkWell(
                          onTap: _showProfileMenuBottomSheet,
                          borderRadius: BorderRadius.circular(12),
                          child: const Icon(Icons.menu_rounded, size: 32)),
            ),
          ],
        ),
      );

  Row _buildProfileHeader() => Row(
        children: [
          SizedBox(width: min(24, context.dp(20))),
          UserAvatar(
            userData: _authOtpProvider.userData,
            size: (context.isMobile) ? 96 : 38,
            padding: 4,
          ),
          SizedBox(width: min(14, context.dp(12))),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'Nama-Lengkap-User',
                  key: const Key('Nama-Lengkap-User'),
                  transitionOnUserGestures: true,
                  child: Text(
                      _authOtpProvider.userData?.namaLengkap ?? 'Sobat GO',
                      style: context.text.titleMedium
                          ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      textScaleFactor: context.textScale12,
                      overflow: TextOverflow.ellipsis),
                ),
                Hero(
                  tag: 'No-Registrasi-User',
                  key: const Key('No-Registrasi-User'),
                  transitionOnUserGestures: true,
                  child: Text(
                      '${_authOtpProvider.userData?.noRegistrasi} (${_authOtpProvider.userData?.siapa.toUpperCase()})',
                      style: context.text.bodyMedium
                          ?.copyWith(color: context.hintColor),
                      maxLines: 1,
                      textScaleFactor: context.textScale12,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(height: min(13, context.dp(9))),
                SizedBox(
                  height: min(context.dp(32), 38),
                  width: min(context.dp(110), 130),
                  child: ElevatedButton(
                    onPressed: () => _onClickUbahProfil(),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        textStyle: context.text.bodySmall?.copyWith(
                          color: context.onPrimaryContainer,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('Ubah Profil'),
                  ),
                ),
                SizedBox(width: min(24, context.dp(20))),
              ],
            ),
          ),
        ],
      );
}
