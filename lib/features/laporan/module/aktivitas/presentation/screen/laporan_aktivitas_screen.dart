import 'package:flutter/material.dart';

import '../widget/laporan_aktivitas_today.dart';
import '../widget/laporan_aktivitas_weekly.dart';
import '../../../../../../core/config/extensions.dart';

class LaporanAktivitasScreen extends StatefulWidget {
  const LaporanAktivitasScreen({Key? key}) : super(key: key);

  @override
  LaporanAktivitasScreenState createState() => LaporanAktivitasScreenState();
}

class LaporanAktivitasScreenState extends State<LaporanAktivitasScreen> {
  /// [_contentBar] merupakan List widget yang akan digunakan di TabBarView.
  final List<Widget> _contentBar = [
    const LogAktivitasHarian(),
    const LogAktivitasMingguan(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: context.dp(16),
              right: context.dp(16),
              left: context.dp(16),
            ),
            decoration: BoxDecoration(
                color: context.background,
                borderRadius: BorderRadius.circular(300),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26)
                ]),
            child: TabBar(
              dividerColor: Colors.transparent,
              labelColor: context.background,
              indicatorColor: context.primaryColor,
              labelStyle: context.text.bodyMedium,
              unselectedLabelStyle: context.text.bodyMedium,
              unselectedLabelColor: context.onBackground,
              splashBorderRadius: BorderRadius.circular(300),
              indicator: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(300)),
              indicatorPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.zero,
              tabs: const [Tab(text: 'Hari ini'), Tab(text: 'Minggu ini')],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const ClampingScrollPhysics(),
              children: [
                _contentBar[0],
                _contentBar[1],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
