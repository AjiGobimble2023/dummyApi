import 'package:flutter/cupertino.dart';

import '../../../config/extensions.dart';

class BottomPickerWidget extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> children;

  const BottomPickerWidget({
    super.key,
    required this.selectedIndex,
    required this.children,
  });

  @override
  State<BottomPickerWidget> createState() => _BottomPickerWidgetState();
}

class _BottomPickerWidgetState extends State<BottomPickerWidget> {
  late int _selectedIndex = widget.selectedIndex;

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: _selectedIndex);

    return SizedBox(
      height: context.dh / 3,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(_selectedIndex),
        child: CupertinoPicker(
          scrollController: scrollController,
          itemExtent: 50.0,
          backgroundColor: CupertinoColors.white,
          children: widget.children,
          onSelectedItemChanged: (int index) => _selectedIndex = index,
        ),
      ),
    );
  }
}
