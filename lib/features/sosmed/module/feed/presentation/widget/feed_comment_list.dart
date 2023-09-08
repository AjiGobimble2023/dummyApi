import 'dart:developer' as logger show log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import 'feed_action_and_caption.dart';
import 'feed_body_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '../provider/feed_provider.dart';
import '../../model/feed.dart';
import '../../model/feed_comment.dart';
import '../../../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/builder/responsive_builder.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../../core/shared/widget/image/profile_picture_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../../../../../../core/shared/widget/button/custom_animated_icon_button.dart';

class FeedCommentList extends StatefulWidget {
  const FeedCommentList({
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
  State<FeedCommentList> createState() => _FeedCommentListtState();
}

class _FeedCommentListtState extends State<FeedCommentList> {
  /// Kumpulan variable untuk initialization data user
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();
  String? _userId;

  /// [feedComments] merupakan variable yang menampung list data komentar feed
  late List<FeedComments> feedComments;

  /// [lihatBalasan] merupakan variable yang menampung list data status
  /// (Apakah balasan di expand/lihat balasan = (true) atau disembunyikan = (false)
  List<bool> lihatBalasan = [];

  /// [reply] merupakan variable untuk menentukan jenis balasan komentar
  /// apakah mengomentari feed = (false) atau mengomentari komentar yang lainnya (true)
  bool reply = false;

  /// Kumpulan variable yang diperlukan untuk membalas komentar yang lain
  String? replyFeedId, replyFeedCreator, replyCreatorName;

  /// [cekKomentar] merupakan variable yang menampung status data balasan komentar
  /// dari komentar yang lainnya jika ada balasan = (true) jika tidak ada balasan =(false)
  List<bool> cekKomentar = [];

  /// Kumpulan variable untuk handle state loading
  bool isLoading = false;
  bool isLoadComments = false;

  /// Keperluan Input Komentar
  final _focusNode = FocusNode();
  final _textController = TextEditingController();

  /// [_refreshController] controller refresh comment
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String? firstHalf;
  String? secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();
    _userId = _authProvider.userData?.noRegistrasi;
    loadComments();
  }

  @override
  void dispose() {
    _textController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  loadComments() async {
    isLoadComments = true;
    feedComments = await context
        .read<FeedProvider>()
        .loadComment(userId: _userId, feedId: widget.feed.feedId);
    isLoadComments = false;
  }

  checkComments(listfeed, listfeedreply) {
    cekKomentar.clear();
    for (int i = 0; i < listfeed.length; i++) {
      bool a = false;
      for (int j = 0; j < listfeedreply.length; j++) {
        if (listfeed[i].feedId == listfeedreply[j].parentId) {
          a = true;
        }
      }
      cekKomentar.add(a);
    }
    if (kDebugMode) {
      logger.log("cekKomentar $cekKomentar");
    }
  }

  convertToTimeAgo(DateTime date) {
    DateTime now = DateTime.now();
    bulan(int bulan) {
      return (bulan == 1)
          ? 'Jan'
          : (bulan == 2)
              ? 'Feb'
              : (bulan == 3)
                  ? 'Mar'
                  : (bulan == 4)
                      ? 'Apr'
                      : (bulan == 5)
                          ? 'Mei'
                          : (bulan == 6)
                              ? 'Jun'
                              : (bulan == 7)
                                  ? 'Jul'
                                  : (bulan == 8)
                                      ? 'Agu'
                                      : (bulan == 9)
                                          ? 'Sep'
                                          : (bulan == 10)
                                              ? 'Okt'
                                              : (bulan == 11)
                                                  ? 'Nov'
                                                  : 'Des';
    }

    return ((now.hour - date.hour) != 0 || now.day != date.day)
        ? ((now.hour - date.hour) <= 0)
            ? '${date.day} ${bulan(date.month)}'
            : '${now.hour - date.hour} jam'
        : ((now.minute - date.minute) > 0)
            ? '${(now.minute - date.minute)} menit'
            : '1 menit';
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      tablet: Consumer<FeedProvider>(
        builder: (context, feed, child) => Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.dh - (context.pd) - context.dp(24),
              height: context.dh - (context.pd) - context.dp(24),
              child: FeedBodyWidget(
                feed: widget.feed,
                width: (context.dw - (context.pd * 2)) / 2,
                height: (context.dw - (context.pd * 2)) / 2,
                isComment: true,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: kElevationToShadow[2],
                      color: context.background,
                    ),
                    child: CustomSmartRefresher(
                      controller: _refreshController,
                      onRefresh: onRefreshComment,
                      isDark: true,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                left: context.pd,
                                right: context.pd,
                                top: context.pd,
                              ),
                              child: FeedActionAndCaption(
                                noRegistrasi: widget.noRegistrasi,
                                namaLengkap: widget.namaLengkap,
                                userType: widget.userType,
                                feed: widget.feed,
                                isComment: true,
                              ),
                            ),
                            (isLoadComments)
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: context.dh / 6),
                                    child: const LoadingWidget(
                                      message: "Sedang memuat Komentar",
                                      sizedBox: false,
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        left: context.pd,
                                        right: context.pd,
                                        bottom: context.dh / 1.5),
                                    child: _buildComment(),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isLoading || feed.isLoading) const LoadingWidget(),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(context.pd / 2),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: buildCommentTextInput(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      mobile: Consumer<FeedProvider>(
        builder: (context, feed, child) => Stack(
          children: [
            CustomSmartRefresher(
              controller: _refreshController,
              onRefresh: onRefreshComment,
              isDark: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FeedBodyWidget(
                      feed: widget.feed,
                      width: context.dw - (context.pd * 2),
                      height: context.dw - (context.pd * 2),
                      isComment: true,
                    ),
                    FeedActionAndCaption(
                      noRegistrasi: widget.noRegistrasi,
                      namaLengkap: widget.namaLengkap,
                      userType: widget.userType,
                      feed: widget.feed,
                      isComment: true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: (isLoadComments)
                              ? context.pd * 2
                              : context.dh / 4),
                      child: (isLoadComments)
                          ? buildShimmerComments(context)
                          : _buildComment(),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading || feed.isLoading) const LoadingWidget(),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: buildCommentTextInput(),
              ),
            )
          ],
        ),
      ),
    );
  }

  ListView buildShimmerComments(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) => Column(
              children: [
                ListTile(
                  leading: ShimmerWidget.rounded(
                      borderRadius: BorderRadius.circular(300),
                      width: context.dp(42),
                      height: context.dp(42)),
                  title: Padding(
                    padding: EdgeInsets.only(right: context.dw * 0.3),
                    child: ShimmerWidget.rounded(
                        borderRadius: gDefaultShimmerBorderRadius,
                        width: context.dp(80),
                        height: context.dp(18)),
                  ),
                  subtitle: ShimmerWidget.rounded(
                      borderRadius: gDefaultShimmerBorderRadius,
                      width: context.dp(180),
                      height: context.dp(12)),
                  trailing: ShimmerWidget.rounded(
                      borderRadius: gDefaultShimmerBorderRadius,
                      width: context.dp(24),
                      height: context.dp(24)),
                ),
              ],
            ),
        itemCount: 5);
  }

  Consumer<FeedProvider> _buildComment() {
    return Consumer<FeedProvider>(builder: (context, value, _) {
      checkComments(value.listFeed, value.listFeedReply);

      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: value.listFeed.length,
          itemBuilder: (BuildContext context, int index) {
            lihatBalasan.add(false);
            return (value.listFeed.isNotEmpty)
                ? Dismissible(
                    key: Key(
                        '${value.listFeed[index].feedId}-${value.listFeed[index].date}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) =>
                        (direction == DismissDirection.endToStart &&
                                (value.listFeed[index].creatorId == _userId))
                            ? deleteComment(value.listFeed[index].feedId,
                                value.listFeed[index].creatorId, true)
                            : null,
                    confirmDismiss: (direction) => (direction ==
                            DismissDirection.endToStart)
                        ? (value.listFeed[index].creatorId != _userId)
                            ? gShowBottomDialogInfo(context,
                                title: 'Konfirmasi Hapus Komentar',
                                message:
                                    'Sobat tidak bisa menghapus komentar orang lain',
                                dialogType: DialogType.warning)
                            : gShowBottomDialog(context,
                                title: 'Konfirmasi Hapus Komentar',
                                message:
                                    'Sobat yakin ingin menghapus komentar ini?',
                                dialogType: DialogType.warning)
                        : Future<bool>.value(false),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(context.dp(8)),
                      color: context.primaryContainer,
                      child: Icon(Icons.delete_rounded,
                          color: context.onPrimaryContainer),
                    ),
                    child: Padding(
                      padding: context.isMobile
                          ? EdgeInsets.symmetric(horizontal: context.pd)
                          : EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            onLongPress: () => deleteComment(
                                value.listFeed[index].feedId,
                                value.listFeed[index].creatorId,
                                false),
                            leading: Container(
                              height: 32.0,
                              width: 32.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: CircleAvatar(
                                radius: context.dp(32),
                                backgroundColor: context.secondaryColor,
                                child: ProfilePictureWidget.circle(
                                  name: value.listFeed[index].creatorName,
                                  width: context.dp(60),
                                  noRegistrasi: value.listFeed[index].creatorId,
                                  // userType: value.listFeed[index].creatorRole,
                                ),
                              ),
                            ),
                            horizontalTitleGap: 5,
                            contentPadding: EdgeInsets.zero,
                            title: RichText(
                              textScaleFactor: context.textScale12,
                              text: TextSpan(children: [
                                TextSpan(
                                  text:
                                      "${value.listFeed[index].creatorName}\t",
                                  style: context.text.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: convertToTimeAgo(
                                    DateTime.parse(value.listFeed[index].date),
                                  ),
                                  style: context.text.bodySmall
                                      ?.copyWith(color: context.hintColor),
                                )
                              ], style: const TextStyle(color: Colors.black)),
                            ),
                            subtitle: ReadMoreText(
                              value.listFeed[index].content,
                              trimLines: 5,
                              colorClickableText: Colors.blueAccent,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Baca selengkapnya',
                              style: context.text.bodyMedium,
                              trimExpandedText: ' Lihat lebih sedikit',
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomAnimatedIconButton(
                                  isLike: value.listFeed[index].isLike,
                                  initialState: value.listFeed[index].isLike,
                                  icondata: (value.listFeed[index].isLike)
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  size: context.isMobile ? 14 : 18,
                                  onTap: (state) {
                                    setState(() {
                                      value.listFeed[index].isLike = state;
                                      state
                                          ? value.listFeed[index].totalLike =
                                              ++value.listFeed[index].totalLike
                                          : --value.listFeed[index].totalLike;
                                    });
                                    context.read<FeedProvider>().responseFeed(
                                          userId: _authProvider
                                              .userData?.noRegistrasi,
                                          feedId: value.listFeed[index].feedId,
                                          type: state ? "like" : "unliked",
                                        );
                                  },
                                ),
                                Text(
                                  value.listFeed[index].totalLike.toString(),
                                  style: context.text.bodySmall,
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 45,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    reply = true;
                                    replyFeedId = value.listFeed[index].feedId;
                                    replyFeedCreator =
                                        value.listFeed[index].creatorId;
                                    replyCreatorName =
                                        value.listFeed[index].creatorName;
                                  });

                                  /// Melakukan request focusNode saat text button balas diklik
                                  /// untuk keperluan auto input text komentar balasan
                                  _focusNode.requestFocus();
                                },
                                child: Text(
                                  "Balas",
                                  style: context.text.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                  left: 45, top: 8, bottom: 8, right: 0),
                              itemCount: value.listFeedReply.length,
                              itemBuilder: (BuildContext context, int idx) {
                                return (value.listFeedReply.isNotEmpty &&
                                        value.listFeedReply[idx].parentId ==
                                            value.listFeed[index].feedId)
                                    ? Column(
                                        children: [
                                          Visibility(
                                            visible: lihatBalasan[index],
                                            child: ListTile(
                                              onLongPress: () => deleteComment(
                                                  value.listFeedReply[idx]
                                                      .feedId,
                                                  value.listFeedReply[idx]
                                                      .creatorId,
                                                  false),
                                              leading: Container(
                                                clipBehavior: Clip.antiAlias,
                                                height: 32.0,
                                                width: 32.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                ),
                                                child: CircleAvatar(
                                                  radius: context.dp(32),
                                                  backgroundColor:
                                                      context.secondaryColor,
                                                  child: ProfilePictureWidget
                                                      .circle(
                                                    name: value
                                                        .listFeedReply[idx]
                                                        .creatorName,
                                                    width: context.dp(60),
                                                    noRegistrasi: value
                                                        .listFeedReply[idx]
                                                        .creatorId,
                                                    // userType: value
                                                    //     .listFeedReply[idx]
                                                    //     .creatorRole,
                                                  ),
                                                ),
                                              ),
                                              horizontalTitleGap: 5,
                                              contentPadding: EdgeInsets.zero,
                                              title: RichText(
                                                textScaleFactor:
                                                    context.textScale12,
                                                text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            "${value.listFeedReply[idx].creatorName}\t",
                                                        style: context
                                                            .text.bodyLarge
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      TextSpan(
                                                        text: convertToTimeAgo(
                                                          DateTime.parse(value
                                                              .listFeed[index]
                                                              .date),
                                                        ),
                                                        style: context
                                                            .text.bodySmall
                                                            ?.copyWith(
                                                                color: context
                                                                    .hintColor),
                                                      )
                                                    ],
                                                    style: const TextStyle(
                                                        color: Colors.black)),
                                              ),
                                              subtitle: ReadMoreText(
                                                value
                                                    .listFeedReply[idx].content,
                                                trimLines: 5,
                                                colorClickableText:
                                                    Colors.blueAccent,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText:
                                                    'Baca selengkapnya',
                                                style: context.text.bodyMedium,
                                                trimExpandedText:
                                                    ' Lihat lebih sedikit',
                                              ),
                                              trailing: Column(
                                                children: [
                                                  CustomAnimatedIconButton(
                                                    isLike: value
                                                        .listFeedReply[idx]
                                                        .isLike,
                                                    initialState: value
                                                        .listFeedReply[idx]
                                                        .isLike,
                                                    icondata: (value
                                                            .listFeedReply[idx]
                                                            .isLike)
                                                        ? CupertinoIcons
                                                            .heart_fill
                                                        : CupertinoIcons.heart,
                                                    size: 14,
                                                    onTap: (state) {
                                                      setState(() {
                                                        value.listFeedReply[idx]
                                                            .isLike = state;
                                                        state
                                                            ? value
                                                                    .listFeedReply[
                                                                        idx]
                                                                    .totalLike =
                                                                ++value
                                                                    .listFeedReply[
                                                                        idx]
                                                                    .totalLike
                                                            : --value
                                                                .listFeedReply[
                                                                    idx]
                                                                .totalLike;
                                                      });
                                                      context
                                                          .read<FeedProvider>()
                                                          .responseFeed(
                                                            userId: _authProvider
                                                                .userData
                                                                ?.noRegistrasi,
                                                            feedId: value
                                                                .listFeedReply[
                                                                    idx]
                                                                .feedId,
                                                            type: state
                                                                ? "like"
                                                                : "unliked",
                                                          );
                                                    },
                                                  ),
                                                  Text(
                                                    (value.listFeedReply[idx]
                                                            .totalLike)
                                                        .toString(),
                                                    style:
                                                        context.text.bodySmall,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink();
                              }),
                          Visibility(
                            visible: cekKomentar[index],
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  lihatBalasan[index] = !lihatBalasan[index];
                                });
                              },
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 45,
                                  ),
                                  Container(
                                    width: context.dp(30),
                                    height: context.dp(1),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  (!lihatBalasan[index])
                                      ? Text(
                                          "Lihat balasan",
                                          style: context.text.bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        )
                                      : Text(
                                          "Sembunyikan balasan",
                                          style: context.text.bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ))
                : const SizedBox.shrink();
          });
    });
  }

  Column buildCommentTextInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: reply,
          child: Container(
            width: context.dw,
            padding: EdgeInsets.all(context.pd),
            decoration: BoxDecoration(
                color: context.background, boxShadow: kElevationToShadow[2]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Membalas komentar dari $replyCreatorName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        reply = false;
                      });
                    },
                    child: const Icon(Icons.close))
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: context.background, boxShadow: kElevationToShadow[12]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: context.pd,
                    right: 8,
                    // bottom: context.pd,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _textController,
                    style: const TextStyle(fontSize: 15),
                    inputFormatters: [
                      NoLeadingSpaceFormatter(),
                    ],
                    textInputAction: TextInputAction.send,
                    decoration: const InputDecoration(
                      hintText: "Tulis komentar",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 5,
                    minLines: 1,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  (_textController.text.isEmpty)
                      ? gShowTopFlash(
                          context, "Sobat belum menuliskan komentar",
                          dialogType: DialogType.warning)
                      : (reply)
                          ? await context.read<FeedProvider>().saveComment(
                                userId: _userId,
                                feedId: replyFeedId,
                                feedCreator: widget.feed.creatorName,
                                text: _textController.text,
                              )
                          : await context.read<FeedProvider>().saveComment(
                                userId: _userId,
                                feedId: widget.feed.feedId,
                                feedCreator: widget.feed.creatorName,
                                text: _textController.text,
                              );

                  _focusNode.unfocus();
                  setState(() {
                    onRefreshComment();
                    isLoading = false;
                    reply = false;
                    _textController.text = "";
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: context.pd,
                    right: context.pd,
                  ),
                  padding: EdgeInsets.only(
                      bottom: context.pd, right: context.pd, top: context.pd),
                  child: Icon(
                    Icons.send,
                    size: 24,
                    color: context.primaryColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  onRefreshComment() async {
    await context.read<FeedProvider>().loadComment(
          userId: widget.feed.creatorId,
          feedId: widget.feed.feedId,
        );
    _refreshController.refreshCompleted();
  }

  deleteComment(String feedId, String creatorId, bool dismissible) async {
    if (dismissible) {
      await context.read<FeedProvider>().deleteComment(feedId);
      await onRefreshComment();
      setState(() {
        isLoading = false;
      });
    } else {
      (creatorId != _userId)
          ? gShowBottomDialogInfo(context,
              title: 'Konfirmasi Hapus Komentar',
              message: 'Sobat tidak bisa menghapus komentar orang lain',
              dialogType: DialogType.warning)
          : gShowBottomDialog(context,
              title: 'Konfirmasi Hapus Komentar',
              message: 'Sobat yakin ingin menghapus komentar ini?',
              actions: (controller) => [
                    TextButton(
                        onPressed: () async {
                          controller.dismiss(true);
                          setState(() {
                            isLoading = true;
                          });
                          await context
                              .read<FeedProvider>()
                              .deleteComment(feedId);
                          await onRefreshComment();
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: const Text('Ya')),
                    TextButton(
                        onPressed: () => controller.dismiss(true),
                        child: const Text('Tidak'))
                  ],
              dialogType: DialogType.warning);
    }
  }
}

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(' ')) {
      final String trimedText = newValue.text.trimLeft();

      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }

    return newValue;
  }
}
