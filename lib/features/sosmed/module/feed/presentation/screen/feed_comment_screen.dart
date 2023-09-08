// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';
import '../../../../../../core/shared/screen/basic_screen_profile.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/enum.dart';
import '../../model/feed.dart';
import '../provider/feed_provider.dart';
import '../widget/feed_comment_list.dart';

class FeedCommentScreen extends StatefulWidget {
  const FeedCommentScreen({
    Key? key,
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.userType,
    required this.feed,
  }) : super(key: key);

  /// Kumpulan Variabel untuk keperluan data user
  final String noRegistrasi;
  final String namaLengkap;
  final String userType;

  /// [feed] merupakan variable yang berisi data
  /// dari Class Feed yang teridiri dari (feedId, creatorId, creatorName,
  /// creatorRole, image, content, status, isLike, totalLike dan date)
  final Feed feed;

  @override
  State<FeedCommentScreen> createState() => _FeedCommentScreenState();
}

class _FeedCommentScreenState extends State<FeedCommentScreen> {
  /// [_settingFeed] merupakan list pilihan menu pada Bootom Sheet
  final List<List<dynamic>> _settingFeed = [
    ["Edit Privasi", const Icon(Icons.settings)],
    ["Hapus postingan", const Icon(Icons.delete)],
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreenProfile(
      title: widget.feed.creatorName!,
      subTitle: (widget.feed.date!.isNotEmpty)
          ? DateFormat("dd MMM yyyy, HH:mm")
              .format(DateTime.parse(widget.feed.date!))
          : DateFormat("dd MMM yyyy, HH:mm").format(DateTime.now()),
      leading: SizedBox(
        width: 60,
        child: Center(
            child: Container(
          margin: const EdgeInsets.only(right: 12),
          clipBehavior: Clip.antiAlias,
          height: (context.isMobile) ? 40 : 80,
          width: (context.isMobile) ? 40 : 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: CircleAvatar(
            key: ValueKey("${widget.feed.creatorName}-${widget.feed.feedId}"),
            radius: (context.isMobile) ? context.dp(32) : context.dp(64),
            backgroundColor: context.secondaryColor,
            child: ProfilePictureWidget.circle(
              name: widget.feed.creatorName!,
              width: (context.isMobile) ? context.dp(60) : context.dp(120),
              noRegistrasi: widget.feed.creatorId!,
              // userType: widget.feed.creatorRole!,
            ),
          ),
        )),
      ),
      trailing: InkWell(
        onTap: () {
          // Membuat variableTemp guna mengantisipasi rebuild saat scroll
          Widget? childWidget;
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            builder: (_) {
              childWidget ??= _bottomSheetSetting(widget.feed);
              return childWidget!;
            },
          );
        },
        child: Visibility(
          visible: widget.feed.creatorId == widget.noRegistrasi,
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Icon(
              Icons.more_vert,
              color: context.onPrimary,
            ),
          ),
        ),
      ),
      body: (widget.feed.status != 'publik')
          ? NoDataFoundWidget(
              subTitle: 'Feed tidak ditemukan',
              emptyMessage:
                  'Sobat tidak dapat melihat feed ini, karena feed ini sudah dihapus')
          : FeedCommentList(
              noRegistrasi: widget.noRegistrasi,
              namaLengkap: widget.namaLengkap,
              userType: widget.userType,
              feed: widget.feed,
            ),
    );
  }

  ///[_bottomSheetSetting] merupakan method yang menampilkan widget Bottom Sheet
  Container _bottomSheetSetting(Feed feed) {
    return Container(
      padding: EdgeInsets.only(
        left: context.dp(12),
        right: context.dp(12),
      ),
      width: context.dw,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: context.dp(40),
              height: context.dp(4),
              margin: EdgeInsets.symmetric(vertical: context.dp(8)),
              decoration: BoxDecoration(
                  color: context.disableColor,
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          CupertinoScrollbar(
            thumbVisibility: false,
            thickness: 4,
            radius: const Radius.circular(14),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _settingFeed.length,
              itemBuilder: (dialogcontext, index) {
                return GestureDetector(
                  onTap: () {
                    if (_settingFeed[index][0].toString() ==
                        "Hapus postingan") {
                      context
                          .read<FeedProvider>()
                          .deleteFeed(feedId: feed.feedId);
                      Navigator.pop(dialogcontext);
                      Navigator.pop(context);

                      gShowTopFlash(
                          context, "Sobat berhasil menghapus postingan",
                          dialogType: DialogType.success);
                    } else if (_settingFeed[index][0].toString() ==
                        "Edit Privasi") {
                      gShowBottomDialog(
                        context,
                        message: "Siapa yang dapat melihat postingan ini?",
                        actions: (controller) => [
                          TextButton(
                            onPressed: () async {
                              controller.dismiss(true);
                              context
                                  .read<FeedProvider>()
                                  .setFeedPublik(feedId: feed.feedId);

                              gShowTopFlash(
                                context,
                                'Yeey, feed kamu sekarang sudah Publik',
                                dialogType: DialogType.success,
                              );
                            },
                            child: const Text('Publik'),
                          ),
                          TextButton(
                            onPressed: () async {
                              controller.dismiss(true);
                              context
                                  .read<FeedProvider>()
                                  .setFeedPrivat(feedId: feed.feedId);

                              gShowTopFlash(
                                context,
                                'Yeey, sekarang feed ini hanya sobat yang dapat melihatnya',
                                dialogType: DialogType.success,
                              );
                            },
                            child: const Text('Hanya saya'),
                          )
                        ],
                      );
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          _settingFeed[index][0],
                          style: context.text.bodyMedium,
                        ),
                        leading: _settingFeed[index][1],
                        minLeadingWidth: context.dp(0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
