import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/friends_provider.dart';
import '../screen/friends_profile_screen.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';

class ListFriendsFromFriendWidget extends StatefulWidget {
  const ListFriendsFromFriendWidget({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final FriendsProfileScreen widget;

  @override
  State<ListFriendsFromFriendWidget> createState() =>
      _ListFriendsFromFriendWidgetState();
}

class _ListFriendsFromFriendWidgetState
    extends State<ListFriendsFromFriendWidget> {
  late final FriendsProvider _friendProvider = context.read<FriendsProvider>();
  deleteFriend(String friendId, fullname) async {
    await context
        .read<FriendsProvider>()
        .deleteFriends(friendId: friendId, userId: gNoRegistrasi);

    /// [loadFriendOfFriends] untuk mengambil list data teman dari teman

    // ignore: use_build_context_synchronously
    await context.read<FriendsProvider>().loadFriendOfFriends(friendId);

    // ignore: use_build_context_synchronously
    gShowTopFlash(
      context,
      'Sobat dan $fullname sudah tidak berteman lagi',
      dialogType: DialogType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsProvider>(
      builder: (context, friends, _) => (friends
              .currentListFriendsOfFriends.isNotEmpty)
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: friends.currentListFriendsOfFriends.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                    key: Key(
                        "${friends.currentListFriendsOfFriends[index].friendId}-${friends.currentListFriendsOfFriends[index].classLevelId}"),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => (direction ==
                            DismissDirection.endToStart)
                        ? deleteFriend(
                            friends.currentListFriendsOfFriends[index].friendId,
                            friends.currentListFriendsOfFriends[index].fullName)
                        : null,
                    confirmDismiss: (direction) => (direction ==
                            DismissDirection.endToStart)
                        ? gShowBottomDialog(context,
                            title: 'Konfirmasi Hapus Teman',
                            message:
                                'Berhenti berteman dengan ${friends.currentListFriendsOfFriends[index].fullName}?',
                            dialogType: DialogType.warning)
                        : Future<bool>.value(false),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(context.dp(8)),
                      color: context.primaryContainer,
                      child: Icon(Icons.delete_rounded,
                          color: context.onPrimaryContainer),
                    ),
                    child: InkWell(
                        onTap: () async {
                          // setState(() {
                          //   isLoading = true;
                          // });
                          await context.read<FriendsProvider>().loadMyScore(
                                noregistrasi: friends
                                    .currentListFriendsOfFriends[index]
                                    .friendId,
                                classLevelId: friends
                                    .currentListFriendsOfFriends[index]
                                    .classLevelId,
                              );
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(
                            context,
                            Constant.kRouteFriendsProfile,
                            arguments: {
                              "nama": friends
                                  .currentListFriendsOfFriends[index].fullName,
                              "noregistrasi": friends
                                  .currentListFriendsOfFriends[index].friendId,
                              "role": friends
                                  .currentListFriendsOfFriends[index].role,
                              "kelas": friends
                                  .currentListFriendsOfFriends[index].className,
                              "status": friends
                                  .currentListFriendsOfFriends[index].status,
                              "score": _friendProvider.myScore,
                            },
                          );
                          // setState(() {
                          //   isLoading = false;
                          // });
                        },
                        child: buildItems(index, context, friends)));
              })
          : SingleChildScrollView(
              child: SizedBox(
                height: context.dh,
                child: BasicEmpty(
                  shrink: context.isMobile,
                  // isLandscape: !context.isMobile,
                  imageUrl:
                      'ilustrasi_sosial_friends_not_found.png'.illustration,
                  title: 'Friends',
                  subTitle: "Belum ada teman",
                  emptyMessage:
                      "${widget.widget.namaLengkap} belum memiliki teman, ayo berteman dengannya Sobat!",
                ),
              ),
            ),
    );
  }

  Column buildItems(int index, BuildContext context, FriendsProvider friends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(children: [
          Container(
            padding: EdgeInsets.only(
                left: context.pd, right: context.pd, top: context.pd),
            child: CircleAvatar(
              radius: context.dp(29),
              backgroundColor: context.secondaryColor,
              child: ProfilePictureWidget.circle(
                name: friends.currentListFriendsOfFriends[index].fullName,
                width: context.dp(56),
                noRegistrasi:
                    friends.currentListFriendsOfFriends[index].friendId,
                // userType: friends.currentListFriendsOfFriends[index].role,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friends.currentListFriendsOfFriends[index].fullName,
                            style: context.text.bodySmall
                                ?.copyWith(color: Colors.black, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Kelas ${friends.currentListFriendsOfFriends[index].className}",
                            style: context.text.bodySmall
                                ?.copyWith(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: context.secondaryColor,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                friends
                                    .currentListFriendsOfFriends[index].score,
                                style: context.text.labelMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      (friends.currentListFriendsOfFriends[index].friendId !=
                              gNoRegistrasi)
                          ? Visibility(
                              visible:
                                  gNoRegistrasi != widget.widget.noRegistrasi,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: (friends
                                            .currentListFriendsOfFriends[index]
                                            .status !=
                                        "pending")
                                    ? InkWell(
                                        onTap: () async {
                                          await context
                                              .read<FriendsProvider>()
                                              .requestFriend(
                                                  sourceId: gNoRegistrasi,
                                                  destId: friends
                                                      .currentListFriendsOfFriends[
                                                          index]
                                                      .friendId);
                                          // ignore: use_build_context_synchronously
                                          gShowTopFlash(context,
                                              "Permintaan pertemanan berhasil dikirimkan",
                                              dialogType: DialogType.success);
                                        },
                                        child: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.green,
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          await context
                                              .read<FriendsProvider>()
                                              .deleteFriends(
                                                  userId: gNoRegistrasi,
                                                  friendId: friends
                                                      .currentListFriendsOfFriends[
                                                          index]
                                                      .friendId);
                                          // ignore: use_build_context_synchronously
                                          gShowTopFlash(context,
                                              "Permintaan pertemanan berhasil dibatalkan",
                                              dialogType: DialogType.success);
                                        },
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          color: context.primaryColor,
                                        ),
                                      ),
                              ),
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            ),
          )
        ]),
      ],
    );
  }
}
