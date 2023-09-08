import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/config/theme.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/html/custom_html_widget.dart';

class PilihanBergandaTabel extends StatefulWidget {
  final Map<String, dynamic> jsonTabelJawaban;
  final List<int>? jawabanSebelumnya;
  final void Function(List<int> selected)? onSelectJawaban;

  // Untuk menampilkan solusi
  final bool bolehLihatSolusi;
  final List<int> kunciJawaban;

  const PilihanBergandaTabel({
    Key? key,
    required this.jsonTabelJawaban,
    this.jawabanSebelumnya,
    this.onSelectJawaban,
    required this.bolehLihatSolusi,
    required this.kunciJawaban,
  }) : super(key: key);

  @override
  State<PilihanBergandaTabel> createState() => _PilihanBergandaTabelState();
}

class _PilihanBergandaTabelState extends State<PilihanBergandaTabel> {
  final ScrollController _scrollController = ScrollController();
  List<int> _listPilihanJawaban = [];
  String _selectedJawaban = '';

  @override
  Widget build(BuildContext context) {
    if (widget.jawabanSebelumnya != null && _selectedJawaban.isEmpty) {
      _listPilihanJawaban = widget.jawabanSebelumnya!;
    } else if (_selectedJawaban.isNotEmpty) {
      _setSelectedJawaban(_selectedJawaban);
      if (widget.onSelectJawaban != null) {
        widget.onSelectJawaban!(_listPilihanJawaban);
      }
      _selectedJawaban = '';
    } else {
      _listPilihanJawaban = List.generate(
          widget.jsonTabelJawaban['bodies'].length, (index) => -1);

      if (kDebugMode) {
        logger.log(
            'PILIHAN_BERGANDA_TABEL-PreparedIsiTabelJawaban: $_listPilihanJawaban');
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: min(24, context.dp(12))),
      child: Theme(
        data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              trackColor: MaterialStateProperty.all(Colors.black12),
              trackBorderColor: MaterialStateProperty.all(Colors.black26)
            )),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 6,
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.dp(12)),
                  border: Border.all(color: context.onBackground)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.dp(12)),
                child: Table(
                  border: TableBorder.symmetric(
                      inside: BorderSide(color: context.onBackground)),
                  defaultColumnWidth: FixedColumnWidth(min(160, context.dp(132))),
                  columnWidths: {0: FixedColumnWidth(min(340, context.dp(186)))},
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    _buildHeaderTable(),
                    ..._buildTableBody(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// NOTE: Kumpulan fungsi
  void _setSelectedJawaban(String selected) {
    final splitJawaban = selected.split('-');
    final rowNumber = int.parse(splitJawaban[0].toString());
    final optionNumber = int.parse(splitJawaban[1].toString());

    if (kDebugMode) {
      logger.log(
          'PILIHAN_BERGANDA_TABEL-SetSelectedJawaban: $selected | $rowNumber >> $optionNumber');
    }

    _listPilihanJawaban[rowNumber] = optionNumber;
  }

  /// NOTE: Kumpulan widget
  TableRow _buildHeaderTable() => TableRow(
        decoration: BoxDecoration(color: context.primaryColor),
        children: (widget.jsonTabelJawaban['headers'] as List)
            .map<Widget>(
              (judul) => Padding(
                padding: EdgeInsets.only(
                  left: min(18, context.dp(12)),
                  top: min(12, context.dp(8)),
                  bottom: min(12, context.dp(8)),
                ),
                child: Text(judul,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.onPrimary)),
              ),
            )
            .toList(),
      );

  List<TableRow> _buildTableBody() {
    List<dynamic> body = widget.jsonTabelJawaban['bodies'];

    return List<TableRow>.generate(
      body.length,
      (rowNumber) => TableRow(
          decoration: BoxDecoration(
              color: rowNumber.isEven ? Colors.black26 : context.background),
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: min(18, context.dp(12)),
                right: min(6, context.dp(4)),
              ),
              child: CustomHtml(htmlString: body[rowNumber]),
            ),
            ...List.generate(
              widget.jsonTabelJawaban['headers'].length - 1,
              (columnNumber) {
                Widget radioButton = Radio<String>(
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  groupValue: '$rowNumber-${_listPilihanJawaban[rowNumber]}',
                  value: '$rowNumber-$columnNumber',
                  onChanged: widget.onSelectJawaban != null
                      ? (value) {
                          setState(() {
                            _selectedJawaban =
                                value ?? '$rowNumber-$columnNumber';
                          });
                        }
                      : null,
                );
                return (widget.bolehLihatSolusi)
                    ? Center(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  min(16, context.dp(12))),
                              color: (widget.kunciJawaban[rowNumber] ==
                                      columnNumber)
                                  ? Palette.kSuccessSwatch[400]
                                  : null),
                          child: radioButton,
                        ),
                      )
                    // Column(
                    //         children: [
                    //           Container(
                    //             width: min(46, context.dp(46)),
                    //             height: min(46, context.dp(46)),
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(
                    //                     min(16, context.dp(12))),
                    //                 color: (widget.kunciJawaban[rowNumber] ==
                    //                         columnNumber)
                    //                     ? Palette.kSuccessSwatch[400]
                    //                     : null),
                    //             child: radioButton,
                    //           ),
                    //           Text(
                    //             'Kunci',
                    //             style: context.text.labelSmall?.copyWith(
                    //               color: (widget.kunciJawaban[rowNumber] ==
                    //                       columnNumber)
                    //                   ? Palette.kSuccessSwatch[600]
                    //                   : Colors.transparent,
                    //             ),
                    //           )
                    //         ],
                    //       )
                    : radioButton;
              },
            ),
          ]),
    );
  }
}
