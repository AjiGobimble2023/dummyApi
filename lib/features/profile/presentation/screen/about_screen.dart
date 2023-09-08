import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/config/constant.dart';
import 'package:provider/provider.dart';

import '../provider/profile_provider.dart';
import '../../model/about_model.dart';
import '../../../../core/config/extensions.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return FutureBuilder<List<AboutModel>>(
      future: context.read<ProfileProvider>().loadAbout(),
      builder: (context, snapshot) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaleFactor: context.textScale11),
        child: Scaffold(
          backgroundColor: context.background,
          body: Scrollbar(
            controller: scrollController,
            thickness: 8,
            radius: const Radius.circular(14),
            child: CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                Theme(
                  data: context.themeData.copyWith(
                    colorScheme: context.colorScheme.copyWith(
                      onSurface: context.onBackground,
                      onSurfaceVariant: context.onBackground,
                      onPrimary: context.onBackground,
                      surface: context.background,
                      primary: context.background,
                      // surfaceTint: context.background,
                      // surfaceVariant: context.background
                    ),
                  ),
                  child: SliverAppBar.medium(
                    stretch: true,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    title: const Text('Tentang GO Kreasi'),
                    leading: IconButton(
                      padding: EdgeInsets.only(
                        left: min(28, context.dp(24)),
                        right: min(16, context.dp(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: context.onBackground,
                      ),
                    ),
                    stretchTriggerOffset: 120,
                    onStretchTrigger: () async => await context
                        .read<ProfileProvider>()
                        .loadAbout(isRefresh: true),
                  ),
                ),
                if (context.select<ProfileProvider, bool>(
                    (data) => data.isLoadingAbout))
                  _buildLoadingWidget(),
                Selector<ProfileProvider, List<AboutModel>>(
                  selector: (_, data) => data.aboutGOKreasi,
                  shouldRebuild: (prev, next) =>
                      prev.length != next.length ||
                      prev.first != next.first ||
                      prev.last != next.last ||
                      prev.any((prevData) => next.any((nextData) =>
                          nextData.judul != prevData.judul ||
                          nextData.deskripsi != prevData.deskripsi ||
                          nextData.subData != prevData.subData)),
                  builder: (context, aboutData, child) => _buildAbout(
                      context,
                      (snapshot.data != null)
                          ? snapshot.data!
                          : (aboutData.isNotEmpty)
                              ? aboutData
                              : Constant.defaultAbout),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLoadingWidget() => const SliverToBoxAdapter(
        child: LinearProgressIndicator(),
      );

  // SliverList _buildLoadingWidget(BuildContext context) => SliverList(
  //       delegate: SliverChildListDelegate.fixed([
  //         const LinearProgressIndicator(),
  //         Padding(
  //             padding: EdgeInsets.only(top: context.dp(14)),
  //             child: const Center(child: Text('Sedang mengambil data')))
  //       ]),
  //     );

  SliverPadding _buildAbout(BuildContext context, List<AboutModel> aboutData) =>
      SliverPadding(
        padding: (context.isMobile)
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: (context.dw - 650) / 2),
        sliver: SliverList(
          delegate: SliverChildListDelegate(aboutData
              .map<Widget>(
                (about) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: min(28, context.dp(24)),
                    vertical: min(16, context.dp(12)),
                  ),
                  child: _buildAboutItem(about, context),
                ),
              )
              .toList()
            ..add(SizedBox(height: context.dp(32)))),
        ),
      );

  RichText _buildAboutItem(AboutModel about, BuildContext context) => RichText(
        textScaleFactor: context.textScale12,
        text: TextSpan(
          text: about.judul,
          style: context.text.titleMedium,
          children: (about.subData.isEmpty)
              ? about.deskripsi
                  .map<WidgetSpan>(
                    (desc) => WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.only(top: min(18, context.dp(14))),
                        child: Text(desc,
                            textAlign: TextAlign.justify,
                            style:
                                context.text.bodyMedium?.copyWith(height: 1.9)),
                      ),
                    ),
                  )
                  .toList()
              : about.subData
                  .map<WidgetSpan>(
                      (visiMisi) => _buildVisiMisi(context, visiMisi))
                  .toList(),
        ),
      );

  WidgetSpan _buildVisiMisi(BuildContext context, AboutModel visiMisi) =>
      WidgetSpan(
        child: Padding(
          padding: EdgeInsets.only(top: context.dp(8)),
          child: RichText(
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: '${visiMisi.judul}:',
              style: context.text.titleSmall,
              children: visiMisi.deskripsi
                  .map<TextSpan>(
                    (visiMisiItem) => TextSpan(
                        text: '\n$visiMisiItem',
                        style: context.text.bodyMedium?.copyWith(height: 1.9)),
                  )
                  .toList(),
            ),
          ),
        ),
      );
}
