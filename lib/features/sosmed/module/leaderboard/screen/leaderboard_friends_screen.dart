import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/friends_leaderboard_big_three.dart';
import '../provider/leaderboard_friends_provider.dart';
import '../../friends/model/friends.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../core/shared/widget/image/profile_picture_widget.dart';

class LeaderboardFriends extends StatefulWidget {
  const LeaderboardFriends({super.key});

  @override
  State<LeaderboardFriends> createState() => _LeaderboardFriendsState();
}

class _LeaderboardFriendsState extends State<LeaderboardFriends> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await context
          .read<LeaderboardFriendsProvider>()
          .loadFriendLeaderboard(gNoRegistrasi);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardFriendsProvider>(builder: (context, value, _) {
      if (value.isLoading) {
        return const LoadingWidget();
      }

      if (value.currentListLeaderboard.isEmpty) {
        return _buildEmptyState(context);
      }

      return Container(
        width: (context.isMobile) ? context.dw : context.dw - context.dp(132),
        padding: EdgeInsets.symmetric(
          vertical: context.pd,
          horizontal: (context.isMobile) ? context.pd : context.pd * 2,
        ),
        child: Column(
          children: [
            (value.currentListLeaderboard.length > 3)
                ? BigThreeFriendsWidget(
                    topThreeFriends: value.currentListLeaderboard,
                  )
                : Expanded(
                    child: ListView(
                    children: [
                      for (int i = 0;
                          i < value.currentListLeaderboard.length;
                          i++)
                        ..._buildItemJuara(value.currentListLeaderboard, i)
                    ],
                  )),
            SizedBox(height: context.dp(12)),
            if (value.currentListLeaderboard.length > 3)
              Expanded(
                  child: ListView(
                children: [
                  for (int i = 0;
                      i < value.currentListLeaderboard.length - 3;
                      i++)
                    ..._buildItemJuara(value.currentListLeaderboard, i + 3)
                ],
              )),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    Widget emptyWidget = Padding(
      padding: EdgeInsets.only(bottom: min(90, context.dp(82))),
      child: NoDataFoundWidget(
        shrink: !context.isMobile,
        imageUrl: 'ilustrasi_sosial_leaderboard_not_found.png'.illustration,
        subTitle:
            'Sepertinya kamu belum memulai pertemanan dengan Sobat GO lainnya.',
        emptyMessage:
            'Yuk mulai tambahkan teman, agar kamu bisa tau peringkat kamu di antara teman-teman kamu.',
      ),
    );

    return (context.isMobile)
        ? emptyWidget
        : SingleChildScrollView(child: emptyWidget);
  }

  List<Widget> _buildItemJuara(List<Friends> dataRanking, int rangking) => [
        dataRanking[rangking].friendId == gNoRegistrasi
            ? Container(
                color: context.hintColor,
                child: Row(
                  children: [
                    Text('${rangking + 1}',
                        style: context.text.titleSmall
                            ?.copyWith(color: context.onPrimary)),
                    Padding(
                      padding: EdgeInsets.only(
                        left: context.dp(12),
                        right: context.dp(8),
                      ),
                      child: ProfilePictureWidget.leaderboard(
                        key: ValueKey(
                            'PHOTO_PROFILE_LEADERBOARD-${dataRanking[rangking].friendId}-${dataRanking[rangking].fullName}'),
                        width: (context.isMobile)
                            ? context.dp(48)
                            : context.dp(36),
                        height: (context.isMobile)
                            ? context.dp(48)
                            : context.dp(36),
                        noRegistrasi: dataRanking[rangking].friendId,
                        // userType: 'SISWA',
                        name: dataRanking[rangking].fullName,
                      ),
                    ),
                    Expanded(
                      child: Text(dataRanking[rangking].fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyLarge
                              ?.copyWith(color: context.onPrimary)),
                    ),
                    Text(dataRanking[rangking].score,
                        style: context.text.bodyLarge
                            ?.copyWith(color: context.onPrimary)),
                  ],
                ),
              )
            : Row(
                children: [
                  Text('${rangking + 1}',
                      style: context.text.titleSmall
                          ?.copyWith(color: context.onPrimary)),
                  Padding(
                    padding: EdgeInsets.only(
                      left: context.dp(12),
                      right: context.dp(8),
                    ),
                    child: ProfilePictureWidget.leaderboard(
                      key: ValueKey(
                          'PHOTO_PROFILE_LEADERBOARD-${dataRanking[rangking].friendId}-${dataRanking[rangking].fullName}'),
                      width:
                          (context.isMobile) ? context.dp(48) : context.dp(36),
                      height:
                          (context.isMobile) ? context.dp(48) : context.dp(36),
                      noRegistrasi: dataRanking[rangking].friendId,
                      // userType: 'SISWA',
                      name: dataRanking[rangking].fullName,
                    ),
                  ),
                  Expanded(
                    child: Text(dataRanking[rangking].fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyLarge
                            ?.copyWith(color: context.onPrimary)),
                  ),
                  Text(dataRanking[rangking].score,
                      style: context.text.bodyLarge
                          ?.copyWith(color: context.onBackground)),
                ],
              ),
        Divider(color: context.onPrimary),
      ];
}
