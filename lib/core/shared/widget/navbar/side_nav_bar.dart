import 'package:flutter/material.dart';

import '../../../config/extensions.dart';

class SideNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<String> iconsActive;
  final List<String> iconsInactive;
  final List<String> labels;
  final ValueChanged<int>? onIndexChange;

  const SideNavBar(
      {Key? key,
      required this.selectedIndex,
      required this.iconsActive,
      required this.iconsInactive,
      required this.labels,
      this.onIndexChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(
        iconsActive.length,
        (index) {
          bool isActive = selectedIndex == index;

          return InkWell(
            onTap: () => onIndexChange?.call(index),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastLinearToSlowEaseIn,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: (isActive)
                  ? const EdgeInsets.only(
                      top: 12, left: 8, bottom: 12, right: 12)
                  : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: (isActive)
                    ? Colors.black12
                    : null,
              ),
              child: Row(
                key: (isActive)
                    ? ValueKey('active_${labels[index]}')
                    : ValueKey('deactive_${labels[index]}'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    (isActive) ? iconsActive[index] : iconsInactive[index],
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    labels[index],
                    style: context.text.labelLarge?.copyWith(
                        color: (isActive)
                            ? context.onBackground
                            : Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
