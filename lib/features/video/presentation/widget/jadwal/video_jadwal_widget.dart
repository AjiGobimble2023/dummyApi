import 'package:flutter/material.dart';

import 'video_mapel_list.dart';
import '../../screen/jadwal/video_jadwal_bab_screen.dart';
import '../../../../../core/config/extensions.dart';

class VideoJadwalWidget extends StatelessWidget {
  final bool isRencanaPicker;

  const VideoJadwalWidget({Key? key, this.isRencanaPicker = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        children: [
          if (!context.isMobile) SizedBox(height: context.dp(6)),
          TabBar(
            indicatorWeight: 2,
            labelColor: context.onBackground,
            indicatorColor: context.onBackground,
            labelStyle: context.text.bodyMedium,
            unselectedLabelStyle: context.text.bodyMedium,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: context.onBackground.withOpacity(0.54),
            padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            tabs: const [Tab(text: 'Video Teori'), Tab(text: 'Video Ekstra')],
          ),
          Expanded(
            child: TabBarView(
              physics: const ClampingScrollPhysics(),
              children: [
                VideoMapelList(isRencanaPicker: isRencanaPicker),
                BabVideoJadwalScreen(
                  idMataPelajaran: 'extra',
                  namaMataPelajaran: 'Ekstra',
                  tingkatSekolah: '-',
                  isRencanaPicker: isRencanaPicker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
