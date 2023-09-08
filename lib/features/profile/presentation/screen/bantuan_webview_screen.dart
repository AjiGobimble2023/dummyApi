// import 'dart:io';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';

class BantuanWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const BantuanWebViewScreen({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<BantuanWebViewScreen> createState() => _BantuanWebViewScreenState();
}

class _BantuanWebViewScreenState extends State<BantuanWebViewScreen> {
  late final WebViewController _webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(context.background)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) => setState(() => _loadingPercentage = 0),
        onProgress: (progress) => setState(() => _loadingPercentage = progress),
        onPageFinished: (url) {
          _webViewController.runJavaScript(
              "document.getElementsByTagName('nav')[0].style.display='none'");
          _webViewController.runJavaScript(
              "document.getElementsByTagName('footer')[0].style.display='none'");
          setState(() => _loadingPercentage = 100);
        },
        onNavigationRequest: (NavigationRequest request) async {
          if (request.url.contains('ganeshaoperation.com')) {
            if (kDebugMode) {
              logger.log('allowing navigation to $request');
            }
            return NavigationDecision.navigate;
          }
          if (request.url.startsWith('https://api.whatsapp.com/send?phone')) {
            if (kDebugMode) {
              logger.log('blocking navigation to $request');
            }

            String phone = "628112468988";
            String message =
                "Hallo Admin Ganesha Operation, Saya ingin bertanya terkait";

            String whatsappUrl =
                'https://wa.me/$phone/?text=${Uri.parse(message)}';

            await _launchURL(Uri.parse(whatsappUrl));
          } else {
            await _launchURL(Uri.parse(request.url));
          }
          return NavigationDecision.prevent;
        },
      ),
    )
    ..loadRequest(Uri.parse(widget.url));

  var _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      gShowTopFlash(context, 'Gagal membuka laman, coba lagi!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: context.background,
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        leading: IconButton(
          padding: EdgeInsets.only(
            left: min(28, context.dp(24)),
            right: min(16, context.dp(12)),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_loadingPercentage < 100)
            LinearProgressIndicator(
              value: _loadingPercentage / 100.0,
              backgroundColor: context.hintColor,
              minHeight: 4,
            ),
        ],
      ),
    );
  }
}
