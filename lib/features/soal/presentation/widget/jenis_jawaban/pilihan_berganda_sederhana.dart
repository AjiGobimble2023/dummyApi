import 'package:flutter/material.dart';

import 'opsi_card_item.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/util/data_formatter.dart';

class PilihanBergandaSederhana extends StatefulWidget {
  final Map<String, dynamic> jsonOpsiJawaban;
  final String? jawabanSebelumnya;
  final String? kunciJawaban;
  final bool isBolehLihatKunci;
  final void Function(String pilihanJawaban)? onClickPilihJawaban;

  const PilihanBergandaSederhana({
    Key? key,
    required this.jsonOpsiJawaban,
    this.jawabanSebelumnya,
    this.onClickPilihJawaban,
    required this.isBolehLihatKunci,
    this.kunciJawaban,
  }) : super(key: key);

  @override
  State<PilihanBergandaSederhana> createState() =>
      _PilihanBergandaSederhanaState();
}

class _PilihanBergandaSederhanaState extends State<PilihanBergandaSederhana> {
  late final ValueNotifier<String> _selectedOpsi =
      ValueNotifier(widget.jawabanSebelumnya ?? '');

  @override
  Widget build(BuildContext context) {
    _selectedOpsi.value = widget.jawabanSebelumnya ?? '';
    widget.jsonOpsiJawaban.removeWhere(
      (_, value) => (value == null ||
          value == '' ||
          value == '-' ||
          value == '<p></p>' ||
          value == '<p>-</p>'),
    );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: context.dp(6)),
      itemCount: widget.jsonOpsiJawaban.length,
      itemBuilder: (_, index) {
        final opsi = widget.jsonOpsiJawaban.keys.elementAt(index);
        final jawabanText = DataFormatter.formatHTMLAKM(
            widget.jsonOpsiJawaban[opsi].toString());

        return ValueListenableBuilder<String>(
          valueListenable: _selectedOpsi,
          builder: (context, selectedOpsi, _) => OpsiCardItem(
            isKunciJawaban: opsi == widget.kunciJawaban,
            isBolehLihatKunci: widget.isBolehLihatKunci,
            isEnabled: widget.onClickPilihJawaban != null,
            isSelected: selectedOpsi == opsi,
            isLastItem: (index == (widget.jsonOpsiJawaban.length - 1)),
            opsiLabel: Text(
              opsi,
              style: context.text.titleLarge?.copyWith(
                  color: (selectedOpsi == opsi)
                      ? context.onPrimary
                      : (widget.onClickPilihJawaban != null)
                          ? context.primaryColor
                          : context.background),
            ),
            opsiText: jawabanText,
            onTap: widget.onClickPilihJawaban != null
                ? () {
                    _selectedOpsi.value =
                        (_selectedOpsi.value == opsi) ? '' : opsi;
                    if (widget.onClickPilihJawaban != null) {
                      widget.onClickPilihJawaban!(_selectedOpsi.value);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}
