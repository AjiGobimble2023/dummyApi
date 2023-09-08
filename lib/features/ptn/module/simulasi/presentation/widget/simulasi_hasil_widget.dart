import 'package:flutter/material.dart';

import '../../model/hasil_model.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../../core/shared/widget/image/custom_image_network.dart';

class SimulasiHasilWidget extends StatefulWidget {
  const SimulasiHasilWidget({Key? key, required this.listHasil})
      : super(key: key);

  final List<HasilModel> listHasil;

  @override
  State<SimulasiHasilWidget> createState() => _SimulasiHasilWidgetState();
}

class _SimulasiHasilWidgetState extends State<SimulasiHasilWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.listHasil.length; i++)
          Column(
            children: [
              _buildSimulasiItem(widget.listHasil[i], i),
              (widget.listHasil.length != i + 1)
                  ? const SizedBox(
                      height: 10,
                    )
                  : const SizedBox.shrink()
            ],
          ),
      ],
    );
  }

  Widget loadingShimmer(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 4; i++)
          Column(
            children: [
              ShimmerWidget.rounded(
                width: context.dw,
                height: 115,
                borderRadius: BorderRadius.circular(24),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
      ],
    );
  }

  Future<void> _showSimulasiDialog(HasilModel simulasiSNBTModel) async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(minHeight: 10, maxHeight: context.dh * 0.9),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      backgroundColor: context.background,
      builder: (context) {
        childWidget ??= Container(
          padding: EdgeInsets.only(
              left: context.pd, right: context.pd, bottom: context.pd * 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomImageNetwork.rounded(
                      'ilustrasi_sbmptn.png'.illustration,
                      width: context.dw * 0.64,
                      height: context.dw * 0.64,
                      shrinkShimmer: true,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildItemsPoin(
                            "Prediksi\n Nilai UTBK", simulasiSNBTModel.total),
                        const SizedBox(
                          height: 25,
                        ),
                        buildItemsPoin("Prediksi\n Nilai Lulus",
                            simulasiSNBTModel.universitasModel.pg.toString()),
                      ],
                    )
                  ],
                ),
              ),
              _buildInformasiPTN(
                  simulasiSNBTModel.universitasModel.ptn.toString(),
                  simulasiSNBTModel.universitasModel.jurusan.toString()),
              Text(
                '*Berdasarkan prediksi pengali/bobot tiap rumpun prodi',
                style:
                    context.text.bodySmall?.copyWith(color: context.hintColor),
              ),
              _buildTitle(context, "Hasil Simulasi"),
              _buildIsi(context, simulasiSNBTModel.saran)
            ],
          ),
        );
        return childWidget!;
      },
    );
  }

  _buildInformasiPTN(String ptn, String jurusan) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 10,
      minVerticalPadding: 0,
      leading: Container(
        padding: const EdgeInsets.all(4),
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
          Icons.apartment_rounded,
          size: context.dp(22),
          color: context.onTertiary,
        ),
      ),
      title: Text(
        ptn,
        style: context.text.titleMedium,
      ),
      subtitle: Text(
        jurusan,
        style: context.text.titleSmall,
      ),
    );
  }

  _buildTitle(BuildContext context, String title, {bool isSubTitle = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: isSubTitle
                  ? context.text.titleMedium
                  : context.text.titleLarge,
            ),
            const Expanded(
              child: Divider(
                  thickness: 1, indent: 8, endIndent: 8, color: Colors.black26),
            ),
          ],
        ),
      );
  _buildIsi(
    BuildContext context,
    String text,
  ) {
    return Text(
      text,
      style: context.text.bodyMedium,
    );
  }

  Widget buildItemsPoin(String title, String poin) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          constraints: BoxConstraints(
            minWidth: context.dw * 0.2,
            maxHeight: context.dw * 0.2,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 1.0],
                colors: [
                  context.background,
                  context.secondaryColor,
                ],
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    spreadRadius: -2,
                    offset: Offset(0, 4))
              ]),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              textScaleFactor: context.textScale12,
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: '$poin\n',
                  style: context.text.titleMedium,
                  children: [
                    TextSpan(text: title, style: context.text.labelSmall),
                  ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimulasiItem(HasilModel simulasiSNBTModel, int index) {
    return InkWell(
      onTap: () => simulasiSNBTModel.universitasModel.jurusanId != null &&
              simulasiSNBTModel.universitasModel.ptn != "Belum ada data"
          ? _showSimulasiDialog(simulasiSNBTModel)
          : gShowBottomDialogInfo(context,
              message:
                  "Sobat belum memilih PTN dan Jurusan, silahkan isi Pilihan PTN dan Jurusan terlebih dahulu sobat"),
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
          top: 10,
        ),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: context.dw,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                horizontalTitleGap: 10,
                minVerticalPadding: 0,
                leading: Container(
                  padding: const EdgeInsets.all(4),
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
                    Icons.apartment_rounded,
                    size: context.dp(22),
                    color: context.onTertiary,
                  ),
                ),
                title: Text(
                  simulasiSNBTModel.universitasModel.ptn.toString(),
                  style: context.text.labelLarge,
                ),
                subtitle: Text(
                  simulasiSNBTModel.universitasModel.jurusan.toString(),
                  style: context.text.bodyMedium,
                ),
                trailing: const Icon(Icons.visibility_outlined),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(
                height: 0,
              ),
            ),
            Row(
              children: <Widget>[
                const Expanded(flex: 2, child: Text('Prioritas')),
                Expanded(
                    flex: 2, child: Text(': ${simulasiSNBTModel.prioritas}')),
              ],
            ),
            Row(
              children: <Widget>[
                const Expanded(
                  flex: 2,
                  child: Text('Daya Tampung'),
                ),
                Expanded(
                    flex: 2,
                    child: Text(
                        ': ${simulasiSNBTModel.universitasModel.tampung!.jumlah ?? 'Belum ada data'}')),
              ],
            ),
            Row(
              children: <Widget>[
                const Expanded(
                  flex: 2,
                  child: Text('Peminat'),
                ),
                Expanded(
                    flex: 2,
                    child: Text(
                        ': ${simulasiSNBTModel.universitasModel.peminat!.jumlah ?? 'Belum ada data'}')),
              ],
            ),
            Row(
              children: <Widget>[
                const Expanded(
                  flex: 2,
                  child: Text('Peluang Lulus'),
                ),
                Expanded(
                    flex: 2,
                    child: Text(
                        ': ${simulasiSNBTModel.universitasModel.pg ?? 'Belum ada data'}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
