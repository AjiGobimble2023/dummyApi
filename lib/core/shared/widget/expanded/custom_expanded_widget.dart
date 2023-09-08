import 'package:flutter/material.dart';

import '../../../config/extensions.dart';

part 'expand_indicator.dart';
part 'indicator_builder.dart';

/// This widget unfolds a hidden widget to the user, called [child].
/// This action is performed when the user clicks the 'expand' indicator.
/// Widget dari: https://pub.dev/packages/expand_widget
class CustomExpandedWidget extends StatefulWidget {
  /// This widget will be displayed if the user clicks the 'expand' indicator.
  final Widget child;

  /// Direction of exapnsion, vertical by default.
  final Axis direction;

  /// Method to override the [ExpandIndicator] widget for expanding the content.
  final IndicatorBuilder? indicatorBuilder;

  /// Percentage of how much of the 'hidden' widget is show when collapsed.
  /// Defaults to `0.0`.
  final double collapsedVisibilityFactor;

  /// Adjust horizontal alignment of the indicator.
  final Alignment? indicatorAlignment;

  final Widget? leadingItem;
  final String title;
  final String subTitle;
  final double? shaderStart;
  final int moreItemCount;
  final bool useBottomIndicator;
  final EdgeInsetsGeometry? headerPadding;

  const CustomExpandedWidget({
    super.key,
    required this.child,
    this.direction = Axis.vertical,
    this.indicatorBuilder,
    this.collapsedVisibilityFactor = 0,
    this.indicatorAlignment,
    this.leadingItem,
    required this.title,
    required this.subTitle,
    this.headerPadding,
    this.shaderStart,
    required this.moreItemCount,
    this.useBottomIndicator = true,
  }) : assert(
          collapsedVisibilityFactor >= 0 && collapsedVisibilityFactor <= 1,
          'The parameter collapsedHeightFactor must lay between 0 and 1',
        );

  @override
  State<StatefulWidget> createState() => _CustomExpandedWidgetState();
}

