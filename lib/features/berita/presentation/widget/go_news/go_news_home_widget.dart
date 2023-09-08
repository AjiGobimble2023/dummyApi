import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../auth/model/user_model.dart';
import 'package:provider/provider.dart';

import '../../../entity/berita.dart';
import 'go_news_item.dart';
import '../../provider/berita_provider.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';

class GoNewsHomeWidget extends StatefulWidget {
  final UserModel? userData;

  const GoNewsHomeWidget({Key? key, this.userData}) : super(key: key);

  @override
  State<GoNewsHomeWidget> createState() => _GoNewsHomeWidgetState();
}

class _GoNewsHomeWidgetState extends State<GoNewsHomeWidget> {
  late final _beritaProvider = context.read<BeritaProvider>();
  late final Future<List<Berita>> _loadBerita = _beritaProvider.loadBerita(
    userType: widget.userData?.siapa ?? 'UMUM',
    fromHome: true,
  );

  @override
  Widget build(BuildContext context) {
    CustomImageNetwork imageGoNews = CustomImageNetwork(
      'go_news.webp'.imgUrl,
      width: min(140, context.dp(100)),
      height: min(140, context.dp(100)),
      fit: BoxFit.contain,
    );

    return Selector<BeritaProvider, List<Berita>>(
      selector: (_, berita) => berita.allNews,
      builder: (_, allNews, buttonLainnya) {
        return Selector<BeritaProvider, List<Berita>>(
          selector: (_, berita) => berita.headlineNews,
          builder: (context, headline, emptyWidget) {
            return FutureBuilder<List<Berita>>(
              future: _loadBerita,
              builder: (context, snapshot) {
                bool isLoading =
                    snapshot.connectionState == ConnectionState.waiting ||
                        context.select<BeritaProvider, bool>(
                            (berita) => berita.isLoadingBerita);

                if (isLoading) {
                  return AspectRatio(
                    aspectRatio: 16 / 7,
                    child: ShimmerWidget.rounded(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: gDefaultShimmerBorderRadius,
                    ),
                  );
                }

                List<Berita> headlineNews = ((snapshot.data?.isEmpty ?? true)
                        ? headline
                        : snapshot.data) ??
                    [];

                return SizedBox(
                  height: (context.isMobile) ? context.dp(179) : context.dp(82),
                  child: (headlineNews.isEmpty)
                      ? emptyWidget
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              (headlineNews.length < 10 || allNews.length <= 10)
                                  ? headlineNews.length + 1
                                  : headlineNews.length + 2,
                          physics: const BouncingScrollPhysics(),
                          padding:
                              EdgeInsets.symmetric(horizontal: context.dp(24)),
                          itemBuilder: (_, index) =>
                              (index > 0 && index <= headlineNews.length)
                                  ? GoNewsItem(
                                      isHome: true,
                                      berita: headlineNews[index - 1])
                                  : (index == 0)
                                      ? imageGoNews
                                      : buttonLainnya!,
                        ),
                );
              },
            );
          },
          child: _buildEmptyRefresh(context, imageGoNews),
        );
      },
      child: _buildButtonLainnya(context),
    );
  }

  Padding _buildEmptyRefresh(
      BuildContext context, CustomImageNetwork imageGoNews) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
      child: LayoutBuilder(builder: (context, constraint) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            imageGoNews,
            SizedBox(width: min(24, context.dp(12))),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: constraint.maxWidth -
                        ((context.isMobile) ? context.dp(120) : context.dp(64)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(
                      (context.isMobile) ? context.dp(12) : context.dp(8),
                    ),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(
                        (context.isMobile)
                            ? max(12, context.dp(12))
                            : context.dp(8),
                      ),
                    ),
                    child: Text(
                      'Tidak Ada Berita Untuk Saat Ini',
                      style: context.text.labelMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: (context.isMobile) ? 1 : 3,
                    ),
                  ),
                  TextButton(
                    onPressed: () async =>
                        await context.read<BeritaProvider>().loadBerita(
                              userType: widget.userData?.siapa ?? 'UMUM',
                              fromHome: true,
                              isRefresh: true,
                            ),
                    style:
                        TextButton.styleFrom(textStyle: context.text.labelSmall),
                    child: const Text('Muat Ulang'),
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Padding _buildButtonLainnya(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.dp(24), right: context.dp(14)),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, Constant.kRouteGoNews),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Icon(Icons.expand_circle_down_outlined,
                    size: 64, color: context.primaryColor),
              ),
              Text('Lainnya',
                  style: context.text.titleMedium?.copyWith(
                      color: context.primaryColor, fontWeight: FontWeight.w700))
            ],
          ),
        ),
      ),
    );
  }
}
