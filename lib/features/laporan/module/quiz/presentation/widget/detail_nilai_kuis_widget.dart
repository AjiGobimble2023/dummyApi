import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../soal/entity/detail_jawaban.dart';

import '../../../../../../core/config/theme.dart';
import '../../../../../../core/shared/builder/responsive_builder.dart';

class DetailNilaiKuisWidget extends StatefulWidget {
  const DetailNilaiKuisWidget({
    Key? key,
    required this.listJawaban,
    required this.kategori,
  }) : super(key: key);
  final List<DetailJawaban> listJawaban;
  final Map<String, dynamic> kategori;

  @override
  State<DetailNilaiKuisWidget> createState() => _DetailNilaiKuisWidgetState();
}

class _DetailNilaiKuisWidgetState extends State<DetailNilaiKuisWidget> {
  /// Kumpulan variable colors
  final Color? _benarColor = Palette.kSuccessSwatch[200];
  final Color? _salahColor = Palette.kPrimarySwatch[200];
  final Color? _benarTextColor = Palette.kSuccessSwatch[900];
  final Color? _salahTextColor = Palette.kPrimarySwatch[900];
  int benar = 0;
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.listJawaban.length; i++) {
      if (widget.listJawaban[i].jawabanSiswa ==
          widget.listJawaban[i].kunciJawaban) {
        benar++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: context.dw - 32),
      padding: EdgeInsets.only(
        top: context.isMobile ? context.dp(12) : context.dp(2),
      ),
      child: Column(
        children: [
          title(context),
          SizedBox(
            height: (context.isMobile) ? context.pd : 0,
          ),
          Container(
            constraints: const BoxConstraints(
              maxHeight: double.infinity,
            ),
            width: (context.isMobile)
                ? (context.dw - context.pd)
                : ((context.dw - context.dp(132))) - context.pd,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.listJawaban.length,
              itemBuilder: (BuildContext context, int index) {
                return ResponsiveBuilder(
                  mobile: buildDetailNilaiMobile(index, context),
                  tablet: buildDetailNilaiTablet(index, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Column buildDetailNilaiTablet(int index, BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index == 0)
            Table(
              children: [
                TableRow(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: context.tertiaryColor,
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text("No",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text("Jawaban",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          "Poin",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      )
                    ])
              ],
            ),
          Table(
            border: TableBorder(
              borderRadius: BorderRadius.circular(16),
              verticalInside: BorderSide(
                  width: 1,
                  color: context.disableColor,
                  style: BorderStyle.solid),
              left: BorderSide(
                  width: 1,
                  color: context.disableColor,
                  style: BorderStyle.solid),
              right: BorderSide(
                  width: 1,
                  color: context.disableColor,
                  style: BorderStyle.solid),
            ),
            children: [
              TableRow(children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${widget.listJawaban[index].nomorSoalSiswa}"),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (widget.listJawaban[index].jawabanSiswa ==
                              widget.listJawaban[index].kunciJawaban)
                          ? _benarColor
                          : _salahColor,
                    ),
                    child: (widget.listJawaban[index].jawabanSiswa ==
                            widget.listJawaban[index].kunciJawaban)
                        ? Icon(Icons.check_circle_outline_rounded,
                            color: _benarTextColor)
                        : Icon(Icons.cancel_outlined, color: _salahTextColor),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.listJawaban[index].nilai.round() * 20}",
                    ),
                  ),
                ),
              ])
            ],
          ),
          if (index + 1 == widget.listJawaban.length)
            Table(
              children: [
                TableRow(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: context.tertiaryColor,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "(Jumlah Benar x Poin) $benar x 20 = ${widget.kategori['nilai']}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )
                    ])
              ],
            ),
        ],
      )
    ]);
  }

  Column buildDetailNilaiMobile(int index, BuildContext context) {
    return Column(
      children: [
        if (index == 0)
          Table(
            children: [
              TableRow(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: context.tertiaryColor,
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text("No",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text("Jawaban",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Poin",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        Table(
          border: TableBorder(
            borderRadius: BorderRadius.circular(16),
            verticalInside: BorderSide(
                width: 1,
                color: context.disableColor,
                style: BorderStyle.solid),
            left: BorderSide(
                width: 1,
                color: context.disableColor,
                style: BorderStyle.solid),
            right: BorderSide(
                width: 1,
                color: context.disableColor,
                style: BorderStyle.solid),
          ),
          children: [
            TableRow(children: [
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${widget.listJawaban[index].nomorSoalSiswa}"),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (widget.listJawaban[index].jawabanSiswa ==
                            widget.listJawaban[index].kunciJawaban)
                        ? _benarColor
                        : _salahColor,
                  ),
                  child: (widget.listJawaban[index].jawabanSiswa ==
                          widget.listJawaban[index].kunciJawaban)
                      ? Icon(Icons.check_circle_outline_rounded,
                          color: _benarTextColor)
                      : Icon(Icons.cancel_outlined, color: _salahTextColor),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${widget.listJawaban[index].nilai.round() * 20}",
                  ),
                ),
              ),
            ])
          ],
        ),
        if (index + 1 == widget.listJawaban.length)
          Table(
            children: [
              TableRow(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  color: context.tertiaryColor,
                ),
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "(Jumlah Benar x Poin) $benar x 20 = ${widget.kategori['nilai']}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Row title(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: context.dw - 32),
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            "Detail Nilai Kuis",
            style: context.text.titleMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
