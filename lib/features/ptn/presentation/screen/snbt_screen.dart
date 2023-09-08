import 'package:flutter/cupertino.dart';

import '../../module/ptnclopedia/presentation/widget/ptn_clopedia.dart';
import '../../module/simulasi/presentation/screen/simulasi_screen.dart';
import '../../../menu/entity/menu.dart';
import '../../../menu/presentation/provider/menu_provider.dart';
import '../../../../../core/shared/screen/drop_down_action_screen.dart';

/// SNBT (Seleksi Nasional Berbasis Tes) merupakan pengganti SBMPTN
class SNBTScreen extends StatefulWidget {
  const SNBTScreen({Key? key}) : super(key: key);

  @override
  State<SNBTScreen> createState() => _SNBTScreenState();
}

class _SNBTScreenState extends State<SNBTScreen> {
  Menu _selectedMenu = MenuProvider.listMenuSNBT[0];

  @override
  Widget build(BuildContext context) {
    return DropDownActionScreen(
        title: 'SNBT',
        subTitle: 'Seleksi Nasional Berbasis Tes',
        isWatermarked: false,
        dropDownItems: MenuProvider.listMenuSNBT,
        selectedItem: _selectedMenu,
        onChanged: (clickedMenu) {
          if (clickedMenu?.label != _selectedMenu.label) {
            setState(() => _selectedMenu = clickedMenu!);
          }
        },
        body: (_selectedMenu.label == 'Simulasi')
            ? const SimulasiScreen()
            : const PtnClopediaWidget());
  }
}
