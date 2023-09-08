import 'package:flutter/material.dart';

import '../widget/buku_list.dart';
import '../../../menu/entity/menu.dart';
import '../../../menu/presentation/provider/menu_provider.dart';
import '../../../../core/shared/screen/drop_down_action_screen.dart';

class BukuTeoriScreen extends StatefulWidget {
  const BukuTeoriScreen({Key? key}) : super(key: key);

  @override
  State<BukuTeoriScreen> createState() => _BukuTeoriScreenState();
}

class _BukuTeoriScreenState extends State<BukuTeoriScreen> {
  Menu _selectedBukuTeori = MenuProvider.listMenuBukuTeori[0];
  String _jenisBuku = MenuProvider.listMenuBukuTeori[0].label;

  @override
  Widget build(BuildContext context) {
    return DropDownActionScreen(
      title: 'Buku $_jenisBuku',
      isWatermarked: false,
      dropDownItems: MenuProvider.listMenuBukuTeori,
      selectedItem: _selectedBukuTeori,
      onChanged: (newValue) {
        if (newValue?.idJenis != _selectedBukuTeori.idJenis) {
          setState(() {
            _selectedBukuTeori = newValue!;
            _jenisBuku = newValue.label;
          });
        }
      },
      body: BukuList(
        idJenisProduk: _selectedBukuTeori.idJenis,
        namaJenisProduk: _selectedBukuTeori.namaJenisProduk,
      ),
    );
  }
}