class _CustomExpandedWidgetState extends State<CustomExpandedWidget>
    with TickerProviderStateMixin {
  /// Custom animation curve for indicator icon controll.
  static final _easeInCurve = CurveTween(curve: Curves.easeInOutCubic);

  /// Controlls the rotation of the indicator icon widget.
  static final _halfTurn = Tween<double>(begin: 0, end: 0.5);

  /// General animation controller.
  late AnimationController _controller;

  /// General animation controller.
  late AnimationController _controllerBottom;

  /// Animations for height/width control.
  late Animation<double> _expandFactor;

  /// Animations for height/width control.
  late Animation<double> _expandFactorBottom;

  /// Animations for indicator icon's rotation control.
  late Animation<double> _iconTurns;

  /// Auxiliary variable to controll expand status.
  var _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Initializing the animation controller with the [duration] parameter
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controllerBottom = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initializing both animations, depending on the [_easeInCurve] curve
    _expandFactor = _controller.drive(
      Tween<double>(
        begin: widget.collapsedVisibilityFactor,
        end: 1,
      ).chain(_easeInCurve),
    );
    _expandFactorBottom = _controllerBottom.drive(
      Tween<double>(begin: 0, end: 1).chain(_easeInCurve),
    );
    _iconTurns = _controller.drive(_halfTurn.chain(_easeInCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerBottom.dispose();

    super.dispose();
  }

  /// Method called when the user clicks on the expand indicator
  void _handleTap() => setState(() {
        _isExpanded = !_isExpanded;
        _isExpanded ? _controllerBottom.forward() : _controllerBottom.reverse();
        _isExpanded ? _controller.forward() : _controller.reverse();
      });

  /// Builds the widget itself. If the [_isExpanded] parameter is 'true',
  /// the [child] parameter will contain the child information, passed to
  /// this instance of the object.
  Widget _buildChild(BuildContext context, Widget? child) {
    // log('TEST Bottom value >> ${_expandFactorBottom.value}');
    return Flex(
      direction: widget.direction,
      children: [
        _ExpandChildIndicator(
          heightIndicatorFactor: 1.0,
          alignment: widget.indicatorAlignment,
          child:
              widget.indicatorBuilder?.call(context, _handleTap, _isExpanded) ??
                  _buildDefaultHeader(context),
        ),
        _ExpandChildContent(
          value: _controller.value,
          direction: widget.direction,
          shaderStart: _isExpanded ? 1 : widget.shaderStart,
          heightFactor:
              widget.direction == Axis.vertical ? _expandFactor.value : null,
          widthFactor:
              widget.direction == Axis.horizontal ? _expandFactor.value : null,
          child: child,
        ),
        if (widget.useBottomIndicator)
          _ExpandChildIndicator(
            heightIndicatorFactor: 1.0 - ((_isExpanded) ? _expandFactorBottom.value : 0.0),
            alignment: Alignment.center,
            child: AnimatedOpacity(
              duration: _controllerBottom.duration!,
              opacity: (_isExpanded) ? 0 : 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${widget.moreItemCount} lagi',
                  style: context.text.labelSmall?.copyWith(
                    color: context.hintColor,
                  ),
                ),
              ),
            ),
          ),
        // if (widget.useBottomIndicator)
        //   AnimatedScale(
        //     scale: (!_isExpanded) ? 1.0 : 0.0,
        //     duration: Duration(milliseconds: 1300),
        //     alignment: Alignment.topCenter,
        //     child: Padding(
        //       padding: const EdgeInsets.only(bottom: 6),
        //       child: Text(
        //               '${widget.moreItemCount} lagi',
        //               style: context.text.labelSmall?.copyWith(
        //                 color: context.hintColor,
        //               ),
        //             ),
        //     ),
        //   ),
      ],
    );
  }

  InkWell _buildDefaultHeader(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: Padding(
        padding: widget.headerPadding ??
            const EdgeInsets.only(
              left: 14,
              right: 20,
              top: 14,
              bottom: 4,
            ),
        child: Row(
          children: [
            widget.leadingItem ?? const SizedBox.shrink(),
            if (widget.leadingItem != null) const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: (_isExpanded)
                          ? context.primaryColor
                          : context.onBackground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    widget.subTitle,
                    style: context.text.labelSmall?.copyWith(
                      color: (_isExpanded)
                          ? context.primaryColor
                          : context.hintColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            ),
            RotationTransition(
              turns: _iconTurns,
              child: (!_isExpanded)
                  ? const Icon(Icons.arrow_drop_down,
                      key: ValueKey('arrow_drop_down'))
                  : Icon(
                      Icons.arrow_drop_down_circle,
                      color: context.primaryColor,
                      key: const ValueKey('arrow_drop_down_circle'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChild,
      child: widget.child,
    );
  }
}

class _ExpandChildContent extends StatelessWidget {
  final double value;
  final Axis direction;
  final Widget? child;
  final double? heightFactor;
  final double? widthFactor;
  final double? shaderStart;

  const _ExpandChildContent({
    required this.value,
    required this.direction,
    this.child,
    this.heightFactor,
    this.widthFactor,
    this.shaderStart,
  });

  Alignment get _childAlignment =>
      direction == Axis.horizontal ? Alignment.centerLeft : Alignment.topCenter;

  Alignment get _beginGradientAlignment =>
      direction == Axis.horizontal ? Alignment.centerLeft : Alignment.topCenter;

  Alignment get _endGradientAlignment => direction == Axis.horizontal
      ? Alignment.centerRight
      : Alignment.bottomCenter;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: LinearGradient(
        colors: [Colors.white, Colors.white.withAlpha(0)],
        begin: _beginGradientAlignment,
        end: _endGradientAlignment,
        stops: (shaderStart == null) ? const [0.9, 1] : [shaderStart ?? 0.9, 1],
      ).createShader,
      child: ClipRect(
        child: Align(
          alignment: _childAlignment,
          heightFactor: heightFactor,
          widthFactor: widthFactor,
          child: child,
        ),
      ),
    );
  }
}

class _ExpandChildIndicator extends StatelessWidget {
  final double heightIndicatorFactor;
  final Widget child;
  final Alignment? alignment;

  const _ExpandChildIndicator({
    required this.heightIndicatorFactor,
    required this.child,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: alignment ?? Alignment.center,
        heightFactor: heightIndicatorFactor,
        child: child,
      ),
    );
  }
}
