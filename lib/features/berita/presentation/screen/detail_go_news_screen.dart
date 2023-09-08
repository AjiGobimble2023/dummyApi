import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/shared/widget/html/custom_html_widget.dart';
import '../provider/berita_provider.dart';
import '../../entity/berita.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';

class DetailGoNewsScreen extends StatefulWidget {
  final Berita berita;

  const DetailGoNewsScreen({Key? key, required this.berita}) : super(key: key);

  @override
  State<DetailGoNewsScreen> createState() => _DetailGoNewsScreenState();
}

class _DetailGoNewsScreenState extends State<DetailGoNewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();
  bool _changeAppBarTheme = false;

  void _scrollListener() {
    if (_scrollController.offset > 100 && !_changeAppBarTheme) {
      setState(() => _changeAppBarTheme = true);
    }
    if (_scrollController.offset < 100 && _changeAppBarTheme) {
      setState(() => _changeAppBarTheme = false);
    }
  }

  @override
  void initState() {
    super.initState();
    //context.read<BeritaProvider>().refresh();

    setViewers();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  setViewers() {
    context.read<BeritaProvider>().addViewers(idBerita: widget.berita.id);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaleFactor: context.textScale12),
      child: Scaffold(
        backgroundColor: context.primaryColor,
        body: Container(
          width: context.dw,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  context.primaryColor,
                  context.secondaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 1]),
          ),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              if (context.isMobile) _buildBeritaImage(context),
              if (context.isMobile) _buildViewsCount(context),
              if (context.isMobile) SliverToBoxAdapter(child: _buildContent()),
              if (!context.isMobile)
                SliverFillRemaining(
                  fillOverscroll: false,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBeritaImage(context),
                            _buildViewsCount(context),
                          ],
                        ),
                      ),
                      Expanded(flex: 3, child: _buildContent()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewsCount(BuildContext context) {
    Widget countWidget = Row(
      children: [
        Text(
          '*Swipe dari kiri ke kanan untuk keluar',
          style: context.text.labelSmall?.copyWith(color: context.onPrimary),
        ),
        const Spacer(),
        Row(children: [
          Icon(
            Icons.visibility,
            size: 14,
            color: context.background,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            (int.parse(widget.berita.viewer) + 1).toString(),
            style: context.text.labelSmall?.copyWith(color: context.onPrimary),
          ),
        ])
      ],
    );

    return (context.isMobile)
        ? SliverPadding(
            padding: EdgeInsets.only(
                top: 4, left: context.dp(28), right: context.dp(28)),
            sliver: SliverToBoxAdapter(child: countWidget),
          )
        : Container(
            padding: const EdgeInsets.only(top: 4, left: 28, right: 28),
            child: countWidget,
          );
  }

  Widget _buildBeritaImage(BuildContext context) {
    Widget imageWidget = Hero(
      tag: widget.berita.id.beritaImageTag,
      transitionOnUserGestures: true,
      child: Material(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular((context.isMobile) ? 24 : 32)),
        ),
        child: CustomImageNetwork.rounded(
          widget.berita.image,
          fit: BoxFit.cover,
          width: (context.isMobile) ? double.infinity : context.dw * .46,
          height: (context.isMobile) ? context.dp(218) : context.dh * .5,
          borderRadius:
              BorderRadius.all(Radius.circular((context.isMobile) ? 24 : 32)),
        ),
      ),
    );

    return (context.isMobile)
        ? SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dp(20),
            ),
            sliver: SliverToBoxAdapter(child: imageWidget),
          )
        : Container(
            padding: const EdgeInsets.only(left: 24),
            child: imageWidget,
          );
  }

  List<Widget> _buildTitle() => [
        Hero(
          tag: widget.berita.id.beritaTitleTag,
          transitionOnUserGestures: true,
          child: Text(
            widget.berita.title,
            style: context.text.titleSmall?.copyWith(
                color: _changeAppBarTheme
                    ? context.onBackground
                    : context.onPrimary),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.berita.date,
          style: context.text.bodySmall?.copyWith(
              color: _changeAppBarTheme
                  ? context.onBackground
                  : context.onPrimary),
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
        ),
      ];

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      elevation: 12,
      snap: true,
      pinned: false,
      floating: true,
      stretch: false,
      centerTitle: true,
      forceElevated: true,
      toolbarHeight: min(98, context.dp(86)),
      collapsedHeight: min(98, context.dp(86)),
      automaticallyImplyLeading: false,
      foregroundColor:
          _changeAppBarTheme ? context.onBackground : context.onPrimary,
      backgroundColor:
          _changeAppBarTheme ? context.background : context.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildTitle(),
      ),
    );
  }

  Widget _buildContent() {
    Widget content = Hero(
      tag: widget.berita.id.beritaDescriptionTag,
      child: (widget.berita.description.contains('table'))
          ? WidgetFromHtml(htmlString: widget.berita.description)
          : CustomHtml(
              htmlString: widget.berita.description,
              fontSize: 12,
            ),
    );

    return Container(
      margin: EdgeInsets.only(
        left: min(22, context.dp(20)),
        right: min(22, context.dp(20)),
        top: min(20, context.dp(18)),
        bottom: (context.isMobile) ? context.dp(30) : 12,
      ),
      width: (context.isMobile) ? context.dw : double.infinity,
      padding: EdgeInsets.only(
        left: min(20, context.dp(16)),
        right: (context.isMobile) ? min(20, context.dp(16)) : 0,
        bottom: min(10, context.dp(8)),
        top: min(10, context.dp(8)),
      ),
      decoration: BoxDecoration(
        color: context.background,
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(2, 4),
            color: Colors.black26,
          ),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular((context.isMobile) ? 24 : 32),
        ),
      ),
      child: (context.isMobile)
          ? content
          : ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular((context.isMobile) ? 24 : 32),
              ),
              child: Scrollbar(
                controller: _contentScrollController,
                thickness: 8,
                thumbVisibility: true,
                trackVisibility: true,
                radius: const Radius.circular(14),
                child: SingleChildScrollView(
                  controller: _contentScrollController,
                  padding: const EdgeInsets.only(right: 20),
                  child: content,
                ),
              ),
            ),
    );
  }
}
