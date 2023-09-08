import 'package:flutter/material.dart';
import '../../../../core/shared/screen/basic_screen.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/global.dart';
import '../provider/feedback_provider.dart';
import '../widget/feedback_widget.dart';

class FeedbackScreen extends StatefulWidget {
  final String idRencana;
  final String namaPengajar;
  final String kelas;
  final String tanggal;
  final String flag;
  final String mapel;
  final bool done;
  const FeedbackScreen(
      {Key? key,
      required this.idRencana,
      required this.namaPengajar,
      required this.kelas,
      required this.tanggal,
      required this.flag,
      required this.mapel,
      required this.done})
      : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int checkAnswer = 0;
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await context
          .read<FeedbackProvider>()
          .loadFeedbackQuestion(gNoRegistrasi, widget.idRencana);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Feedback Pengajaran',
      body: SafeArea(
        child: ChangeNotifierProvider<FeedbackProvider>(
          create: (_) => FeedbackProvider(),
          child: FeedbackWidget(
            idRencana: widget.idRencana,
            namaPengajar: widget.namaPengajar,
            tanggal: widget.tanggal,
            mapel: widget.mapel,
            kelas: widget.kelas,
            flag: widget.flag,
            done: widget.done,
          ),
        ),
      ),
    );
  }
}
