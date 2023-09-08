import 'package:flutter/material.dart';
import '../../../config/extensions.dart';

import '../../../../features/menu/entity/menu.dart';

class SideBarMenu extends StatelessWidget {
  final Menu selectedMenu;
  final List<Menu> listMenu;
  final ValueChanged<Menu?> onIndexChange;

  const SideBarMenu({
    Key? key,
    required this.selectedMenu,
    required this.listMenu,
    required this.onIndexChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();

    return Scrollbar(
      controller: controller,
      thickness: 8,
      radius: const Radius.circular(24),
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.separated(
        controller: controller,
        padding: EdgeInsets.symmetric(horizontal: context.dp(5), vertical: 16),
        itemCount: listMenu.length,
        separatorBuilder: (context, index) =>
            const Divider(indent: 12, endIndent: 24),
        itemBuilder: (context, index) {
          bool isActive = selectedMenu == listMenu[index];

          return InkWell(
            onTap: () => onIndexChange.call(listMenu[index]),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastLinearToSlowEaseIn,
              width: double.infinity,
              padding: (isActive)
                  ? const EdgeInsets.only(
                      top: 12, left: 8, bottom: 12, right: 12)
                  : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: (isActive) ? Colors.black12 : null,
              ),
              child: Text(
                listMenu[index].label,
                key: (isActive)
                    ? ValueKey('active_${listMenu[index].label}')
                    : ValueKey('deactive_${listMenu[index].label}'),
                style: context.text.labelLarge?.copyWith(
                    color: (isActive) ? context.onBackground : Colors.black54),
              ),
            ),
          );
        },
      ),
    );
  }
}
