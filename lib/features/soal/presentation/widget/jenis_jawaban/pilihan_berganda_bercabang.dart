import 'package:flutter/material.dart';

import 'opsi_card_item.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/util/data_formatter.dart';

class PilihanBergandaBercabang extends StatefulWidget {
  final List<dynamic> jsonOpsiJawaban;
  final Map<String, dynamic>? jawabanSebelumnya;
  final void Function(Map<String, dynamic> selected)? onSimpanJawaban;

  const PilihanBergandaBercabang(
      {Key? key,
      required this.jsonOpsiJawaban,
      this.jawabanSebelumnya,
      this.onSimpanJawaban})
      : super(key: key);

  @override
  State<PilihanBergandaBercabang> createState() =>
      _PilihanBergandaBercabangState();
}

class _PilihanBergandaBercabangState extends State<PilihanBergandaBercabang> {
  bool _isOpsiSelected = false;
  Map<String, dynamic> _jawabanTemp = {};
  List<int> _selectedAlasan = [];
  int? _selectedOpsiIndex, _selectedAlasanIndex, _selectedJawaban;

  @override
  Widget build(BuildContext context) {
    if (widget.jawabanSebelumnya != null &&
        _selectedJawaban == null &&
        !_isOpsiSelected) {
      _jawabanTemp = widget.jawabanSebelumnya!;
      _selectedOpsiIndex = _jawabanTemp.containsKey('opsi')
          ? int.parse(_jawabanTemp['opsi'].toString())
          : null;
      _selectedAlasan = _jawabanTemp.containsKey('alasan')
          ? List<int>.from(_jawabanTemp['alasan'])
          : [];
    } else if (_selectedJawaban != null || _isOpsiSelected) {
      _setSelectedJawaban();
      if (widget.onSimpanJawaban != null && _jawabanTemp.isNotEmpty) {
        widget.onSimpanJawaban!(_jawabanTemp);
      }
      _isOpsiSelected = false;
      _selectedJawaban = null;
    } else {
      _isOpsiSelected = false;
      _jawabanTemp = {};
      _selectedAlasan = [];
      _selectedOpsiIndex = null;
      _selectedJawaban = null;
    }

    return Column(children: [_buildListOption(widget.jsonOpsiJawaban)]);
  }

  /// NOTE: Kumpulan Function
  void _setSelectedJawaban() {
    if (_selectedJawaban != null) {
      if (_selectedAlasan[_selectedAlasanIndex!] != -1) {
        _selectedAlasan[_selectedAlasanIndex!] = -1;
      } else {
        _selectedAlasan[_selectedAlasanIndex!] = _selectedJawaban!;
      }
    }

    _jawabanTemp = {};
    _jawabanTemp['opsi'] = _selectedOpsiIndex;
    _jawabanTemp['alasan'] = _selectedAlasan;
  }

  void _prepareValueJawaban(List<dynamic> listReason) =>
      _selectedAlasan = listReason.map<int>((e) => -1).toList();

  /// NOTE: Kumpulan Widget
  Widget _buildListOption(List<dynamic> listOption) {
    listOption.removeWhere(
      (option) => (option == null ||
          option['text'] == null ||
          option['text'] == '' ||
          option['text'] == '-' ||
          option['text'] == '<p></p>' ||
          option['text'] == '<p>-</p>'),
    );

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: context.dp(6)),
          itemCount: listOption.length,
          itemBuilder: (_, index) {
            final optionLabel =
                DataFormatter.formatHTMLAKM(listOption[index]['text']);
            final isSelected = _selectedOpsiIndex == index;

            return OpsiCardItem(
              isEnabled: widget.onSimpanJawaban != null,
              isSelected: isSelected,
              isLastItem: (index == (listOption.length - 1)),
              isBolehLihatKunci: false,
              isKunciJawaban: false,
              opsiLabel: Text(
                '${index + 1}',
                style: context.text.titleMedium?.copyWith(
                    color: isSelected
                        ? context.onPrimary
                        : (widget.onSimpanJawaban != null)
                            ? context.primaryColor
                            : context.background),
              ),
              opsiText: optionLabel,
              onTap: widget.onSimpanJawaban != null
                  ? () {
                      setState(() {
                        _isOpsiSelected = true;
                        _selectedOpsiIndex = index;
                        _prepareValueJawaban(
                            listOption[_selectedOpsiIndex!]['alasan']);
                      });
                    }
                  : null,
            );
          },
        ),
        if (_selectedOpsiIndex != null)
          _buildListReason(listOption[_selectedOpsiIndex!]['alasan']),
      ],
    );
  }

  Widget _buildListReason(List<dynamic> listReason) {
    listReason.removeWhere(
      (option) => (option == null ||
          option['text'] == null ||
          option['text'] == '' ||
          option['text'] == '-' ||
          option['text'] == '<p></p>' ||
          option['text'] == '<p>-</p>'),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          Text(
            'ALASAN',
            style:
                context.text.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: context.dp(12)),
            itemCount: listReason.length,
            itemBuilder: (context, index) {
              final optionLabel =
                  DataFormatter.formatHTMLAKM(listReason[index]['text']);
              final isSelected = _selectedAlasan[index] != -1;

              return OpsiCardItem(
                isEnabled: widget.onSimpanJawaban != null,
                isSelected: isSelected,
                isLastItem: (index == (listReason.length - 1)),
                isBolehLihatKunci: false,
                isKunciJawaban: false,
                opsiLabel: FittedBox(
                  child: Icon(
                    Icons.check_rounded,
                    color: (isSelected || widget.onSimpanJawaban != null)
                        ? context.onPrimary
                        : context.disableColor,
                  ),
                ),
                opsiText: optionLabel,
                onTap: widget.onSimpanJawaban != null
                    ? () {
                        setState(() {
                          _isOpsiSelected = false;
                          _selectedAlasanIndex = index;
                          _selectedJawaban = listReason[_selectedAlasanIndex!]
                                      ['isbenar'] ==
                                  true
                              ? 1
                              : 0;
                        });
                      }
                    : null,
              );
            },
          )
        ],
      ),
    );
  }
}
