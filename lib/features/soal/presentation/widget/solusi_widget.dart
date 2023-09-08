import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/shared/widget/html/custom_html_widget.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import 'video_solusi_expand.dart';
import '../provider/solusi_provider.dart';
import '../../entity/solusi.dart';
import '../../../video/model/video_soal.dart';
import '../../../video/presentation/provider/video_provider.dart';
import '../../../video/presentation/widget/video_player_card.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';
import '../../../../core/shared/widget/animation/hero_dialog_route.dart';

class SolusiWidget extends StatelessWidget {
  final String idSoal;
  final String tipeSoal;
  final String? idVideo;
  final dynamic kunciJawaban;
  final AccessVideoCardFrom accessFrom;

  const SolusiWidget({
    Key? key,
    required this.idSoal,
    required this.tipeSoal,
    this.idVideo,
    this.kunciJawaban,
    required this.accessFrom,
  }) : super(key: key);

  // void disposeVideoController(
  //   VideoPlayerController videoController,
  //   ChewieController chewieController,
  // ) {
  //   videoController.dispose();
  //   chewieController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Solusi?>(
        future: context.read<SolusiProvider>().getSolusi(idSoal: idSoal),
        builder: (_, snapshot) {
          Solusi solusi = snapshot.data ??
              const Solusi(solusi: '', theKing: '', idVideo: null);

          if (kDebugMode) {
            logger
                .log('SOLUSI_WIDGET-FutureBuilder: ${snapshot.connectionState}'
                    ' Data Solusi >> $solusi');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerWidget.rounded(
                width: context.dp(342),
                height: context.dp(240),
                borderRadius: BorderRadius.circular(24));
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text(
                    'Oops, terjadi kesalahan saat mengambil data solusi.'));
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildTitleText(context, 'Kunci Jawaban :'),
              // ..._buildKunciJawaban(context, [
              //   'Pernyataan 1 - Ya',
              //   'Pernyataan 2 - Tidak',
              //   'Pernyataan 3 - Tidak',
              //   'Pernyataan 4 - Ya'
              // ]),
              SizedBox(height: context.dp(12)),
              _buildTitleText(context, 'Solusi :'),
              (solusi.solusi.isEmpty ||
                      solusi.solusi == '-' ||
                      solusi.solusi == '<p>-</p>')
                  ? _buildEmptySolusi(context)
                  : Padding(
                      padding: EdgeInsets.only(left: context.dp(8)),
                      child: (solusi.solusi.contains('table'))
                          ? WidgetFromHtml(htmlString: solusi.solusi)
                          : CustomHtml(htmlString: solusi.solusi),
                    ),
              if (solusi.theKing != null &&
                  (solusi.theKing?.isNotEmpty ?? false) &&
                  solusi.theKing != '-' &&
                  solusi.theKing != '<p>-</p>')
                _buildTheKing(context,
                    DataFormatter.formatHTMLAKM(snapshot.data!.theKing!)),
              _buildVideoSoal(solusi, context),
              SizedBox(height: context.dp(52))
            ],
          );
        });
  }

  Widget _buildTitleText(BuildContext context, String title) => Padding(
        padding: EdgeInsets.only(left: context.dp(8), bottom: context.dp(4)),
        child: Text(title, style: context.text.titleMedium),
      );

  // List<Widget> _buildKunciJawaban(
  //         BuildContext context, List<String> kunciJawaban) =>
  //     kunciJawaban
  //         .map<Widget>(
  //           (kunci) => Padding(
  //             padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
  //             child: Text(' • $kunci'),
  //           ),
  //         )
  //         .toList();

  Widget _buildTheKing(BuildContext context, String theKing) => Container(
        padding: EdgeInsets.all(context.dp(10)),
        margin: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
            color: Palette.kSecondarySwatch[400],
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: context.dp(4)),
            Text('The King',
                style: context.text.titleMedium, textAlign: TextAlign.center),
            (theKing.contains('table'))
                ? WidgetFromHtml(htmlString: theKing)
                : CustomHtml(htmlString: theKing)
          ],
        ),
      );

  Widget _buildEmptySolusi(BuildContext context) => Container(
        padding: EdgeInsets.all(context.dp(14)),
        decoration: BoxDecoration(
            color: context.secondaryContainer,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(
            'Yaah, saat ini, belum ada solusi untuk soal ini Sobat. Tapi tenang, Kamu bisa menanyakan langsung solusi ke pengajar favoritmu!',
            style: context.text.bodyMedium,
            textAlign: TextAlign.center),
      );

  Widget _buildVideoSoalButton(
    BuildContext context, {
    required bool isBeliVideoSolusi,
    VideoSoal? video,
  }) =>
      Hero(
        tag: 'video_solusi',
        transitionOnUserGestures: true,
        child: TextButton.icon(
          onPressed: () {
            // Cek video solusi is exist
            if (video != null) {
              Navigator.of(context).push(
                HeroDialogRoute(
                  settings:
                      const RouteSettings(name: Constant.kRouteVideoSolusi),
                  builder: (context) => VideoSolusiExpand(videoSolusi: video),
                ),
              );
            } else {
              // Membuat variableTemp guna mengantisipasi rebuild saat scroll
              Widget? childWidget;
              // Show Bottom Sheet untuk promosi
              showModalBottomSheet(
                context: context,
                isDismissible: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) {
                  childWidget ??= Padding(
                    padding: EdgeInsets.symmetric(vertical: context.dp(18)),
                    child: ListTile(
                      dense: true,
                      isThreeLine: true,
                      leading: Icon(
                        Icons.movie_outlined,
                        color: context.primaryColor,
                        size: 46,
                        semanticLabel: 'Icon Video Soal',
                      ),
                      title: Text('Video Pembahasan',
                          style: context.text.labelLarge),
                      subtitle: Text((isBeliVideoSolusi)
                          ? 'Video pembahasan terkait soal ini belum tersedia Sobat. '
                              'Silahkan hubungi Min GO untuk mengajukan Video '
                              'Pembahasan terkait Soal ini yaa Sobat!'
                          : 'Yahh, kamu belum membeli produk Video Pembahasan Sobat. '
                              'Kalau Sobat tertarik dengan fitur Video Pembahasan, '
                              'hubungi cabang terdekat ya Sobat!'),
                    ),
                  );
                  return childWidget!;
                },
              );
            }
          },
          icon: Icon(Icons.movie_outlined, color: context.primaryColor),
          label: (isBeliVideoSolusi)
              ? const Text('Video Pembahasan Belum Dibeli')
              : (video != null)
                  ? const Text('Lihat Video Pembahasan >>')
                  : const Text('Video Pembahasan Belum Tersedia'),
          style: TextButton.styleFrom(
              textStyle: context.text.bodyMedium
                  ?.copyWith(decoration: TextDecoration.underline),
              foregroundColor: context.onBackground),
        ),
      );

  Widget _buildVideoSoal(Solusi solusi, BuildContext context) {
    // e-Video Soal (id: 87)
    bool isBeliVideoSoal =
        context.read<AuthOtpProvider>().isProdukDibeliSiswa(87);

    if (solusi.idVideo == null || solusi.idVideo == 0 || !isBeliVideoSoal) {
      return _buildVideoSoalButton(
        context,
        video: null,
        isBeliVideoSolusi: isBeliVideoSoal,
      );
    } else {
      return Selector<VideoProvider, VideoSoal?>(
        selector: (_, video) => video.getVideoSoalByIdVideo(solusi.idVideo!),
        shouldRebuild: (prev, next) =>
            prev?.idVideo == next?.idVideo &&
            (prev?.judulVideo != next?.judulVideo ||
                prev?.linkVideo != next?.linkVideo ||
                prev?.deskripsi != next?.deskripsi),
        builder: (_, videoSoal, loadingWidget) => FutureBuilder<VideoSoal?>(
          future: context
              .read<VideoProvider>()
              .getVideoSoal(idVideo: solusi.idVideo!),
          builder: (context, snapshot) {
            VideoSoal? video = snapshot.data ?? videoSoal;

            bool isLoadingVideoSoal =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<VideoProvider, bool>(
                        (video) => video.isLoadingVideoSoal);

            logger.log(
                'Get Video Soal >> loading($isLoadingVideoSoal) >> $video');

            if (isLoadingVideoSoal) {
              return loadingWidget!;
            }

            return _buildVideoSoalButton(
              context,
              video: video,
              isBeliVideoSolusi: isBeliVideoSoal,
            );
          },
        ),
        child: ShimmerWidget.rounded(
          width: context.dw * 0.3,
          height: 46,
          borderRadius: gDefaultShimmerBorderRadius,
        ),
      );
    }
  }
}
