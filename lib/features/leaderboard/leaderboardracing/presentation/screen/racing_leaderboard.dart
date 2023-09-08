import 'package:flutter/material.dart';

import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/builder/responsive_builder.dart';
import '../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../core/shared/screen/drop_down_action_screen.dart';
import '../../../../menu/entity/menu.dart';
import '../../../../menu/presentation/provider/menu_provider.dart';
import '../widget/location_leaderboard.dart';

class RacingLeaderboard extends StatefulWidget {
  const RacingLeaderboard({super.key});

  @override
  State<RacingLeaderboard> createState() => _RacingLeaderboardState();
}

class _RacingLeaderboardState extends State<RacingLeaderboard> {
  /// [_selectedLeaderboard] Variabel yang digunakan untuk menyimpan jenis Leaderboard yang dipilih.
  Menu _selectedLeaderboard = MenuProvider.listMenuLeaderBoardRacing[0];

  /// [menuLeaderboard] Digunakan untuk menyimpan data jenis Leaderboard yang dipilih.
  String menuLeaderboard = MenuProvider.listMenuLeaderBoardRacing[0].label;
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      tablet: DropDownActionScreen(
        title: "LeaderBoard Racing",
        isWatermarked: false,
        dropDownItems: MenuProvider.listMenuLeaderBoardRacing,
        selectedItem: _selectedLeaderboard,
        onChanged: (newValue) {
          setState(() {
            _selectedLeaderboard = newValue!;
            menuLeaderboard = newValue.label;
          });
        },
        body: (_selectedLeaderboard.label == "Gedung")
            ? const LocationLeaderboard(level: 'gedung')
            : (_selectedLeaderboard.label == "Kota")
                ? const LocationLeaderboard(level: 'kota')
                : const LocationLeaderboard(level: 'nasional'),
      ),
      mobile: BasicScreen(
        title: "LeaderBoard Racing",
        body: Container(
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
          child: DefaultTabController(
            length: 3,
            initialIndex: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  TabBar(
                    onTap: (int index) {
                      setState(() {
                        FocusManager.instance.primaryFocus?.unfocus();
                      });
                    },
                    dividerColor: Colors.transparent,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: context.onPrimary,
                    indicatorColor: context.onPrimary,
                    labelStyle: context.text.titleMedium,
                    unselectedLabelStyle: context.text.titleMedium,
                    unselectedLabelColor: context.onPrimary.withOpacity(0.54),
                    padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Gedung'),
                      Tab(text: 'Kota'),
                      Tab(text: 'Nasional'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      physics: ClampingScrollPhysics(),
                      children: [
                        LocationLeaderboard(level: 'gedung'),
                        LocationLeaderboard(level: 'kota'),
                        LocationLeaderboard(level: 'nasional'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
