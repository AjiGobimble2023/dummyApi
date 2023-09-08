import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/config/global.dart';
import 'package:provider/provider.dart';

import '../provider/feed_provider.dart';
import '../../../../../../core/config/extensions.dart';

class FeedCommentTextInput extends StatefulWidget {
  final String feedId;
  final String feedCreator;
  final String? parentId;
  final String? parentCreator;
  final String? creatorName;
  final bool? reply;

  const FeedCommentTextInput(
      {Key? key,
      required this.feedId,
      required this.feedCreator,
      this.parentCreator,
      this.creatorName,
      this.parentId,
      this.reply = false})
      : super(key: key);

  @override
  State<FeedCommentTextInput> createState() => _FeedCommentTextInputState();
}

class _FeedCommentTextInputState extends State<FeedCommentTextInput> {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  bool? reply;
  @override
  void initState() {
    if (kDebugMode) {
      logger.log("Cek feedid ${widget.feedId}");
    }
    _textController.addListener(() {
      final String text = _textController.text;
      _textController.value = _textController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    if (widget.reply!) {
      _focusNode.requestFocus();
    }
    reply = widget.reply!;
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reply!)
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Text("Membalas ${widget.creatorName}"),
                    const Spacer(),
                    InkWell(
                        onTap: () {
                          setState(() {
                            reply = false;
                          });
                        },
                        child: const Icon(Icons.close))
                  ],
                ),
              ),
              const Divider(
                height: 0,
              )
            ],
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: kElevationToShadow[2],
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
                margin: const EdgeInsets.only(
                  left: 16,
                  bottom: 16,
                  right: 8,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 4,
                ),
                child: TextField(
                  focusNode: _focusNode,
                  controller: _textController,
                  style: const TextStyle(fontSize: 15),
                  textInputAction: TextInputAction.send,
                  inputFormatters: [
                    NoLeadingSpaceFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: "Tulis komentar",
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  maxLength: 500,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                (_textController.text.isEmpty)
                    ? Container()
                    : context.read<FeedProvider>().saveComment(
                          userId: gNoRegistrasi,
                          feedId: widget.feedId,
                          feedCreator: widget.feedCreator,
                          text: _textController.text,
                        );
                setState(() {
                  onRefreshComment();
                  _textController.text = "";
                });
                _focusNode.unfocus();
              },
              child: Container(
                padding: const EdgeInsets.all(
                  6,
                ),
                margin: const EdgeInsets.only(
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(300),
                  boxShadow: kElevationToShadow[2],
                ),
                child: Container(
                  padding: const EdgeInsets.all(
                    4,
                  ),
                  margin: const EdgeInsets.all(
                    4,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  onRefreshComment() async {
    if (reply!) {
      await context.read<FeedProvider>().loadComment(
            userId: gNoRegistrasi,
            feedId: widget.parentId,
          );
    } else {
      await context.read<FeedProvider>().loadComment(
            userId: gNoRegistrasi,
            feedId: widget.feedId,
          );
    }
  }
}

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(' ')) {
      final String trimedText = newValue.text.trimLeft();

      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }

    return newValue;
  }
}
