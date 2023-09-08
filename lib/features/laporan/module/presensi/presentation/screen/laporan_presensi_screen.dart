import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/laporan_presensi_provider.dart';
import '../widget/laporan_presensi_widget.dart';

class LaporanPresensiScreen extends StatefulWidget {
  const LaporanPresensiScreen({Key? key}) : super(key: key);

  @override
  LaporanPresensiScreenState createState() => LaporanPresensiScreenState();
}

class LaporanPresensiScreenState extends State<LaporanPresensiScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Provider<LaporanPresensiProvider>(
        create: (_) => LaporanPresensiProvider(),
        child: const LaporanPresensiWidget(),
      ),
    );
  }
}
