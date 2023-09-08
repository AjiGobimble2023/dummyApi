import 'package:flutter/material.dart';

import 'time/bulan_widget.dart';
import 'time/minggu_widget.dart';
import 'time/semester_widget.dart';
import '../../../../../../core/config/extensions.dart';

class LocationLeaderboard extends StatefulWidget {
  const LocationLeaderboard({super.key, required this.level});
  final String level;

  @override
  State<LocationLeaderboard> createState() => _LocationLeaderboard();
}

class _LocationLeaderboard extends State<LocationLeaderboard>
    with TickerProviderStateMixin {
  TabController? _tabwaktu;

  @override
  void initState() {
    super.initState();
    _tabwaktu = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabwaktu!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Column(
        children: [
          Container(
            height: (context.isMobile) ? context.dp(29) : context.dp(16),
            margin: (context.isMobile)
                ? EdgeInsets.only(
                    left: context.dp(70),
                    right: context.dp(70),
                    top: context.dp(20),
                    bottom: context.dp(20))
                : EdgeInsets.all(context.pd),
            decoration: (context.isMobile)
                ? const BoxDecoration()
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: kElevationToShadow[12],
                    color: context.background),
            child: TabBar(
              onTap: (int index) {
                setState(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              },
              labelColor:
                  context.isMobile ? (Colors.black) : context.background,
              indicatorColor: (context.isMobile)
                  ? context.background
                  : context.primaryColor,
              labelStyle: context.text.bodyMedium,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelStyle: context.text.bodyMedium,
              unselectedLabelColor: (context.isMobile)
                  ? context.onPrimary.withOpacity(0.54)
                  : context.hintColor,
              indicator: BoxDecoration(
                  color: (context.isMobile)
                      ? context.background
                      : context.primaryColor,
                  borderRadius: (context.isMobile)
                      ? BorderRadius.circular(8)
                      : BorderRadius.circular(300)),
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              tabs: const [
                Tab(
                  text: 'Minggu',
                ),
                Tab(text: 'Bulan'),
                Tab(text: 'Semester')
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const ClampingScrollPhysics(),
              children: [
                MingguRacing(
                  level: widget.level,
                ),
                BulanRacing(
                  level: widget.level,
                ),
                SemesterRacing(
                  level: widget.level,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
