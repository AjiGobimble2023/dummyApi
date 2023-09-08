part of 'custom_expanded_widget.dart';

/// This function is used to override the `ExpandArrow` widget for controlling
/// a `ExpandChild` or `ExpandText` widget.
typedef IndicatorBuilder = Widget Function(
    BuildContext context,
    VoidCallback onTap,
    bool isExpanded,
);