import 'package:flutter/material.dart';
import '../../../../../core/config/global.dart';
import 'package:provider/provider.dart';

import '../../model/data_ranking.dart';
import '../../../../sosmed/module/friends/presentation/provider/friends_provider.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/image/profile_picture_widget.dart';

class LeaderboardRacingListRank extends StatefulWidget {
  const LeaderboardRacingListRank({
    super.key,
    required this.context,
    required this.dataRanking,
  });

  final BuildContext context;
  final List<Myrank> dataRanking;

  @override
  State<LeaderboardRacingListRank> createState() =>
      _LeaderboardRacingListRankState();
}

class _LeaderboardRacingListRankState extends State<LeaderboardRacingListRank> {
  late final FriendsProvider _friendProvider = context.read<FriendsProvider>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.dataRanking.length,
          itemBuilder: (context, index) {
            Myrank detail = widget.dataRanking[index];
            return InkWell(
              onTap: () async {
                await context.read<FriendsProvider>().loadMyScore(
                      noregistrasi: detail.id,
                      classLevelId: detail.level,
                    );
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(
                  context,
                  Constant.kRouteFriendsProfile,
                  arguments: {
                    "nama": detail.fullName!.toUpperCase(),
                    "noregistrasi": detail.id,
                    "role": 'SISWA',
                    "kelas": '',
                    "status": "approved",
                    "score": _friendProvider.myScore,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: (detail.id == gNoRegistrasi)
                    ? BoxDecoration(
                        color: context.hintColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: (detail.rank == "1")
                              ? const Color.fromARGB(255, 247, 210, 0)
                              : (detail.rank == "2")
                                  ? const Color(0xffc0c0c0) // t
                                  : (detail.rank == "3")
                                      ? const Color(0xffcd7f32)
                                      : Colors.transparent,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          detail.rank!,
                          textAlign: TextAlign.center,
                          style: context.text.bodyMedium?.copyWith(
                              color: (int.parse(detail.rank!) <= 3)
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      height: 32.0,
                      width: 32.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: CircleAvatar(
                        key: ValueKey(detail.fullName),
                        radius: context.dp(32),
                        backgroundColor: context.secondaryColor,
                        child: ProfilePictureWidget.circle(
                          name: detail.fullName!,
                          width: context.dp(60),
                          noRegistrasi: '${detail.id}',
                          // userType: 'SISWA',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(child: Text(detail.fullName!.toUpperCase())),
                    const SizedBox(width: 10.0),
                    Text(detail.total!),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
