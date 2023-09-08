import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/provider/disposable_provider.dart';
import '../../features/buku/presentation/provider/buku_provider.dart';
import '../../features/jadwal/presentation/provider/jadwal_provider.dart';
import '../../features/profile/presentation/provider/profile_provider.dart';
import '../../features/bookmark/presentation/provider/bookmark_provider.dart';
import '../../features/kehadiran/presentation/provider/kehadiran_provider.dart';
import '../../features/leaderboard/presentation/provider/capaian_provider.dart';
import '../../features/pembayaran/presentation/provider/pembayaran_provider.dart';
import '../../features/leaderboard/presentation/provider/leaderboard_provider.dart';
import '../../features/soal/module/timer_soal/presentation/provider/tob_provider.dart';
import '../../features/soal/module/paket_soal/presentation/provider/paket_soal_provider.dart';
import '../../features/soal/module/bundel_soal/presentation/provider/bundel_soal_provider.dart';

class AppProviders {
  static List<DisposableProvider> getDisposableProviders(BuildContext context) {
    return [
      Provider.of<TOBProvider>(context, listen: false),
      Provider.of<BukuProvider>(context, listen: false),
      Provider.of<ProfileProvider>(context, listen: false),
      Provider.of<CapaianProvider>(context, listen: false),
      Provider.of<BookmarkProvider>(context, listen: false),
      Provider.of<PaketSoalProvider>(context, listen: false),
      Provider.of<JadwalProvider>(context, listen: false),
      Provider.of<KehadiranProvider>(context, listen: false),
      Provider.of<PembayaranProvider>(context, listen: false),
      Provider.of<BundelSoalProvider>(context, listen: false),
      Provider.of<LeaderboardProvider>(context, listen: false),
    ];
  }

  static void disposeAllDisposableProviders(BuildContext context) {
    getDisposableProviders(context).forEach((disposableProvider) {
      Future.delayed(const Duration(milliseconds: 300))
          .then((_) => disposableProvider.disposeValues());
    });
  }
}
