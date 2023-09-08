// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'feedback_question/feedback_question_bool_widget.dart';
import 'feedback_question/feedback_question_text_widget.dart';
import '../provider/feedback_provider.dart';
import '../../model/feedback_question.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/shared/widget/dialog/custom_dialog.dart';
import '../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../core/shared/widget/exception/exception_widget.dart';

class FeedbackWidget extends StatefulWidget {
  final String idRencana;
  final String namaPengajar;
  final String kelas;
  final String tanggal;
  final String flag;
  final String mapel;
  final bool done;

  FeedbackWidget({
    Key? key,
    required this.idRencana,
    required this.namaPengajar,
    required this.kelas,
    required this.tanggal,
    required this.flag,
    required this.mapel,
    required this.done,
  }) : super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  Future<List<FeedbackQuestion>>? _futureLoadQuestion;
  String? _userId;
  late bool _done = widget.done;
  late FocusNode textFocusNode;
  late final AuthOtpProvider _authProvider = context.read<AuthOtpProvider>();

  Widget _buildInformationItem(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "$label : ",
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: context.text.bodyMedium?.copyWith(
                color: context.hintColor,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  void _onButtonPressed(String userId, String idRencana) async {
    try {
      FocusScope.of(context).unfocus();
      CustomDialog.loadingDialog(context);
      await context.read<FeedbackProvider>().saveFeedback(userId, idRencana);
      Navigator.pop(context);
      setState(() {
        _done = true;
      });
      gShowTopFlash(context, 'Feedback berhasil disimpan',
          dialogType: DialogType.success);
    } on NoConnectionException catch (_) {
      Navigator.pop(context);
      CustomDialog.connectionExceptionDialog(context);
    } on DataException catch (e) {
      Navigator.pop(context);
      gShowBottomDialog(context,
          message: e.toString(), dialogType: DialogType.warning);
    } catch (e) {
      Navigator.pop(context);

      CustomDialog.fatalExceptionDialog(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _userId = _authProvider.userData!.noRegistrasi;
    _futureLoadQuestion = context
        .read<FeedbackProvider>()
        .loadFeedbackQuestion(_userId!, widget.idRencana);
    textFocusNode = FocusNode();
  }

  @override
  void dispose() {
    textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedbackQuestion>>(
      future: _futureLoadQuestion,
      builder: (context, feedbackSnapshot) => feedbackSnapshot
                  .connectionState ==
              ConnectionState.done
          ? feedbackSnapshot.hasError
              ? ExceptionWidget(
                  feedbackSnapshot.error.toString(),
                  exceptionMessage: feedbackSnapshot.error.toString(),
                )
              : feedbackSnapshot.hasData
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 16,
                          left: 16,
                          top: 16,
                          bottom: 10,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.background,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildIcon(context, "Informasi Kelas"),
                                  _buildInformationItem('Kelas', widget.kelas),
                                  _buildInformationItem(
                                      'Kelompok Ujian', widget.mapel),
                                  _buildInformationItem(
                                      'Pengajar', widget.namaPengajar),
                                  _buildInformationItem(
                                    'Tanggal',
                                    DateFormat.yMMMMd('ID').format(
                                      DateTime.parse(
                                        widget.tanggal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            SizedBox(height: 5.0),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              decoration: BoxDecoration(
                                color: context.background,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildIcon(context, "Pertanyaan"),
                                  Text(
                                    'Berikut ini pertanyaan untuk feedback pengajar yang masuk sesuai dengan infomasi yang tercantum di atas.',
                                    style: context.text.labelLarge
                                        ?.copyWith(color: context.hintColor),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: feedbackSnapshot.data!.length,
                                    itemBuilder: (ctx, index) =>
                                        feedbackSnapshot.data![index].type ==
                                                'switch'
                                            ? Container(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child:
                                                    FeedbackQuestionBoolWidget(
                                                  _done,
                                                  feedbackSnapshot.data![index],
                                                  index,
                                                  onSelected: (val) {
                                                    context
                                                        .read<
                                                            FeedbackProvider>()
                                                        .setJawaban(index, val);
                                                  },
                                                ),
                                              )
                                            : FeedbackQuestionTextWidget(
                                                _done,
                                                feedbackSnapshot.data![index],
                                                textFocusNode,
                                                onChanged: (val) {
                                                  context
                                                      .read<FeedbackProvider>()
                                                      .setJawaban(index, val);
                                                },
                                              ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_done)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    List<FeedbackQuestion> listAnswer = context
                                        .read<FeedbackProvider>()
                                        .listPertanyaan;
                                    int checkAnswer = 0;
                                    for (int i = 0;
                                        i < listAnswer.length;
                                        i++) {
                                      if (listAnswer[i].answer == "na" ||
                                          listAnswer[i].answer == "") {
                                        checkAnswer++;
                                      }
                                    }
                                    if (checkAnswer == 0) {
                                      _onButtonPressed(
                                          _userId!, widget.idRencana);
                                    } else {
                                      textFocusNode.requestFocus();
                                      gShowBottomDialogInfo(context,
                                          message:
                                              "Sobat belum menjawab seluruh pertanyaan!");
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: context.secondaryColor,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.secondaryColor
                                              .withOpacity(0.5),
                                          blurRadius: 7,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "Simpan",
                                      style: context.text.bodyMedium,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    )
                  : ExceptionWidget(
                      'Belum ada data untuk saat ini',
                      exceptionMessage: 'Belum ada data untuk saat ini',
                    )
          : LoadingWidget(),
    );
  }

  _buildIcon(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              margin: EdgeInsets.only(right: context.dp(12)),
              decoration: BoxDecoration(
                  color: context.tertiaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(-1, -1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42)),
                    BoxShadow(
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42))
                  ]),
              child: Icon(
                (title == "Informasi Kelas")
                    ? Icons.info_outlined
                    : Icons.question_mark,
                size: context.dp(22),
                color: context.onTertiary,
              ),
            ),
            Text(
              title,
              style: context.text.labelLarge,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Divider(),
        )
      ],
    );
  }
}
