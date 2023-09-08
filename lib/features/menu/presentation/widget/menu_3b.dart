import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/widget/animation/custom_rect_tween.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../entity/menu.dart';
import '../provider/menu_provider.dart';

class Menu3B extends StatefulWidget {
  const Menu3B({Key? key, required this.heroTag}) : super(key: key);

  final String heroTag;

  @override
  State<Menu3B> createState() => _Menu3BState();
}

class _Menu3BState extends State<Menu3B> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  late bool _isLogin;
  late bool _isSiswa;

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    Future.delayed(const Duration(milliseconds: 340))
        .then((value) => _animController.forward());
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data isLogin dari Auth Provider.
    _isLogin = context.select<AuthOtpProvider, bool>((auth) => auth.isLogin);
    _isSiswa = context.select<AuthOtpProvider, bool>((auth) => auth.isSiswa);
    return _buildBody(context);
  }

  void _navigateTo(
      {required String label,
      required int idJenisProduk,
      required String namaJenisProduk}) {
    if (label == 'Soal') {
      Navigator.pushNamed(context, Constant.kRouteBukuSoalScreen);
      return;
    }
    if (label == 'Teori') {
      Navigator.pushNamed(context, Constant.kRouteBukuTeoriScreen);
      return;
    }
    if (label == 'TOBK') {
      Navigator.pushNamed(context, Constant.kRouteTobkScreen, arguments: {
        'idJenisProduk': idJenisProduk,
        'namaJenisProduk': namaJenisProduk
      });
      return;
    }
    if (_isLogin) {
      switch (label) {
        case 'Rencana':
          if (_isSiswa) {
            Navigator.pushNamed(context, Constant.kRouteRencanaBelajar);
            return;
          }
          break;
        case 'Laporan':
          Navigator.pushNamed(context, Constant.kRouteLaporan);
          return;
        case 'Jadwal':
          Navigator.pushNamed(context, Constant.kRouteJadwal);
          return;
        case 'SNBT':
          Navigator.pushNamed(context, Constant.kRouteSNBT);
          return;
        case 'Profiling':
          if (_isSiswa) {
            Navigator.pushNamed(context, Constant.kRouteProfilingScreen);
            return;
          }
          break;
        default:
          // Default di atur agar menuju ke 404 Screen.
          Navigator.pushNamed(context, '/$label');
          return;
      }
    }
    // Navigate ke story board saat tidak login.
    Navigator.pushNamed(
      context,
      Constant.kRouteStoryBoardScreen,
      arguments: Constant.kStoryBoard[label]!,
    );
  }

  Align _buildBody(BuildContext context) {
    return Align(
      alignment:
          (context.isMobile) ? Alignment.bottomCenter : Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(
          right: (context.isMobile) ? 0 : 28,
          bottom: (context.isMobile) ? context.dp(78) : 20,
        ),
        child: Hero(
          tag: widget.heroTag,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin, end: end),
          child: Material(
            elevation: 4,
            color: Palette.kSecondarySwatch[400],
            borderRadius: BorderRadius.circular((context.isMobile) ? 32 : 64),
            child: ResponsiveBuilder(
              mobile: _buildMenu3B(
                context,
                BoxConstraints(
                  minWidth: 100,
                  minHeight: 100,
                  maxHeight: context.dh * 0.5,
                  maxWidth: context.dw,
                ),
              ),
              tablet: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 100,
                  minHeight: 100,
                  maxWidth: 650,
                  maxHeight: 460,
                ),
                child: LayoutBuilder(
                  builder: (context, constraint) =>
                      _buildMenu3B(context, constraint),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildMenu3B(
      BuildContext context, BoxConstraints constraint) {
    double maxWidth = (constraint.maxWidth != double.infinity)
        ? constraint.maxWidth
        : (context.isMobile)
            ? context.dw
            : context.dh;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        (context.isMobile) ? context.dp(20) : context.dp(12),
      ),
      child: AnimatedBuilder(
        animation: _animController.view,
        builder: (_, child) =>
            Opacity(opacity: _animController.value, child: child),
        child: Wrap(
          clipBehavior: Clip.hardEdge,
          spacing: (context.isMobile) ? context.dp(12) : context.dp(6),
          runSpacing: (context.isMobile) ? context.dp(8) : context.dp(4),
          children: [
            _buildMenuTitle(
              context,
              'belajar',
              maxWidth - context.dp(48),
            ),
            _buildSubMenu(
              context,
              MenuProvider.listMenuBelajar,
              (maxWidth - context.dp(85)) / 4,
              maxWidth - context.dp(48),
            ),
            _buildMenuTitle(
              context,
              'berlatih',
              (maxWidth - context.dp(54)) / 2,
            ),
            _buildMenuTitle(
              context,
              'bertanding',
              (maxWidth - context.dp(54)) / 2,
            ),
            _buildSubMenu(
              context,
              MenuProvider.listMenuBerlatih,
              (maxWidth - context.dp(85)) / 4,
              (maxWidth - context.dp(54)) / 2,
            ),
            _buildSubMenu(
              context,
              MenuProvider.listMenuBertanding,
              (maxWidth - context.dp(85)) / 4,
              (maxWidth - context.dp(54)) / 2,
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildMenuTitle] merupakan function untuk menampilkan title dari pengelompokan menu 3B.
  Widget _buildMenuTitle(BuildContext context, String menu, double width) =>
      FittedBox(
        fit: BoxFit.fitWidth,
        child: Image.asset(
          'assets/img/txt_$menu.webp',
          width: width,
          height: (context.isMobile) ? context.dp(20) : context.dp(9),
          alignment: Alignment.centerLeft,
        ),
      );

  /// [_buildSubMenu] merupakan function untuk menampilkan subMenu dari masing-masing kelompokan menu 3B.
  Widget _buildSubMenu(BuildContext context, List<Menu> subMenus,
          double subMenuWidth, double containerWidth) =>
      FittedBox(
        fit: BoxFit.fitWidth,
        child: Container(
          width: containerWidth,
          padding: EdgeInsets.symmetric(
            vertical: (context.isMobile) ? context.dp(10) : context.dp(6),
            horizontal: (subMenus.length == 2)
                ? context.dp(6)
                : (context.isMobile)
                    ? context.dp(12)
                    : context.dp(8),
          ),
          decoration: BoxDecoration(
            color: context.surface.withOpacity(0.54),
            borderRadius: BorderRadius.circular((context.isMobile) ? 12 : 32),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: subMenus
                  .map<Widget>(
                    (subMenu) => GestureDetector(
                      onTap: () => _navigateTo(
                          label: subMenu.label,
                          idJenisProduk: subMenu.idJenis,
                          namaJenisProduk: subMenu.namaJenisProduk),
                      child: Image.asset(
                        subMenu.iconPath!,
                        width: subMenuWidth,
                        height: subMenuWidth,
                      ),
                    ),
                  )
                  .toList()),
        ),
      );
}
