import 'package:flutter/material.dart';

import 'opsi_card_item.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/util/data_formatter.dart';

class PilihanBergandaKompleks extends StatefulWidget {
  final Map<String, dynamic> jsonOpsiJawaban;
  final List<String>? jawabanSebelumnya;
  final List<String>? kunciJawaban;
  final bool isBolehLihatKunci;
  final void Function(List<String> selected)? onClickPilihJawaban;

  const PilihanBergandaKompleks(
      {Key? key,
      required this.jsonOpsiJawaban,
      this.jawabanSebelumnya,
      this.onClickPilihJawaban,
      this.kunciJawaban,
      required this.isBolehLihatKunci})
      : super(key: key);

  @override
  State<PilihanBergandaKompleks> createState() =>
      _PilihanBergandaKompleksState();
}

class _PilihanBergandaKompleksState extends State<PilihanBergandaKompleks> {
  List<String> _listSelectedJawaban = [];
  String _selectedJawaban = '';

  bool _setSelectedJawaban(String selected) {
    if (selected.isEmpty) return false;
    if (_listSelectedJawaban.contains(selected)) {
      _listSelectedJawaban.removeWhere((answer) => answer == selected);
      return true;
    }
    _listSelectedJawaban.add(selected);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    widget.jsonOpsiJawaban.removeWhere(
      (_, value) => (value == null ||
          value == '' ||
          value == '-' ||
          value == '<p></p>' ||
          value == '<p>-</p>'),
    );

    if (widget.jawabanSebelumnya != null && _selectedJawaban.isEmpty) {
      _listSelectedJawaban = widget.jawabanSebelumnya!;
    } else if (_selectedJawaban.isNotEmpty) {
      final bool isUbahJawabanBerhasil = _setSelectedJawaban(_selectedJawaban);
      if (widget.onClickPilihJawaban != null && isUbahJawabanBerhasil) {
        widget.onClickPilihJawaban!(_listSelectedJawaban);
      }
      _selectedJawaban = '';
    } else {
      _listSelectedJawaban = [];
      _selectedJawaban = '';
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: context.dp(6)),
      itemCount: widget.jsonOpsiJawaban.length,
      itemBuilder: (_, index) {
        final opsi = widget.jsonOpsiJawaban.keys.elementAt(index);
        final jawabanText = DataFormatter.formatHTMLAKM(
            widget.jsonOpsiJawaban[opsi].toString());
        final isSelected = _listSelectedJawaban.contains(opsi);

        return OpsiCardItem(
          isEnabled: widget.onClickPilihJawaban != null,
          isSelected: isSelected,
          isLastItem: (index == (widget.jsonOpsiJawaban.length - 1)),
          isBolehLihatKunci: widget.isBolehLihatKunci,
          isKunciJawaban: widget.kunciJawaban?.contains(opsi) ?? false,
          opsiLabel: Text(
            opsi,
            style: context.text.titleLarge?.copyWith(
                color: isSelected
                    ? context.onPrimary
                    : (widget.onClickPilihJawaban != null)
                        ? context.primaryColor
                        : context.background),
          ),
          opsiText: jawabanText,
          onTap: widget.onClickPilihJawaban != null
              ? () {
                  setState(() {
                    _selectedJawaban = opsi;
                  });
                }
              : null,
        );
      },
    );
  }
}
