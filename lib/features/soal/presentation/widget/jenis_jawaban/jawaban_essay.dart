import 'package:flutter/material.dart';

import 'text_field_essay.dart';
import '../../../../../core/config/enum.dart';
import '../../../../../core/config/global.dart';

class JawabanEssay extends StatefulWidget {
  final String? jawabanSebelumnya;
  final void Function(String)? onSimpanJawaban;

  const JawabanEssay({Key? key, this.jawabanSebelumnya, this.onSimpanJawaban})
      : super(key: key);

  @override
  State<JawabanEssay> createState() => _JawabanEssayState();
}

class _JawabanEssayState extends State<JawabanEssay> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  // ignore: prefer_final_fields
  String _tempAnswer = '';

  bool checkAnswer(String answer) {
    if (_tempAnswer.toLowerCase() != answer.toLowerCase()) {
      _tempAnswer = answer;
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _textEditingController.text = widget.jawabanSebelumnya ?? '';
    _tempAnswer = widget.jawabanSebelumnya ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) => mounted ? super.setState(() => fn()) : fn();

  @override
  Widget build(BuildContext context) {
    return TextFieldEssay(
      enable: widget.onSimpanJawaban != null,
      focusNode: _focusNode,
      controller: _textEditingController,
      onSubmit: (widget.onSimpanJawaban != null)
          ? (isiJawaban) {
              _focusNode.unfocus();

              if (isiJawaban.isEmpty) {
                gShowBottomDialogInfo(
                  context,
                  message:
                      'Jika kamu ingin menyimpan jawaban soal ini mohon untuk mengisinya, jika tidak silakan lewati soal ini dan biarkan kosong',
                );
                return;
              }

              if (widget.onSimpanJawaban == null) {
                gShowTopFlash(
                  context,
                  'Kamu sudah mengumpulkan jawaban soal ini!',
                  dialogType: DialogType.error,
                );
                return;
              }

              if (checkAnswer(isiJawaban)) {
                widget.onSimpanJawaban!(isiJawaban);

                gShowTopFlash(
                  context,
                  'Jawaban essay untuk soal ini telah disimpan',
                  dialogType: DialogType.info,
                );
                return;
              }

              gShowTopFlash(
                context,
                'Jawaban sama dengan yang sebelumnya',
                dialogType: DialogType.warning,
              );
            }
          : null,
    );
  }
}
