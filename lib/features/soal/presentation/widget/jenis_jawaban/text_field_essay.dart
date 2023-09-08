import 'package:flutter/material.dart';

import '../../../../../core/config/extensions.dart';

class TextFieldEssay extends StatelessWidget {
  final String? soalText;
  final bool enable;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onSubmit;

  const TextFieldEssay({
    Key? key,
    this.soalText,
    this.enable = true,
    this.controller,
    this.onSubmit,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: context.dp(4), bottom: context.dp(18), right: context.dp(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (soalText != null) Text(soalText!),
          if (soalText != null) SizedBox(height: context.dp(8)),
          TextFormField(
            enabled: enable,
            readOnly: !enable,
            minLines: 5,
            maxLines: 10,
            focusNode: focusNode,
            controller: controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: onSubmit,
            style: context.text.bodyMedium,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  vertical: context.dp(8), horizontal: context.dp(12)),
              hintText: 'Ketik jawaban kamu di sini',
              hintStyle:
                  context.text.bodyMedium?.copyWith(color: context.hintColor),
              helperText: 'Klik enter untuk menyimpan jawaban',
              helperStyle: context.text.bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.hintColor, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
