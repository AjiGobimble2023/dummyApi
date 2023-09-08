import 'package:flutter/material.dart';

import '../../../../../core/config/extensions.dart';
import '../../../../leaderboard/presentation/widget/juara_avatar_widget.dart';
import '../../friends/model/friends.dart';

class BigThreeFriendsWidget extends StatelessWidget {
  final List<Friends> topThreeFriends;

  const BigThreeFriendsWidget({Key? key, required this.topThreeFriends})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBigThreeItemWidget(context, topThreeFriends[1], 2),
        SizedBox(width: context.dp(8)),
        _buildBigThreeItemWidget(context, topThreeFriends[0], 1),
        SizedBox(width: context.dp(8)),
        _buildBigThreeItemWidget(context, topThreeFriends[2], 3),
      ],
    );
  }

  SizedBox _buildBigThreeItemWidget(
      BuildContext context, Friends juara, int rank) {
    return SizedBox(
      width: context.isMobile
          ? context.dw -
              (rank == 1
                  ? context.dp(262)
                  : rank == 2
                      ? context.dp(294)
                      : context.dp(312))
          : context.dw -
              (rank == 1
                  ? context.dp(320)
                  : rank == 2
                      ? context.dp(350)
                      : context.dp(350)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JuaraAvatarWidget(
            width: context.isMobile
                ? context.dw -
                    (rank == 1
                        ? context.dp(262)
                        : rank == 2
                            ? context.dp(294)
                            : context.dp(312))
                : context.dw -
                    (rank == 1
                        ? context.dp(320)
                        : rank == 2
                            ? context.dp(340)
                            : context.dp(340)),
            isPiala: rank == 1,
            isMedali: true,
            noRegistrasi: juara.friendId,
            namaSiswa: juara.fullName,
            ranking: rank,
          ),
          SizedBox(height: context.dp(6)),
          Text(
            juara.fullName,
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
