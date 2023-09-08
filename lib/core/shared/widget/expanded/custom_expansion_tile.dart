import 'package:flutter/material.dart';

import '../../../../core/config/extensions.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Widget? trailing;
  final EdgeInsetsGeometry? tilePadding;

  const CustomExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.tilePadding,
  }) : super(key: key);

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _customTileExpanded = false;

  /// Custom animation curve for indicator icon controll.
  static final _easeInCurve = CurveTween(curve: Curves.easeInOutCubic);

  /// Controlls the rotation of the indicator icon widget.
  static final _halfTurn = Tween<double>(begin: 0, end: 0.5);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: ExpansionTileThemeData(
          collapsedTextColor: _customTileExpanded
              ? context.primaryColor
              : context.onBackground.withOpacity(0.76),
        ),
      ),
      child: ExpansionTile(
        title: widget.title,
        tilePadding: widget.tilePadding ??
            EdgeInsets.symmetric(horizontal: context.dp(18), vertical: 0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.centerLeft,
        subtitle: widget.subtitle,
        leading: widget.leading,
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          transitionBuilder: (child, animation) => RotationTransition(
              turns: (!_customTileExpanded)
                  ? animation
                  : animation.drive(_halfTurn.chain(_easeInCurve)),
              child: child),
          child: widget.trailing ??
              ((!_customTileExpanded)
                  ? const Icon(Icons.arrow_drop_down,
                      key: ValueKey('arrow_drop_down'))
                  : const Icon(Icons.arrow_drop_down_circle,
                      key: ValueKey('arrow_drop_down_circle'))),
        ),
        onExpansionChanged: widget.onExpansionChanged ??
            (bool expanded) {
              setState(() => _customTileExpanded = expanded);
            },
        children: widget.children,
      ),
    );
  }
}
