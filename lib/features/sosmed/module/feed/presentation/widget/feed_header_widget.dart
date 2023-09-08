import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/feed_provider.dart';
import '../../model/feed.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/data_formatter.dart';
import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';

class FeedHeaderWidget extends StatefulWidget {
  const FeedHeaderWidget({
    Key? key,
    required this.feed,
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.userType,
  }) : super(key: key);

  final String noRegistrasi;
  final String namaLengkap;
  final String userType;

  /// [feed] merupakan variable yang berisi data
  /// dari Class Feed yang teridiri dari (feedId, creatorId, creatorName,
  /// creatorRole, image, content, status, isLike, totalLike dan date)
  final Feed feed;

  @override
  State<FeedHeaderWidget> createState() => _FeedHeaderWidgetState();
}

class _FeedHeaderWidgetState extends State<FeedHeaderWidget> {
  /// [futureFetchFeed] merupakan variabel yang menampung data list feed
  Future<List<Feed>>? futureFetchFeed;

  /// Var Controller
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// [_settingFeed] merupakan list pilihan menu pada Bootom Sheet
  final List<List<dynamic>> _settingFeed = [
    ["Edit Privasi", const Icon(Icons.settings)],
    ["Hapus postingan", const Icon(Icons.delete)],
  ];

  Future<void> _onRefresh() async {
    return Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      setState(() {
        futureFetchFeed =
            context.read<FeedProvider>().loadFeed(widget.noRegistrasi);
      });
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.pd,
        right: context.pd,
        top: context.pd,
      ),
      child: Row(
        children: [
          _buildProfilePicture(context),
          _buildNameDateAndStatus(context),
          _buildActionFeed(context)
        ],
      ),
    );
  }

  /// [_buildActionFeed] widget untuk setting feed oleh user, yang berisi icon more_vert
  Visibility _buildActionFeed(BuildContext context) {
    return Visibility(
      visible: (widget.feed.creatorId == widget.noRegistrasi),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                // Membuat variableTemp guna mengantisipasi rebuild saat scroll
                Widget? childWidget;
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  builder: (context) {
                    childWidget ??= _bottomSheetSetting(widget.feed);
                    return childWidget!;
                  },
                );
              },
              child: Icon(
                Icons.more_vert,
                size: context.isMobile ? 24 : 36,
              )),
        ],
      ),
    );
  }

  /// [_buildNameDateAndStatus] widget ini berisi widget nama creator feed,
  /// tanggal upload dan status publikasi feed
  Expanded _buildNameDateAndStatus(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DataFormatter.formatCamelCase(widget.feed.creatorName!),
            style: (context.isMobile)
                ? context.text.bodyMedium
                : context.text.bodyLarge,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                  DateFormat("dd MMM yyyy, HH:mm")
                      .format(DateTime.parse(widget.feed.date!)),
                  style: context.text.labelSmall?.copyWith(
                      color: context.hintColor, fontWeight: FontWeight.normal)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: context.hintColor),
              ),
              Icon(
                  (widget.feed.status == "publik")
                      ? Icons.public
                      : Icons.lock_rounded,
                  size: context.isMobile ? 12 : 16,
                  color: context.hintColor),
            ],
          ),
        ],
      ),
    );
  }

  /// [_buildProfilePicture] merupakan method untuk membangun widget profile picture feed creator
  Container _buildProfilePicture(BuildContext context) {
    return Container(
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
          isUserLogin: true,
        ),
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
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (_settingFeed[index][0].toString() ==
                        "Hapus postingan") {
                      context
                          .read<FeedProvider>()
                          .deleteFeed(feedId: feed.feedId);
                      Navigator.pop(context);
                      _onRefresh();
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
                              _onRefresh();
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
                              _onRefresh();
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
