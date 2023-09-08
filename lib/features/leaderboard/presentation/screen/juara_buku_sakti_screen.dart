import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../widget/list_juara_buku_sakti.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

const List<String> juaraTypes = ['Gedung', 'Kota', 'Nasional'];

class JuaraBukuSaktiScreen extends StatefulWidget {
  final String juaraType;

  const JuaraBukuSaktiScreen({Key? key, required this.juaraType})
      : super(key: key);

  @override
  State<JuaraBukuSaktiScreen> createState() => _JuaraBukuSaktiScreenState();
}

class _JuaraBukuSaktiScreenState extends State<JuaraBukuSaktiScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late final _tabController = TabController(
    length: juaraTypes.length,
    vsync: this,
    initialIndex: juaraTypes.indexOf(widget.juaraType),
  );
  // Value Listenable untuk index menu pada tablet mode.
  late final ValueNotifier<int> _selectedMenuIndex =
      ValueNotifier(juaraTypes.indexOf(widget.juaraType));

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  @override
  void reassemble() {
    _refreshController.dispose();
    super.reassemble();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          bottom: false,
          child: ResponsiveBuilder(
            mobile: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context),
                _buildCenterHeader(context),
                _buildTabBar(context),
                _buildTabBarView(),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(
                  flex: (context.dw > 1100) ? 3 : 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBackButton(context),
                      const SizedBox(height: 12),
                      _buildCenterHeader(context),
                      const SizedBox(height: 24),
                      _buildSideBar(),
                    ],
                  ),
                ),
                _buildTabBarView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildSideBar() {
    return Expanded(
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedMenuIndex,
        builder: (context, selectedIndex, _) => Scrollbar(
          controller: _scrollController,
          thickness: 8,
          radius: const Radius.circular(24),
          thumbVisibility: true,
          trackVisibility: true,
          child: ListView.separated(
            controller: _scrollController,
            padding:
                EdgeInsets.symmetric(horizontal: context.dp(5), vertical: 16),
            itemCount: juaraTypes.length,
            separatorBuilder: (context, index) =>
                const Divider(indent: 12, endIndent: 24),
            itemBuilder: (context, index) {
              bool isActive = selectedIndex == index;

              return InkWell(
                onTap: () {
                  _selectedMenuIndex.value = index;
                  _tabController.animateTo(index);
                },
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: double.infinity,
                  padding: (isActive)
                      ? const EdgeInsets.only(
                          top: 12, left: 8, bottom: 12, right: 12)
                      : const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: (isActive) ? Colors.black12 : null,
                  ),
                  child: Text(
                    juaraTypes[index],
                    key: (isActive)
                        ? ValueKey('active_${juaraTypes[index]}')
                        : ValueKey('deactive_${juaraTypes[index]}'),
                    style: context.text.labelLarge?.copyWith(
                      color: (isActive)
                          ? context.onPrimary
                          : context.onPrimary.withOpacity(0.54),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Expanded _buildTabBarView() {
    return Expanded(
      flex: (context.isMobile)
          ? 1
          : (context.isLandscape && context.dw > 1100)
              ? 6
              : 6,
      child: CustomSmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: juaraTypes
              .map<Widget>((e) => ListJuaraBukuSakti(juaraType: e))
              .toList(),
        ),
      ),
    );
  }

  TabBar _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      indicatorWeight: 2,
      labelColor: context.onPrimary,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: context.onPrimary,
      labelStyle: context.text.titleMedium,
      unselectedLabelStyle: context.text.titleMedium,
      unselectedLabelColor: context.onPrimary.withOpacity(0.54),
      padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
      indicatorPadding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      tabs: juaraTypes
          .map<Tab>((e) => Tab(text: e, iconMargin: EdgeInsets.zero))
          .toList(),
    );
  }

  Center _buildCenterHeader(BuildContext context) {
    return Center(
      child: CustomImageNetwork(
        'top_skor_header.png'.imgUrl,
        height: (context.isMobile) ? context.dp(54) : context.dp(24),
        fit: BoxFit.contain,
      ),
    );
  }

  IconButton _buildBackButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.only(
        top: (context.isMobile) ? 0 : context.dp(12),
        left: min(32, context.dp(24)),
        right: context.dp(12),
        bottom: 0,
      ),
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.onPrimary),
    );
  }
}
