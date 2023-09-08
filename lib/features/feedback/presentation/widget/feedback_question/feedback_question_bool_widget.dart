import 'package:flutter/material.dart';
import '../../../../../core/config/extensions.dart';

import '../../../model/feedback_question.dart';

class FeedbackQuestionBoolWidget extends StatefulWidget {
  final int index;
  final bool isDone;
  final FeedbackQuestion feedbackQuestion;
  final void Function(String selected)? onSelected;
  const FeedbackQuestionBoolWidget(
      this.isDone, this.feedbackQuestion, this.index,
      {Key? key, this.onSelected})
      : super(key: key);

  @override
  State<FeedbackQuestionBoolWidget> createState() =>
      _FeedbackQuestionBoolWidgetState();
}

class _FeedbackQuestionBoolWidgetState
    extends State<FeedbackQuestionBoolWidget> {
  String charAnswer = "na";

  @override
  void initState() {
    super.initState();
    charAnswer = widget.feedbackQuestion.answer ?? "na";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.dw,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 22, child: Text("${widget.index + 1}) ")),
                Expanded(
                  child: Text(
                    widget.feedbackQuestion.question,
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              Container(
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
                child: GestureDetector(
                  onTap: () {
                    if (!widget.isDone) {
                      setState(() {
                        charAnswer = 'y';
                        widget.onSelected!(charAnswer);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: charAnswer == 'y'
                            ? Colors.green
                            : context.background,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: charAnswer == 'y'
                                ? Colors.green
                                : Colors.grey.withOpacity(0.5),
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ]),
                    child: Icon(
                      Icons.check,
                      color: charAnswer == 'y'
                          ? context.background
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  if (!widget.isDone) {
                    setState(() {
                      charAnswer = 'n';
                      widget.onSelected!(charAnswer);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: charAnswer == 'n'
                          ? context.primaryColor
                          : context.background,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: charAnswer == 'n'
                              ? context.primaryColor
                              : Colors.grey.withOpacity(0.5),
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ]),
                  child: Icon(
                    Icons.close,
                    color: charAnswer == 'n'
                        ? context.background
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
