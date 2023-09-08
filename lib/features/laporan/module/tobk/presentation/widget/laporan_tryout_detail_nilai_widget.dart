import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'laporan_detail_nilai_chart.dart';

import '../../model/laporan_tryout_nilai_model.dart';

class LaporanTryoutSNBTDetailNilai extends StatelessWidget {
  final List<LaporanTryoutNilaiModel> _list;
  final String namaTOB;

  const LaporanTryoutSNBTDetailNilai(this._list, this.namaTOB, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: context.isMobile
            ? context.dw
            : context.dw / 2 - context.pd / 2 - context.pd,
        margin: context.isMobile
            ? EdgeInsets.only(
                left: context.pd,
                right: context.pd,
                bottom: context.pd + 20,
                top: 5,
              )
            : EdgeInsets.only(
                top: context.pd,
                left: context.pd / 2,
                right: context.pd,
                bottom: context.pd,
              ),
        padding: EdgeInsets.all(context.pd),
        decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: kElevationToShadow[2]),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 12),
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
                    CupertinoIcons.chart_bar_circle,
                    size: (context.isMobile) ? context.dp(22) : context.dp(16),
                    color: context.onTertiary,
                  ),
                ),
                Expanded(
                    child: (context.isMobile)
                        ? RichText(
                            textScaleFactor: context.textScale12,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "DETAIL NILAI\n",
                                  style: context.text.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: namaTOB,
                                  style: context.text.bodyMedium?.copyWith(
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RichText(
                            textScaleFactor: context.textScale12,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "DETAIL NILAI\n",
                                  style: context.text.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: namaTOB,
                                  style: context.text.bodyMedium?.copyWith(
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Divider(),
            ),
            for (int i = 0; i < _list.length; i++)
              Container(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _list[i].mapel,
                            style: context.text.labelLarge,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: context.secondaryColor),
                            child: Text("Skor : ${_list[i].nilai}",
                                style: context.text.labelLarge)),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: DetailNilaiChart(listJawaban: _list[i])),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Divider(color: context.hintColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
