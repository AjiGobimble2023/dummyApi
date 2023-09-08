import 'package:flutter/material.dart';

import '../../entity/jadwal_siswa.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/card/custom_card.dart';
import '../../../../core/shared/widget/separator/dash_divider.dart';

class JadwalItemWidget extends StatelessWidget {
  final String kelasGO;
  final JadwalSiswa jadwal;

  const JadwalItemWidget({
    Key? key,
    required this.jadwal,
    required this.kelasGO,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 3,
      margin: EdgeInsets.symmetric(
        horizontal: context.dp(18),
        vertical: context.dp(8),
      ),
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.only(
          top: context.dp(10),
          left: context.dp(10),
          right: context.dp(10),
          bottom: context.dp(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(
            height: 24,
            thickness: 1,
            color: Colors.black12,
          ),
          IntrinsicHeight(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: (context.isMobile) ? 46 : 112),
              child: Row(
                children: [
                  _buildWaktuKegiatan(context),
                  _buildInformasiKegiatan(context),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Expanded _buildInformasiKegiatan(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: 'Tempat: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: jadwal.namaGedung,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: 'Kelas GO: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: kelasGO,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tema Pembahasan:',
            style: context.text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 2),
          RichText(
            maxLines: 3,
            overflow: TextOverflow.fade,
            textScaleFactor: context.textScale12,
            text: TextSpan(
              text: '${jadwal.mataPelajaran}, ',
              style:
                  context.text.labelMedium?.copyWith(color: context.hintColor),
              children: [
                TextSpan(
                    text: jadwal.infoKegiatan,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pengajar:',
            style: context.text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 2),
          Text(
            jadwal.namaPengajar,
            style: context.text.labelMedium?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '(${jadwal.nikPengajar})',
            style: context.text.bodySmall?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  Expanded _buildWaktuKegiatan(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(right: context.dp(6)),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryColor,
                borderRadius: BorderRadius.circular(300),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: context.secondaryContainer.withOpacity(0.87)),
                  BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: context.secondaryContainer.withOpacity(0.87)),
                ],
              ),
              child: Text(
                jadwal.jamMulai,
                style: context.text.labelMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: DashedDivider(
                dashColor: context.disableColor,
                strokeWidth: 2,
                dash: 6,
                direction: Axis.vertical,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryColor,
                borderRadius: BorderRadius.circular(300),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryContainer.withOpacity(0.87)),
                  BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryContainer.withOpacity(0.87)),
                ],
              ),
              child: Text(jadwal.jamSelesai, style: context.text.labelMedium),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Row _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildIconJadwal(context),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jadwal.kegiatan,
                style: context.text.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Pertemuan ke-${jadwal.sesi}',
                style:
                    context.text.labelSmall?.copyWith(color: context.hintColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildIconJadwal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: EdgeInsets.only(right: context.dp(12)),
      decoration: BoxDecoration(
          color: context.tertiaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                offset: const Offset(-1, -1),
                blurRadius: 4,
                spreadRadius: 1,
                color: context.tertiaryColor.withOpacity(0.42)),
            BoxShadow(
                offset: const Offset(1, 1),
                blurRadius: 4,
                spreadRadius: 1,
                color: context.tertiaryColor.withOpacity(0.42))
          ]),
      child: Icon(
        Icons.schedule,
        size: context.dp(32),
        color: context.onTertiary,
        semanticLabel: 'ic_jadwal_siswa',
      ),
    );
  }
}
