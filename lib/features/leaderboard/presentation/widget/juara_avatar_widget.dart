import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/image/profile_picture_widget.dart';

class JuaraAvatarWidget extends StatelessWidget {
  final String noRegistrasi;
  final String namaSiswa;
  final bool isPiala;
  final bool isMedali;
  final int ranking;
  final double? width;

  const JuaraAvatarWidget({
    Key? key,
    required this.noRegistrasi,
    required this.namaSiswa,
    this.width,
    this.isPiala = false,
    this.isMedali = false,
    required this.ranking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = ProfilePictureWidget.leaderboard(
      key: ValueKey('PHOTO_PROFILE_LEADERBOARD-$noRegistrasi-$namaSiswa'),
      width: width,
      noRegistrasi: noRegistrasi,
      // userType: 'SISWA',
      name: namaSiswa,
    );

    double medalIconSize = context.dp((ranking == 1) ? 48 : 32);

    if (!context.isMobile) {
      medalIconSize = context.dp((ranking == 1) ? 32 : 24);
    }

    if (isPiala || isMedali) {
      return SizedBox(
        width: width,
        height: width,
        child: Stack(
          children: [
            avatar,
            Align(
              alignment:
                  (ranking == 2) ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Transform.translate(
                offset: Offset(
                  (ranking == 3)
                      ? context.dp(-4)
                      : (ranking == 1)
                          ? context.dp(4)
                          : 0,
                  context.dp((ranking == 1)
                      ? -2
                      : 4),
                ),
                child: CachedNetworkImage(
                  width: medalIconSize,
                  height: medalIconSize,
                  imageUrl: (isPiala)
                      ? 'juara_piala.webp'.icon
                      : 'juara_medali.webp'.icon,
                  progressIndicatorBuilder: (_, __, progress) =>
                      ShimmerWidget.rectangle(
                          width: medalIconSize, height: medalIconSize),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return avatar;
  }
}
