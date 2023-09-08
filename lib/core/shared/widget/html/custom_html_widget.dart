import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';

import '../image/zoomable_image.dart';
import '../loading/shimmer_widget.dart';
import '../../../config/global.dart';
import '../../../config/extensions.dart';
import '../../../util/data_formatter.dart';

// TODO: Kemungkinan Widget ini akan di hapus, namun untuk penggantinya (widget_from_html.dart) masih dalam tahap tes.
/// [CustomHtml] digunakan di semua tempat kecuali pada
/// OpsiCardItem karena memiliki style berbeda.
class CustomHtml extends StatelessWidget {
  final String htmlString;
  final double? fontSize;
  final EdgeInsets? padding;
  final Map<String, Style>? extraStyle;
  final Map<String, Style>? replaceStyle;

  const CustomHtml(
      {Key? key,
      required this.htmlString,
      this.extraStyle,
      this.replaceStyle,
      this.fontSize,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      logger.log('CUSTOM_HTML_WIDGET-Build: Html String >> ${DataFormatter.formatHTMLAKM(htmlString)}');
    }
    Map<String, Style> defaultStyle = {
      "html": Style(padding: HtmlPaddings.zero),
      "body": Style(padding: HtmlPaddings.zero),
      "img": Style(padding: HtmlPaddings.zero),
      // "table": Style(width: Width(MediaQuery.of(context).size.width - 50)),
      // "tr": Style(
      //   border: Border(bottom: BorderSide(color: context.hintColor)),
      // ),
      // "th": Style(
      //   padding: HtmlPaddings.all(context.dp(6)),
      //   backgroundColor: context.primaryColor,
      //   color: context.onPrimary,
      // ),
      // "td": Style(
      //   padding: HtmlPaddings.all(context.dp(6)),
      //   alignment: Alignment.topLeft,
      // ),
    };

    if (fontSize != null) {
      defaultStyle.addAll({
        'p': Style(
          fontSize: FontSize(fontSize!),
          color: context.onBackground,
        )
      });
    }

    if (extraStyle != null) {
      defaultStyle.addAll(extraStyle!);
    }

    var htmlWidget = Html(
        shrinkWrap: true,
        data: DataFormatter.formatHTMLAKM(htmlString),
        extensions: [
          const TableHtmlExtension(),
          OnImageTapExtension(
            onImageTap: (src, imgAttributes, element) {
              final ImageProvider image = (src!.contains('base64')
                  ? MemoryImage(base64Decode(
                      src.substring('data:image/png;base64,'.length)))
                  : NetworkImage(src)) as ImageProvider;

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ZoomableImageWidget(imgUrl: src, imageProvider: image)),
              );
            },
          ),
          ImageExtension(
            handleAssetImages: false,
            handleDataImages: false,
            builder: (extensionContext) {
              final double? width =
                  double.tryParse(extensionContext.attributes['width'] ?? '');
              final double? height =
                  double.tryParse(extensionContext.attributes['height'] ?? '');
              final String imgUrl = extensionContext.attributes['src'] ??
                  'https://ganeshaoperation.com/img/logo5.png';

              final ImageProvider image = ((imgUrl.contains('base64'))
                  ? MemoryImage(base64Decode(
                      imgUrl.substring('data:image/png;base64,'.length)))
                  : NetworkImage(imgUrl)) as ImageProvider;

              var imageWidget = GestureDetector(
                onTap: () {
                  Navigator.push(
                    gNavigatorKey.currentState!.context,
                    MaterialPageRoute(
                      builder: (context) => ZoomableImageWidget(
                          imgUrl: imgUrl, imageProvider: image),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: image,
                    width: width,
                    height: height,
                    semanticLabel: (imgUrl.contains('base64'))
                        ? 'Html-Base64-Image'
                        : 'Html Image Network',
                    errorBuilder: (context, error, stackTrace) {
                      if (kDebugMode) {
                        logger.log(
                            'CUSTOM_HTML-Image: $error\nSTACKTRACE >> $stackTrace');
                      }

                      return Image.asset(
                        'assets/img/logo.webp',
                        width: context.dp(width ?? context.dw * 0.3),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) =>
                        (loadingProgress?.cumulativeBytesLoaded ==
                                loadingProgress?.expectedTotalBytes)
                            ? child
                            : ShimmerWidget.rounded(
                                width: width ?? context.dw * 0.3,
                                height: height ?? context.dw * 0.2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                  ),
                ),
              );

              return Hero(
                tag: imgUrl,
                transitionOnUserGestures: true,
                child: imageWidget,
              );
            },
          ),
        ],
        // onImageTap: (value, ctx, attr, elem) {
        //   final ImageProvider image = (value!.contains('base64')
        //       ? MemoryImage(base64Decode(
        //           value.substring('data:image/png;base64,'.length)))
        //       : NetworkImage(value)) as ImageProvider;
        //
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             ZoomableImageWidget(imgUrl: value, imageProvider: image)),
        //   );
        // },
        // customRenders: {
        //   (renderContext) => renderContext.tree.element?.localName == 'table':
        //       CustomRender.widget(
        //     widget: (renderContext, buildChildren) {
        //       final ScrollController scrollController = ScrollController();
        //
        //       return Scrollbar(
        //         controller: scrollController,
        //         thickness: 6,
        //         thumbVisibility: true,
        //         trackVisibility: true,
        //         radius: const Radius.circular(30),
        //         child: SizedBox(
        //           width: (context.isMobile)
        //               ? context.dw * 0.94
        //               : context.dw * 0.54,
        //           child: SingleChildScrollView(
        //             controller: scrollController,
        //             scrollDirection: Axis.horizontal,
        //             child: tableRender
        //                 .call()
        //                 .widget!
        //                 .call(renderContext, buildChildren),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        //   (context) => context.tree.element?.localName == 'img':
        //       CustomRender.widget(
        //     widget: (context, buildChildren) {
        //       double? width =
        //           double.tryParse(context.tree.attributes['width'] ?? '');
        //       double? height =
        //           double.tryParse(context.tree.attributes['height'] ?? '');
        //       String imgUrl = context.tree.attributes['src'] ??
        //           'https://ganeshaoperation.com/img/logo5.png';
        //
        //       final ImageProvider image = ((imgUrl.contains('base64'))
        //           ? MemoryImage(base64Decode(
        //               imgUrl.substring('data:image/png;base64,'.length)))
        //           : NetworkImage(imgUrl)) as ImageProvider;
        //
        //       var imageWidget = GestureDetector(
        //         onTap: () {
        //           Navigator.push(
        //             gNavigatorKey.currentState!.context,
        //             MaterialPageRoute(
        //                 builder: (context) => ZoomableImageWidget(
        //                     imgUrl: imgUrl, imageProvider: image)),
        //           );
        //         },
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(8),
        //           child: Image(
        //             image: image,
        //             width: width,
        //             height: height,
        //             semanticLabel: (imgUrl.contains('base64'))
        //                 ? 'Html-Base64-Image'
        //                 : 'Html Image Network',
        //             errorBuilder: (context, error, stackTrace) {
        //               if (kDebugMode) {
        //                 logger.log(
        //                     'CUSTOM_HTML-Image: $error\nSTACKTRACE >> $stackTrace');
        //               }
        //
        //               return Image.asset(
        //                 'assets/img/logo.webp',
        //                 width: context.dp(width ?? context.dw * 0.3),
        //               );
        //             },
        //             loadingBuilder: (context, child, loadingProgress) =>
        //                 (loadingProgress?.cumulativeBytesLoaded ==
        //                         loadingProgress?.expectedTotalBytes)
        //                     ? child
        //                     : ShimmerWidget.rounded(
        //                         width: width ?? context.dw * 0.3,
        //                         height: height ?? context.dw * 0.2,
        //                         borderRadius: BorderRadius.circular(8),
        //                       ),
        //           ),
        //         ),
        //       );
        //
        //       return Hero(
        //         tag: imgUrl,
        //         transitionOnUserGestures: true,
        //         child: imageWidget,
        //       );
        //     },
        //   ),
        // },
        style: replaceStyle ?? defaultStyle);

    return (padding != null)
        ? Padding(padding: padding!, child: htmlWidget)
        : htmlWidget;
  }
}

//
// (renderContext) => renderContext.tree.element?.localName == 'table':
// CustomRender.widget(
// widget: (renderContext, buildChildren) {
// final ScrollController scrollController = ScrollController();
//
// return Center(
// child: Scrollbar(
// controller: scrollController,
// thickness: 6,
// thumbVisibility: true,
// trackVisibility: true,
// radius: const Radius.circular(30),
// child: SizedBox(
// width: context.dw * 0.94,
// child: SingleChildScrollView(
// controller: scrollController,
// scrollDirection: Axis.horizontal,
// child: tableRender
//     .call()
//     .widget!
//     .call(renderContext, buildChildren),
// ),
// ),
// ),
// );
// },
// )
//
