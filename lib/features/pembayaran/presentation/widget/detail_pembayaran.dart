import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kreasi/features/auth/presentation/provider/auth_otp_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/config/global.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../auth/model/user_model.dart';
import '../../entity/pembayaran.dart';
import '../provider/pembayaran_provider.dart';

class DetailPembayaran extends StatefulWidget {
  // final UserModel? userData;

  const DetailPembayaran({Key? key}) : super(key: key);

  @override
  State<DetailPembayaran> createState() => _DetailPembayaranState();
}

class _DetailPembayaranState extends State<DetailPembayaran> {
  final ScrollController _scrollController = ScrollController();
  late UserModel? userData = context.watch<AuthOtpProvider>().userData;

  @override
  Widget build(BuildContext context) {
    return Selector<PembayaranProvider, List<Pembayaran>>(
      selector: (_, pembayaran) => pembayaran.detailPembayaran,
      builder: (context, detail, emptyWidget) {
        return FutureBuilder<List<Pembayaran>>(
          future: context.read<PembayaranProvider>().loadDetailPembayaran(
                noRegistrasi: '${userData?.noRegistrasi}',
              ),
          builder: (context, snapshot) {
            bool isLoadingDetail =
                snapshot.connectionState == ConnectionState.waiting ||
                    context.select<PembayaranProvider, bool>(
                        (pembayaran) => pembayaran.isLoadingDetail);

            if (isLoadingDetail) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: ShimmerWidget.rounded(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: gDefaultShimmerBorderRadius),
              );
            }

            if (!snapshot.hasData && detail.isEmpty) {
              return emptyWidget!;
            }

            List<Pembayaran> detailPembayaran =
                (snapshot.data!.isEmpty) ? detail : snapshot.data!;

            return (detailPembayaran.isEmpty)
                ? emptyWidget!
                : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(14),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: detailPembayaran.length + 2,
                      itemBuilder: (_, index) => (index == 0)
                          ? _buildTitleText(context)
                          : (index == detailPembayaran.length + 1)
                              ? _buildMessageBox(context)
                              : _buildTableInfo(
                                  index, context, detailPembayaran),
                    ),
                  );
          },
        );
      },
      child: const Text(
        'Mohon maaf, pembayaran anda belum terdata oleh kami. '
        'Silahkan hubungi 0853 5199 1159 (WA) untuk penanganan selanjutnya.\n',
        textAlign: TextAlign.center,
      ),
    );
  }

  Padding _buildTableInfo(
    int index,
    BuildContext context,
    List<Pembayaran> detailPembayaran,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: (index == 1) ? min(24, context.dp(20)) : min(18, context.dp(14)),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaleFactor: context.textScale12),
        child: Table(
          border: TableBorder(
              horizontalInside: BorderSide(width: 1, color: context.hintColor)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                const Text('Harga Bimbel Final'),
                Text(detailPembayaran[index - 1].hargaBimbelFinal),
              ],
            ),
            TableRow(
              children: [
                const Text('Sudah Dibayar'),
                Text(detailPembayaran[index - 1].sudahBayar),
              ],
            ),
            TableRow(
              children: [
                const Text('Sisa Pembayaran'),
                Text(detailPembayaran[index - 1].sisaPembayaran),
              ],
            ),
            TableRow(
              children: [
                const Text('Jatuh Tempo'),
                Text(detailPembayaran[index - 1].displayJatuhTempo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Center _buildTitleText(BuildContext context) {
    return Center(
      child: Text(
        'Hi Sobat, Jangan Lupa\nCek Pembayaran Kamu Ya',
        maxLines: 2,
        textAlign: TextAlign.center,
        style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Container _buildMessageBox(BuildContext context) {
    return Container(
      height: min(72, context.dp(62)),
      margin: EdgeInsets.symmetric(
        vertical: min(28, context.dp(24)),
        horizontal: (context.isMobile) ? 0 : context.dp(12),
      ),
      padding: EdgeInsets.all(
        min(18, context.dp(12)),
      ),
      decoration: BoxDecoration(
        color: context.primaryContainer,
        borderRadius: BorderRadius.circular(max(18, context.dp(8))),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
              offset: Offset(1, 1))
        ],
      ),
      child: FittedBox(
        child: Text(
          '*PERHATIAN:\n${context.read<PembayaranProvider>().pesanPembayaran}',
          style: context.text.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
