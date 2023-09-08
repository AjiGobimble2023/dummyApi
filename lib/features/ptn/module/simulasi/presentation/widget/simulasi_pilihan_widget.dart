import 'package:flutter/material.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../model/pilihan_model.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';

class SimulasiPilihanWidget extends StatefulWidget {
  const SimulasiPilihanWidget({super.key, required this.listPilihan});
  final List<PilihanModel> listPilihan;

  @override
  State<SimulasiPilihanWidget> createState() => _SimulasiPilihanWidgetState();
}

class _SimulasiPilihanWidgetState extends State<SimulasiPilihanWidget> {
  Future<void> loadPilihan(PilihanModel pilihanModel) async {
    if (pilihanModel.status != 'fix') {
      Navigator.of(context).pushNamed(Constant.kRouteSimulasiPilihanForm,
          arguments: {'pilihanModel': pilihanModel}).then((value) {});
    } else {
      gShowBottomDialogInfo(context,
          message: 'Kesempatan untuk merubah pilihan ini telah habis');
    }
  }

  Widget _buildPilihanItem(PilihanModel pilihanModel, int index) {
    return Container(
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
            offset: const Offset(0, 3),
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
                pilihanModel.universitasModel!.ptn.toString(),
                style: context.text.labelLarge,
              ),
              subtitle: Text(
                pilihanModel.universitasModel!.jurusan.toString(),
                style: context.text.bodyMedium,
              ),
              trailing: GestureDetector(
                  onTap: () => loadPilihan(pilihanModel),
                  child: Visibility(
                    visible: (pilihanModel.status != "fix"),
                    child: SizedBox(
                      height: 40,
                      width: 30,
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.edit,
                            // size: 24,
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.secondaryColor),
                                child: Text(
                                  (pilihanModel.status != "fix")
                                      ? ((3 - int.parse(pilihanModel.status!))
                                          .toString())
                                      : "",
                                  style: context.text.bodySmall,
                                ),
                              ))
                        ],
                      ),
                    ),
                  )),
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
              Expanded(flex: 2, child: Text(': ${pilihanModel.prioritas}')),
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
                      ': ${pilihanModel.universitasModel!.tampung!.jumlah ?? 'Belum ada data'}')),
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
                      ': ${pilihanModel.universitasModel!.peminat!.jumlah ?? 'Belum ada data'}')),
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
                child: Text((pilihanModel.universitasModel!.pg!.isNotEmpty)
                    ? ': ${pilihanModel.universitasModel!.pg}'
                    : ": Belum ada data"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.listPilihan.length; i++)
          Column(
            children: [
              _buildPilihanItem(widget.listPilihan[i], i),
              (widget.listPilihan.length != i + 1)
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
}
