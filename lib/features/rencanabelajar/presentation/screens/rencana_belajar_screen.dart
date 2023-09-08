import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/event_calendar_widget.dart';
import '../provider/rencana_belajar_provider.dart';
import '../../model/rencana_belajar.dart';
import '../../service/notifikasi/local_notification_service.dart';
import '../../../auth/presentation/provider/auth_otp_provider.dart';
import '../../../../core/shared/screen/basic_screen.dart';

class RencanaBelajarScreen extends StatefulWidget {
  const RencanaBelajarScreen({Key? key}) : super(key: key);

  @override
  State<RencanaBelajarScreen> createState() => _RencanaBelajarScreenState();
}

class _RencanaBelajarScreenState extends State<RencanaBelajarScreen> {
  final CalendarController _calendarController = CalendarController();
  late final _rencanaProvider = context.read<RencanaBelajarProvider>();
  late final _authOtpProvider = context.read<AuthOtpProvider>();


  @override
  void initState() {
    LocalNotificationService().requestPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Rencana Belajar',
      onWillPop: _onWillPop,
      body: FutureBuilder<List<RencanaBelajar>>(
        future: _prepareRencanaData(),
        builder: (context, snapshot) {
          bool isLoading = snapshot.connectionState == ConnectionState.waiting;
          List<RencanaBelajar> listRencanaBelajar = snapshot.data ?? [];

          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Sedang menyiapkan data\nrencana belajar...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return EventCalendarWidget(
            controller: _calendarController,
            onWillPopCalendar: _onWillPopCalendar,
            listRencanabelajar: listRencanaBelajar,
          );
        },
      ),
    );
  }

  void _onWillPop() {
    if (_onWillPopCalendar()) {
      Navigator.of(context).pop();
    }
  }

  bool _onWillPopCalendar() {
    switch (_calendarController.view) {
      case CalendarView.week:
        _calendarController.view = CalendarView.schedule;
        _rencanaProvider.calendarView = CalendarView.schedule;
        return false;
      default:
        return true;
    }
  }

  Future<List<RencanaBelajar>> _prepareRencanaData(
      {bool isRefresh = false}) async {
    if (kDebugMode) {
      logger.log('EVENT_CALENDER_WIDGET-GetDataMenu: START');
    }

    await _rencanaProvider.getListMenu(isRefresh: isRefresh);

    List<RencanaBelajar> listRencana = await _rencanaProvider.getDataRencanaBelajar(
      isRefresh: isRefresh,
      noRegistrasi: _authOtpProvider.userData!.noRegistrasi,
    );

    if (kDebugMode) {
      logger.log(
          'EVENT_CALENDER_WIDGET-GetDataMenu: Selected Menu Index >> ${_rencanaProvider.selectedMenuIndex}');
    }

    return listRencana;
  }
}
