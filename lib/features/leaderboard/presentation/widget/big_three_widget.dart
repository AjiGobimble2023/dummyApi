import 'dart:math';

import 'package:flutter/material.dart';

import 'juara_avatar_widget.dart';
import '../../model/leaderboard_rank_model.dart';
import '../../../../core/config/extensions.dart';

class BigThreeWidget extends StatelessWidget {
  final List<LeaderboardRankModel> topThreeJuaraBukuSakti;

  const BigThreeWidget({Key? key, required this.topThreeJuaraBukuSakti})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (topThreeJuaraBukuSakti.length > 1)
          _buildBigThreeItemWidget(context, topThreeJuaraBukuSakti[1]),
        (topThreeJuaraBukuSakti.length > 1)
            ? SizedBox(
                width:
                    (context.isMobile || context.dw > 1100) ? context.dp(8) : 8)
            : const Spacer(),
        _buildBigThreeItemWidget(context, topThreeJuaraBukuSakti[0]),
        (topThreeJuaraBukuSakti.length > 2)
            ? SizedBox(
                width:
                    (context.isMobile || context.dw > 1100) ? context.dp(8) : 8)
            : const Spacer(),
        if (topThreeJuaraBukuSakti.length > 2)
          _buildBigThreeItemWidget(context, topThreeJuaraBukuSakti[2]),
      ],
    );
  }

  SizedBox _buildBigThreeItemWidget(
      BuildContext context, LeaderboardRankModel juara) {
    double deviceWidth = (context.isMobile) ? context.dw : context.dw * 0.6;
    double avatarWidth = (context.isMobile) ? context.dw : context.dw * 0.6;

    if (juara.isJuaraSatu) {
      avatarWidth = deviceWidth -
          ((context.isMobile)
              ? context.dp(262)
              : (context.dw > 1100)
                  ? context.dp(148)
                  : context.dp(152));
    } else if (juara.isJuaraDua) {
      avatarWidth = deviceWidth -
          ((context.isMobile)
              ? context.dp(294)
              : (context.dw > 1100)
                  ? context.dp(168)
                  : context.dp(172));
    } else {
      avatarWidth = deviceWidth -
          ((context.isMobile)
              ? context.dp(312)
              : (context.dw > 1100)
                  ? context.dp(186)
                  : context.dp(188));
    }

    return SizedBox(
      width: avatarWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JuaraAvatarWidget(
            width: avatarWidth,
            isPiala: juara.isJuaraSatu,
            isMedali: juara.isBigThree,
            noRegistrasi: juara.noRegistrasi,
            namaSiswa: juara.namaLengkap,
            ranking: juara.rank,
          ),
          SizedBox(height: min(10, context.dp(6))),
          Text(
            juara.namaLengkap,
            style: context.text.bodyLarge?.copyWith(color: context.onPrimary),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            juara.score,
            style: context.text.bodyMedium?.copyWith(
                color: context.onPrimary, fontWeight: FontWeight.w300),
          )
        ],
      ),
    );
  }
}
