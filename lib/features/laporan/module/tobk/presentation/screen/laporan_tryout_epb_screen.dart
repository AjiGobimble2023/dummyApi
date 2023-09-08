import 'package:flutter/material.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../provider/laporan_tryout_provider.dart';

class LaporanTryoutEPBScreen extends StatefulWidget {
  const LaporanTryoutEPBScreen({
    Key? key,
    required this.title,
    required this.link,
  }) : super(key: key);
  final String title;
  final String link;

  @override
  State<LaporanTryoutEPBScreen> createState() => _LaporanTryoutEPBScreenState();
}

class _LaporanTryoutEPBScreenState extends State<LaporanTryoutEPBScreen> {
  /// [_pdfViewerController] controller untuk penampil PDF.
  late PdfViewerController _pdfViewerController;

  /// [_pdfViewerStateKey] digunakan untuk mengakses keadaan penampil PDF.
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: widget.title,
      body: SafeArea(
        child: Builder(
          builder: (context) => FutureBuilder<String>(
            future: context.read<LaporanTryoutProvider>().fetchEpbToken(),
            builder: (context, tokenSnapshot) => (tokenSnapshot
                        .connectionState ==
                    ConnectionState.done)
                ? (widget.link.isNotEmpty)
                    ? SfPdfViewer.network(
                        widget.link,
                        headers: {
                          "secretkey": tokenSnapshot.data!,
                          "credentialauth": dotenv.env['CREDENTIAL_AUTH']!
                        },
                        controller: _pdfViewerController,
                        key: _pdfViewerStateKey,
                        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                          const LoadingWidget();
                        },
                        currentSearchTextHighlightColor: context.secondaryColor,
                        onDocumentLoadFailed:
                            (PdfDocumentLoadFailedDetails details) {
                          NoDataFoundWidget(
                              subTitle: "Data tidak ditemukan",
                              emptyMessage: details.error);
                        },
                      )
                    : const NoDataFoundWidget(
                        subTitle: "Data tidak ditemukan",
                        emptyMessage:
                            "Laporan EPB Sobat tidak ditemukan, silahkan hubungi customer service ya Sobat")
                : const LoadingWidget(),
          ),
        ),
      ),
    );
  }
}
