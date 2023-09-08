import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../image/zoomable_image.dart';
import '../loading/shimmer_widget.dart';
import '../../../util/data_formatter.dart';
import '../../../config/extensions.dart';

/// [WidgetFromHtml] digunakan di semua tempat kecuali pada
/// OpsiCardItem karena memiliki style berbeda.
class WidgetFromHtml extends StatelessWidget {
  final String htmlString;
  final EdgeInsets? padding;

  const WidgetFromHtml({
    Key? key,
    required this.htmlString,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (kDebugMode) {
    //   logger.log(
    //       'CUSTOM_HTML_WIDGET-Build: Html String >> ${DataFormatter.formatHTMLAKM(htmlString)}');
    // }
    var htmlWidget = MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 0.8),
      child: HtmlWidget(
        DataFormatter.formatHTMLAKM(htmlString),
        enableCaching: true,
        renderMode: RenderMode.column,
        factoryBuilder: () => ScrollableTableFactory(),
        customStylesBuilder: (element) {
          var style = element.attributes['style'];
          Map<String, String> customStyle = {};

          // if (kDebugMode) {
          //   logger.log(
          //       'CUSTOM_HTML_WIDGET-CustomStylesBuilder: On Element $element');
          //   logger.log('Style Is td >> ${element.localName == 'td'}');
          //   logger.log('Custom Style >> style >> $style');
          // }

          if (element.localName == 'td') {
            List<String> conditions = ['0%px', '0%', '0px'];
            List<String> listStyle = style?.split(';') ?? [];
            List<String> styleKey = [];
            List<String> styleValue = [];

            for (var style in listStyle) {
              final keyValue = style.split(':');
              if (keyValue.length > 1) {
                styleKey.add(keyValue[0]);
                styleValue.add(keyValue[1]);
              }
            }
            // if (kDebugMode) {
            //   logger.log('Style Key >> $styleKey');
            //   logger.log('Style Value >> $styleValue');
            // }
            for (int i = 0; i < styleKey.length; i++) {
              final isWidthZero = conditions.contains(styleValue[i].trim());
              customStyle.putIfAbsent(
                  styleKey[i].trim(),
                  () => (isWidthZero && styleKey[i].trim() == 'width')
                      ? '30%'
                      : styleValue[i].trim());
            }
            if (kDebugMode) {
              logger.log('Custom Style >> $customStyle');
            }
            return customStyle;
          }

          return null;
        },
        customWidgetBuilder: (element) {
          // if (kDebugMode) {
          //   logger.log(
          //       'CUSTOM_HTML_WIDGET-CustomWidgetBuilder: On Element $element');
          //   logger.log(
          //     'ID ${element.id}\n'
          //     'styles ${element.styles}\n'
          //     'attributes ${element.attributes}\n'
          //     'attributeSpans ${element.attributeSpans}\n'
          //     'attributeValueSpans ${element.attributeValueSpans}\n'
          //     'sourceSpan ${element.sourceSpan}\n'
          //     'endSourceSpan ${element.endSourceSpan}\n'
          //     'localName ${element.localName}\n'
          //     'namespaceUri ${element.namespaceUri}\n'
          //     'nodeType ${element.nodeType}\n'
          //     'nodes ${element.nodes}\n'
          //     'firstChild ${element.firstChild}\n'
          //     'parent ${element.parent}\n'
          //     'parentNode ${element.parentNode}\n'
          //     'children ${element.children}\n',
          //   );
          // }
          // final styles = element.styles;
          // if (kDebugMode) {
          // logger.log('Is td >> ${element.localName == 'td'}');
          // for (var style in styles) {
          //   logger.log('--------------------------');
          //   logger.log('dartStyle >> ${style.dartStyle}');
          //   logger.log('hasDartStyle >> ${style.hasDartStyle}');
          //   logger.log('important >> ${style.important}');
          //   logger.log('isIE7 >> ${style.isIE7}');
          //   logger.log('property >> ${style.property}');
          //   logger.log('term >> ${style.term}');
          //   logger.log('value >> ${style.value?.span}');
          //   logger.log('values >> ${style.values}');
          //   logger.log('expression >> ${style.expression?.span}');
          //   logger.log('span >> ${style.span}');
          //   logger.log('--------------------------');
          // }
          // }
          // if (element.localName == 'p') {
          //   return Text(element.text, );
          // }
          // if (element.localName == 'table') {
          //   return ;
          // }

          return null;
        },
        onLoadingBuilder: (context, element, loadingProgress) => AspectRatio(
          aspectRatio: 9 / 16,
          child: ShimmerWidget.rounded(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onErrorBuilder: (context, element, error) {
          if (kDebugMode) {
            logger
                .log('CUSTOM_HTML_WIDGET-Error: On Element $element >> $error');
          }

          return const Text(
              'Gagal mengolah data HTML, silahkan hubungi CS di cabang terdekat.');
        },
        onTapImage: (imgMetadata) {
          List<ImageSource> src = imgMetadata.sources.toList();

          if (kDebugMode) {
            logger.log('CUSTOM_HTML_WIDGET-OnTapImage: sources >> $src');
          }

          if (src.isNotEmpty) {
            final url = src.first.url;

            final ImageProvider image = (url.contains('base64')
                ? MemoryImage(base64Decode(
                    url.substring('data:image/png;base64,'.length)))
                : NetworkImage(url)) as ImageProvider;

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ZoomableImageWidget(imgUrl: url, imageProvider: image)),
            );
          }
        },
      ),
    );

    return (padding != null)
        ? Padding(padding: padding!, child: htmlWidget)
        : htmlWidget;
  }
}

class ScrollableTableFactory extends WidgetFactory {
  @override
  void parse(BuildMetadata meta) {
    switch (meta.element.localName) {
      case 'table':
        meta.register(
          BuildOp(
            onWidgets: (meta, widgets) => listOrNull(
              widgets.first.wrapWith(
                (context, child) => ScrollableTableFromHtml(
                    element: meta.element, child: child),
              ),
            ),
          ),
        );
        break;
    }
    return super.parse(meta);
  }
}

class ScrollableTableFromHtml extends StatelessWidget {
  const ScrollableTableFromHtml({
    super.key,
    required this.child,
    required this.element,
  });

  final Widget child;
  final dom.Element element;

  @override
  Widget build(BuildContext context) {
    final double width = context.dw;
    final ScrollController scrollController = ScrollController();

    return _columnCount(element) <= 2
        ? child
        : Scrollbar(
            controller: scrollController,
            thickness: 6,
            thumbVisibility: true,
            trackVisibility: true,
            radius: const Radius.circular(30),
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: LimitedBox(maxWidth: width * 2, child: child),
            ),
          );
  }

  int _columnCount(dom.Element element) {
    final List<dom.Element> tableRows = element.getElementsByTagName('tr');

    return _getCountOrNullByTag(tableRows, 'th') ??
        _getCountOrNullByTag(tableRows, 'td') ??
        0;
  }

  int? _getCountOrNullByTag(List<dom.Element> tableRows, String tag) {
    if (tableRows.isEmpty) return null;

    final int count = tableRows.first.getElementsByTagName(tag).length;
    return count != 0 ? count : null;
  }
}
