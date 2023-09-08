// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_import

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'picker_widget.dart';

class DatetimePickerWidget extends StatefulWidget {
  final String? currentDate;
  final String? label;
  final void Function(DateTime? selectedDateTime)? onConfirm;

  const DatetimePickerWidget({
    this.currentDate,
    this.label,
    this.onConfirm,
  });

  @override
  _DatetimePickerWidgetState createState() => _DatetimePickerWidgetState();
}

class _DatetimePickerWidgetState extends State<DatetimePickerWidget> {
  double? _deviceHeight;
  DateTime? _currentDate = DateTime.now();
  DateTime? _selectedDate;

  Future<void> _showDatePickerAndroid() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onConfirm!(_selectedDate);
    }
  }

  Future<void> _showDatePickerIOS() async {
    DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        DateTime? tempPickedDate;

        return SizedBox(
          height: _deviceHeight! / 3,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop(tempPickedDate);
                    },
                  ),
                ],
              ),
              const Divider(
                height: 0,
                thickness: 1,
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime dateTime) {
                    tempPickedDate = dateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onConfirm!(_selectedDate);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentDate = widget.currentDate != null
        ? DateTime.parse(widget.currentDate!)
        : DateTime.now();
    _selectedDate = _currentDate;
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: Platform.isIOS ? _showDatePickerIOS : _showDatePickerAndroid,
      child: PickerWidget(
        label: widget.label ?? 'Tanggal',
        value: DateFormat.yMMMMd().format(_selectedDate!),
      ),
    );
  }
}
