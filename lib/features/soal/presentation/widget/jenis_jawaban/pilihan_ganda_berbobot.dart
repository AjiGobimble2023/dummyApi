import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'opsi_card_item.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/util/data_formatter.dart';

class PilihanGandaBerbobot extends StatefulWidget {
  final Map<String, dynamic> jsonOpsiJawaban;
  final String? jawabanSebelumnya;
  final String? kunciJawaban;
  final bool isBolehLihatKunci;
  final void Function(String pilihanJawaban)? onClickPilihJawaban;

  const PilihanGandaBerbobot({
    Key? key,
    required this.jsonOpsiJawaban,
    this.jawabanSebelumnya,
    this.kunciJawaban,
    this.onClickPilihJawaban,
    required this.isBolehLihatKunci,
  }) : super(key: key);

  @override
  State<PilihanGandaBerbobot> createState() => _PilihanGandaBerbobotState();
}

class _PilihanGandaBerbobotState extends State<PilihanGandaBerbobot> {
  late final ValueNotifier<String> _selectedOpsi =
      ValueNotifier(widget.jawabanSebelumnya ?? '');

  @override
  Widget build(BuildContext context) {
    _selectedOpsi.value = widget.jawabanSebelumnya ?? '';
    widget.jsonOpsiJawaban.removeWhere(
      (_, value) => (value == null ||
          value['text'] == null ||
          value['text'] == '' ||
          value['text'] == '-' ||
          value['text'] == '<p></p>' ||
          value['text'] == '<p>-</p>'),
    );

    if (kDebugMode) {
      logger.log('PGB_SCREEN-Build: kunciJawaban >> ${widget.kunciJawaban}');
      logger.log(
          'PGB_SCREEN-Build: jawaban sebelumnya >> ${widget.jawabanSebelumnya}');
      logger.log('PGB_SCREEN-Build: selected opsi >> ${_selectedOpsi.value}');
      logger.log('PGB_SCREEN-Build: json opsi >> ${widget.jsonOpsiJawaban}');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: context.dp(6)),
      itemCount: widget.jsonOpsiJawaban.length,
      itemBuilder: (_, index) {
        final opsi = widget.jsonOpsiJawaban.keys.elementAt(index);
        final jawabanText = DataFormatter.formatHTMLAKM(
            widget.jsonOpsiJawaban[opsi]['text'].toString());

        return ValueListenableBuilder<String>(
          valueListenable: _selectedOpsi,
          builder: (context, selectedOpsi, _) => OpsiCardItem(
            isEnabled: widget.onClickPilihJawaban != null,
            isSelected: selectedOpsi == opsi,
            isBolehLihatKunci: widget.isBolehLihatKunci,
            isKunciJawaban: opsi == widget.kunciJawaban,
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
