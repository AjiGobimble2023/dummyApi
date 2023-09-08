import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../../model/feed.dart';
import '../provider/feed_provider.dart';
import '../widget/feed_card_widget.dart';

class FeedScreen extends StatefulWidget {
  final String noRegistrasi, namaLengkap, userType;
  const FeedScreen({
    super.key,
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.userType,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  /// [futureFetchFeed] merupakan variabel yang menampung data list feed
  Future<List<Feed>>? futureFetchFeed;

  /// Kumpulan var untuk Controller
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isLoading = false;
  bool _postHabis = false;

  @override
  void initState() {
    super.initState();

    /// Set value isLoading untuk keperluan persiapan load data list feed
    _isLoading = true;

    /// Initialization value var [_scrollController] untuk
    /// keperluan memuat data feed yang lawas tanpa harus menekan button load more
    _scrollController.addListener(() {
      if (_scrollController.offset >
          _scrollController.position.maxScrollExtent + 100) {
        if (!_isLoading) _onLoadmore(widget.noRegistrasi);
      }
    });

    /// Initialization data list feed
    Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      futureFetchFeed =
          context.read<FeedProvider>().loadFeed(widget.noRegistrasi);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// [_onRefresh] merupakan fungsi untuk merefresh halaman
  /// dengan cara pull down untuk mendapatkan feed yang terbaru
  Future<void> _onRefresh() async {
    return Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      setState(() {
        futureFetchFeed =
            context.read<FeedProvider>().loadFeed(widget.noRegistrasi);
        _postHabis = false;
      });
      _refreshController.refreshCompleted();
    });
  }

  /// [_onLoadmore] merupakan fungsi untuk memuat data feed yang lebih lawas dengan cara pull up
  Future<void> _onLoadmore(String userId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await context.read<FeedProvider>().loadmoreFeed(userId);
    } catch (e) {
      gShowTopFlash(context, "Seluruh data feed yang lawas telah dimuat",
          dialogType: DialogType.warning);
      setState(() {
        _postHabis = true;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: context.dh,
            width: context.dw,
            child: Padding(
              padding: EdgeInsets.only(
                left: context.pd,
                right: context.pd,
                bottom: context.pd,
              ),
              child: Consumer<FeedProvider>(
                builder: (context, feed, _) => CustomSmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: (feed.isLoading || _isLoading)
                      ? _buildShimmerWidget(context)
                      : (feed.currentListFeed.isEmpty)
                          ? _buildEmptyState(context)
                          : _buildListFeed(feed),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [_buildShimmerWidget] Loading Shimmer untuk widget item feed
  _buildShimmerWidget(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: context.pd),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: kElevationToShadow[2]),
                padding: EdgeInsets.all(context.pd),
                height: context.isMobile
                    ? context.dh < 700
                        ? context.dh * 0.68
                        : context.dh < 750
                            ? context.dh * 0.65
                            : context.dh < 900
                                ? context.dh * 0.6
                                : context.dh < 950
                                    ? context.dh * 0.57
                                    : context.dh * 0.6
                    : context.dw < 1100
                        ? context.dh * 1.5
                        : context.dh < 750
                            ? context.dh * 1.15
                            : context.dh < 850
                                ? context.dh * 1.1
                                : context.dh < 1400
                                    ? context.dh * 1.02
                                    : context.dh * 1.1,
                width: context.isMobile
                    ? context.dw
                    : context.dw - context.dp(132),
                child: Column(
                  children: [
                    /// Header Shimmer
                    Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[350]!,
                          highlightColor: Colors.grey[100]!,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child: SizedBox(
                              height: (context.isMobile) ? 40 : 80,
                              width: (context.isMobile) ? 40 : 80,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[350]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: SizedBox(
                                  height: (context.isMobile) ? 15 : 25,
                                  width: context.isMobile
                                      ? context.dw / 2
                                      : context.dw / 2 - context.dp(72),
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[350]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: SizedBox(
                                  height: (context.isMobile) ? 15 : 25,
                                  width: context.isMobile
                                      ? context.dw / 3
                                      : context.dw / 3 - context.dp(72),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[350]!,
                          highlightColor: Colors.grey[100]!,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child: SizedBox(
                              height: (context.isMobile) ? 25 : 40,
                              width: (context.isMobile) ? 25 : 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: context.pd / 2,
                    ),

                    /// Body Shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey[350]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          height: (context.isMobile)
                              ? (context.dh * 0.6) * 0.55
                              : context.dw < 1100
                                  ? context.dh * 1.4 * 0.6
                                  : (context.dh * 1.1 * 0.6),
                          width: context.isMobile
                              ? context.dw
                              : context.dw - context.dp(72),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.pd / 2,
                    ),

                    /// Action Shimmer
                    Row(
                      children: [
                        Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[350]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: SizedBox(
                                  height: (context.isMobile) ? 25 : 40,
                                  width: (context.isMobile) ? 25 : 40,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: context.pd,
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[350]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: SizedBox(
                                  height: (context.isMobile) ? 25 : 40,
                                  width: (context.isMobile) ? 25 : 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[350]!,
                          highlightColor: Colors.grey[100]!,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child: SizedBox(
                              height: (context.isMobile) ? 15 : 20,
                              width: (context.isMobile) ? 60 : 120,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: context.pd / 2,
                    ),

                    /// Caption Shimmer
                    SizedBox(
                      width: context.isMobile
                          ? context.dw - context.pd * 2
                          : context.dw - context.pd * 2 - context.dp(132),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[350]!,
                            highlightColor: Colors.grey[100]!,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: SizedBox(
                                height: (context.isMobile) ? 15 : 25,
                                width: context.isMobile
                                    ? context.dw / 3.5
                                    : (context.dw - context.dp(72)) / 3.5,
                              ),
                            ),
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[350]!,
                            highlightColor: Colors.grey[100]!,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: SizedBox(
                                  height: (context.isMobile) ? 15 : 25,
                                  width: context.dw),
                            ),
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[350]!,
                            highlightColor: Colors.grey[100]!,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(300),
                              ),
                              child: SizedBox(
                                  height: (context.isMobile) ? 15 : 25,
                                  width: context.isMobile
                                      ? context.dw / 2
                                      : (context.dw - context.dp(72)) / 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
                visible: index + 1 == 2,
                child: const SizedBox(
                  height: 300,
                )),
          ],
        );
      },
    );
  }

  /// [_buildListFeed] merupakan method untuk membangun widget list item feed
  ListView _buildListFeed(FeedProvider feed) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: feed.currentListFeed.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            /// Widget untuk membuat space/padding pada item feed yang pertama/yang paling atas
            Visibility(
              visible: index == 0,
              child: SizedBox(
                height: context.pd,
              ),
            ),

            ((feed.currentListFeed[index].status == "pribadi" &&
                        feed.currentListFeed[index].creatorId ==
                            widget.noRegistrasi) ||
                    feed.currentListFeed[index].status == "publik")
                ?

                /// FeedCardWidget merupakan widget item feed
                FeedCardWidget(
                    noRegistrasi: widget.noRegistrasi,
                    namaLengkap: widget.namaLengkap,
                    userType: widget.userType,
                    feed: feed.currentListFeed[index])
                : const SizedBox.shrink(),

            /// Widget untuk menampilkan data kosong,
            /// dengan kondisi seluruh feed teman ditemukan namun seluruh status feednya pribadi/not public
            Visibility(
              visible:
                  index + 1 == feed.currentListFeed.length && (feed.isEmpty),
              child: _buildEmptyState(context),
            ),

            /// Widget button Load more
            _buildButtonLoadMore(index, feed, context)
          ],
        );
      },
    );
  }

  Container _buildButtonLoadMore(
      int index, FeedProvider feed, BuildContext context) {
    return Container(
      child:

          /// Jika item feed adalah index terakhir dan status postHabis = false
          /// maka menampilkan button load more
          (index + 1 == feed.currentListFeed.length && !_postHabis)
              ? SizedBox(
                  height: 300,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextButton(
                      onPressed: () => _onLoadmore(widget.noRegistrasi),
                      child: Container(
                          padding: EdgeInsets.all(context.pd),
                          decoration: BoxDecoration(
                            color: context.background,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: kElevationToShadow[2],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: context.primaryColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text("Load more"),
                            ],
                          )),
                    ),
                  ),
                )
              : Visibility(
                  visible: index + 1 == feed.currentListFeed.length,
                  child: const SizedBox(
                    height: 300,
                  ),
                ),
    );
  }

  /// [_buildEmptyState] merupakan widget yang akan ditampilkan jika data feed kosong
  SingleChildScrollView _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: (context.isMobile) ? context.dh - 200 : 800,
        ),
        child: const NoDataFoundWidget(
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/kreasi-f1f7b.appspot.com/o/ilustrasi%2Filustrasi_sosial_feed_not_found.png?alt=media',
          subTitle: 'Sepertinya kamu belum mengunggah apapun sobat.',
          emptyMessage:
              'Yuk mulai share Rangking atau hasil TryOut kamu. Atau mulai tambahkan teman, agar kamu bisa tau update tentang teman kamu.',
        ),
      ),
    );
  }
}
