import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/html/custom_html_widget.dart';
import '../../../../../core/util/data_formatter.dart';

class PilihanBergandaMemasangkan extends StatefulWidget {
  final Map<String, dynamic> jsonPernyataanOpsi;
  final List<int>? jawabanSebelumnya;
  final void Function(List<int> selected)? onSimpanJawaban;

  const PilihanBergandaMemasangkan(
      {Key? key,
      required this.jsonPernyataanOpsi,
      this.jawabanSebelumnya,
      this.onSimpanJawaban})
      : super(key: key);

  @override
  State<PilihanBergandaMemasangkan> createState() =>
      _PilihanBergandaMemasangkanState();
}

class _PilihanBergandaMemasangkanState
    extends State<PilihanBergandaMemasangkan> {
  List<int> _listJawabanTemp = [];
  int? _statementIndex, _selectedValue;

  @override
  Widget build(BuildContext context) {
    if (widget.jawabanSebelumnya != null && _selectedValue == null) {
      _listJawabanTemp = widget.jawabanSebelumnya!;
    } else if (_statementIndex != null && _selectedValue != null) {
      _setSelectedJawaban(_statementIndex!, _selectedValue!);
      if (widget.onSimpanJawaban != null) {
        widget.onSimpanJawaban!(_listJawabanTemp);
      }
      _statementIndex = null;
      _selectedValue = null;
    } else {
      _listJawabanTemp =
          (widget.jsonPernyataanOpsi['statement'] as List<dynamic>)
              .map<int>((e) => -1)
              .toList();
      _statementIndex = null;
      _selectedValue = null;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: context.dp(20), horizontal: context.dp(6)),
      child: Column(
        children: [
          _buildOptionInformation(),
          SizedBox(height: context.dp(10)),
          Text(
            'Tahan dan tarik ke pernyataan untuk mengisi jawaban!',
            style: context.text.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.dp(10)),
          _buildDragAndDrop(),
        ],
      ),
    );
  }

  /// NOTE: Kumpulan Fungsi
  void _setSelectedJawaban(int index, int selected) {
    // Jika pada [_listJawabanTemp] mengandung jabawan yang sama, dan indexnya jga sama, maka return.
    if (_listJawabanTemp.indexOf(selected) == index) return;
    // Jika pada [_listJawabanTemp] mengandung jabawan yang sama, maka hapus jawaban tersebut.
    if (_listJawabanTemp.contains(selected)) {
      final existIndex = _listJawabanTemp.indexOf(selected);
      _listJawabanTemp[existIndex] = -1;
    }
    // Set selected value ke index.
    _listJawabanTemp[index] = selected;
  }

  /// NOTE: Kumpulan widget
  TableRow _buildHeaderInformation() => TableRow(
        decoration: BoxDecoration(color: context.primaryColor),
        children: List<Widget>.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: context.dp(12),
              top: context.dp(8),
              bottom: context.dp(8),
            ),
            child: Text(index == 0 ? 'Opsi' : 'Keterangan',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.onPrimary)),
          ),
        ),
      );

  Widget _buildOptionInformation() {
    List<dynamic> listOptions = widget.jsonPernyataanOpsi['option'];

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.onBackground)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: TableBorder.symmetric(
              inside: BorderSide(color: context.onBackground)),
          columnWidths: {0: FixedColumnWidth(context.dp(56))},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildHeaderInformation(),
            ...List<TableRow>.generate(
              listOptions.length,
              (rowNumber) => TableRow(
                decoration: BoxDecoration(
                    color: rowNumber.isEven
                        ? context.disableColor
                        : context.background),
                children: [
                  Center(
                      child: Text('${rowNumber + 1}',
                          style: context.text.bodyMedium)),
                  CustomHtml(htmlString: listOptions[rowNumber]['option']),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDragAndDrop() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Pernyataan', style: context.text.bodyMedium),
            Text('Opsi', style: context.text.bodyMedium),
          ],
        ),
        Row(
          children: [
            _buildDropWidget(),
            SizedBox(width: context.dp(27)),
            _buildDragWidget()
          ],
        ),
        // _buildTableRow(
        //   firstColumnWidget: _buildDropWidget(),
        //   secondColumnWidget: _buildDragWidget(),
        // ),
      ],
    );
  }

  Widget _buildDropWidget() {
    List<dynamic> listStatements = widget.jsonPernyataanOpsi['statement'];

    return Column(
        mainAxisSize: MainAxisSize.min,
        children: listStatements.map<Widget>((statement) {
          final statementLabel =
              DataFormatter.formatHTMLAKM(statement['statement']);
          final statementIndex = statement['index'];

          return Padding(
            padding: EdgeInsets.only(top: context.dp(10)),
            child: DragTarget<int>(
              builder: (_, incoming, rejected) {
                return Statement(
                  statement: statementLabel,
                  option: (_listJawabanTemp[statementIndex] != -1)
                      ? 'Opsi ${_listJawabanTemp[statementIndex] + 1}'
                      : null,
                );
              },
              onWillAccept: (_) => true,
              onAccept: widget.onSimpanJawaban != null
                  ? (data) {
                      setState(() {
                        _selectedValue = data;
                        _statementIndex = statementIndex;
                      });
                    }
                  : null,
              onLeave: (data) {},
            ),
          );
        }).toList());
  }

  Widget _buildDragWidget() {
    List<dynamic> listOptions = widget.jsonPernyataanOpsi['option'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        listOptions.length,
        (optionIndex) => Padding(
          padding: EdgeInsets.symmetric(vertical: context.dp(12)),
          child: Draggable<int>(
            data: optionIndex,
            feedback: Option(label: 'Opsi ${optionIndex + 1}'),
            childWhenDragging: Option(label: 'Opsi ${optionIndex + 1}'),
            child: Option(label: 'Opsi ${optionIndex + 1}'),
          ),
        ),
      ),
    );
  }
}

class Statement extends StatelessWidget {
  final String statement;
  final String? option;

  const Statement({Key? key, required this.statement, this.option})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      strokeWidth: 1.2,
      strokeCap: StrokeCap.round,
      color: context.disableColor,
      borderType: BorderType.RRect,
      dashPattern: const [8, 8],
      radius: const Radius.circular(12),
      padding: EdgeInsets.only(
          left: context.dp(6), right: context.dp(4), bottom: context.dp(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: context.dp(171),
            child: CustomHtml(htmlString: statement),
          ),
          if (option != null) Option(label: option!),
        ],
      ),
    );
  }
}

class Option extends StatelessWidget {
  final String label;

  const Option({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: context.dp(118),
        height: context.dp(40),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            vertical: context.dp(10), horizontal: context.dp(12)),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: context.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style:
                context.text.labelLarge?.copyWith(color: context.primaryColor)),
      ),
    );
  }
}
