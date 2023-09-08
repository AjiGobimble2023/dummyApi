import 'package:flutter/material.dart';

import '../../../model/feedback_question.dart';
import '../../../../../core/config/extensions.dart';

class FeedbackQuestionTextWidget extends StatefulWidget {
  final bool isDone;
  final FeedbackQuestion feedbackQuestion;
  final void Function(String selected)? onChanged;
  final FocusNode textFocusNode;
  const FeedbackQuestionTextWidget(
      this.isDone, this.feedbackQuestion, this.textFocusNode,
      {Key? key, this.onChanged})
      : super(key: key);

  @override
  State<FeedbackQuestionTextWidget> createState() =>
      _FeedbackQuestionTextWidgetState();
}

class _FeedbackQuestionTextWidgetState
    extends State<FeedbackQuestionTextWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.feedbackQuestion.answer ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 22,
              child: Text("6) "),
            ),
            Flexible(
              child: Text(
                widget.feedbackQuestion.question,
                style: context.text.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            focusNode: widget.textFocusNode,
            enabled: !widget.isDone,
            controller: _textEditingController,
            minLines: 3,
            maxLines: 20,
            maxLength: 500,
            style: context.text.bodyMedium,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              fillColor: context.background,
              hintText: 'Ketikan materi disini',
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              counterText: "${_textEditingController.text.length}/500",
              counterStyle:
                  context.text.labelSmall?.copyWith(color: context.hintColor),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            ),
            onChanged: (val) {
              widget.onChanged!(_textEditingController.text.trim());
            },
          ),
        ),
      ],
    );
  }
}
