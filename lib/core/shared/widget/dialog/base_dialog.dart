// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

// ignore: constant_identifier_names
enum DialogType { Basic, Success, Info, Confirm, Warning, Danger }

// ignore: constant_identifier_names
enum DialogActionType { Outlined, Filled }

class BaseDialogAction {
  final String text;
  final VoidCallback onPressed;
  final DialogActionType type;

  BaseDialogAction({
    required this.text,
    required this.onPressed,
    required this.type,
  });
}

class BaseDialogWidget extends StatefulWidget {
  final DialogType type;
  final IconData? icon;
  final String? title;
  final String? message;
  final Widget? header;
  final Widget? body;
  final List<BaseDialogAction> listAction;

  const BaseDialogWidget({
    Key? key,
    required this.type,
    this.icon,
    this.title,
    this.message,
    this.header,
    this.body,
    this.listAction = const [],
  }) : super(key: key);

  @override
  _BaseDialogWidgetState createState() => _BaseDialogWidgetState();
}

class _BaseDialogWidgetState extends State<BaseDialogWidget> {
  String? _title, _message;
  IconData? _icon;
  Color? _color;

  void _prepareDialog() {
    switch (widget.type) {
      case DialogType.Success:
        _title = 'Sukses';
        _message = 'Berhasil memproses data';
        _icon = Icons.check_circle_outline;
        _color = Colors.green.shade800;
        break;
      case DialogType.Info:
        _title = 'Informasi';
        _message = 'Belum ada informasi';
        _icon = Icons.info_outline_rounded;
        _color = Colors.lightBlue;
        break;
      case DialogType.Confirm:
        _title = 'Konfirmasi';
        _message = 'Apakah Kamu yakin melakukan ini?';
        _icon = Icons.help_outline_outlined;
        _color = Colors.blue.shade800;
        break;
      case DialogType.Warning:
        _title = 'Peringatan';
        _message = 'Belum ada informasi';
        _icon = Icons.error_outline;
        _color = Colors.yellow.shade800;
        break;
      case DialogType.Danger:
        _title = 'Error';
        _message = 'Terjadi kesalahan';
        _icon = Icons.error_outline;
        _color = Colors.red.shade800;
        break;
      case DialogType.Basic:
      default:
        _title = 'Informasi';
        _message = 'Belum ada informasi';
        _icon = Icons.info_outline_rounded;
        _color = Colors.black54;
    }

    _title = widget.title ?? _title;
    _icon = widget.icon ?? _icon;
  }

  Widget _buildHeader() {
    if (widget.header != null) return widget.header!;

    return Column(
      children: [
        Icon(_icon, size: 60.0, color: _color),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _title ?? 'Title tidak ada',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: _color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: widget.body ??
          Text(
            widget.message ?? _message ?? 'Tidak ada pesan',
            textAlign: TextAlign.center,
          ),
    );
  }

  Widget _buildAction({
    required DialogActionType type,
    String? label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: type == DialogActionType.Filled
            ? _color ?? Colors.black
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: type == DialogActionType.Outlined
              ? BorderSide(color: _color ?? Colors.black, width: 2)
              : BorderSide.none,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label ?? 'OK',
        style: TextStyle(
          color: type == DialogActionType.Filled
              ? Colors.white
              : _color ?? Colors.black,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _prepareDialog();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: deviceWidth > 600.0 ? 400.0 : double.infinity,
            maxHeight: deviceHeight > 1000.0 ? 800.0 : double.infinity,
          ),
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildBody(),
                if (widget.listAction.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.listAction.map<Widget>((action) {
                      return _buildAction(
                        type: action.type,
                        label: action.text,
                        onPressed: action.onPressed,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
