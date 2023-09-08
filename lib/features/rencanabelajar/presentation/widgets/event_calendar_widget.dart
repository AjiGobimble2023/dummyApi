library event_calendar;

import 'dart:async';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/config/global.dart';
import '../../model/rencana_belajar.dart';
import '../provider/rencana_belajar_provider.dart';

class EventCalendarWidget extends StatefulWidget {
  final CalendarController controller;
  final bool Function() onWillPopCalendar;
  final List<RencanaBelajar> listRencanabelajar;

  const EventCalendarWidget({
    Key? key,
    required this.controller,
    required this.onWillPopCalendar,
    required this.listRencanabelajar,
  }) : super(key: key);

  @override
  State<EventCalendarWidget> createState() => _EventCalendarWidgetState();
}

class _EventCalendarWidgetState extends State<EventCalendarWidget> {
  late final RencanaBelajarProvider _rencanaProvider =
      context.read<RencanaBelajarProvider>();

  @override
  Widget build(BuildContext context) {
    widget.controller.view =
        context.select<RencanaBelajarProvider, CalendarView>(
            (rencana) => rencana.calendarView);

    final listRencana =
        context.watch<RencanaBelajarProvider>().listRencanaBelajar;

    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaleFactor: context.textScale11),
      child: WillPopScope(
        onWillPop: () async =>
            await Future<bool>.value(widget.onWillPopCalendar()),
        child: Padding(
          padding: (!context.isMobile)
              ? EdgeInsets.symmetric(
                  horizontal: context.dw * 0.14,
                )
              : EdgeInsets.zero,
          child: SfCalendar(
            controller: widget.controller,
            firstDayOfWeek: 1,
            showNavigationArrow: true,
            // timeZone: 'Singapore Standard Time',
            timeZone: 'Asia/Jakarta',
            appointmentTimeTextFormat: 'HH:mm a',
            initialDisplayDate: DateTime.now(),
            initialSelectedDate: _rencanaProvider.startRencanaDate,
            todayHighlightColor: context.secondaryColor,
            todayTextStyle:
                context.text.titleMedium?.copyWith(color: context.onSecondary),
            onTap: (calendarTapDetails) =>
                _onCalendarTapped(context, calendarTapDetails),
            dataSource: RencanaBelajarDataSource(listRencana),
            headerHeight: 64,
            headerStyle: CalendarHeaderStyle(
              textAlign: TextAlign.center,
              textStyle: context.text.titleLarge,
            ),
            cellBorderColor: Colors.black12,
            appointmentTextStyle:
                context.text.bodyMedium!.copyWith(color: context.onBackground),
            appointmentBuilder: (_, details) {
              bool isViewSchedule = details.bounds.width > (context.dw * 0.5);
              RencanaBelajar appointment =
                  details.appointments.first as RencanaBelajar;

              return Container(
                width: details.bounds.width,
                padding: (isViewSchedule)
                    ? const EdgeInsets.symmetric(vertical: 8, horizontal: 10)
                    : EdgeInsets.all((appointment.isFittedBox) ? 4 : 6),
                decoration: BoxDecoration(
                    color: appointment.backgroundColor,
                    borderRadius:
                        BorderRadius.circular((isViewSchedule) ? 12 : 8)),
                child: (isViewSchedule)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.menuLabel,
                            style: context.text.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          // const Spacer(),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${appointment.startRencana.displayHHMMA} - ${appointment.endRencana.displayHHMMA}',
                                style: context.text.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      )
                    : FittedBox(
                        child: Text(
                          appointment.displayWeek
                              .replaceAll(' ', '\n')
                              .replaceAll('-', ' '),
                          style: context.text.labelMedium!
                              .copyWith(color: context.onBackground),
                        ),
                      ),
              );
            },
            scheduleViewMonthHeaderBuilder: (context, details) => Container(
              width: details.bounds.width,
              height: details.bounds.height,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: gDefaultShimmerBorderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.primaryContainer,
                    context.secondaryContainer,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: gDefaultShimmerBorderRadius,
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.black26, Colors.black],
                        ).createShader(bounds),
                        child: Image.asset(
                          'assets/img/header_calender.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 48,
                    child: Text(
                      details.date.displayMMMMYYYY,
                      style: context.text.titleMedium
                          ?.copyWith(color: context.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            timeSlotViewSettings: const TimeSlotViewSettings(
              minimumAppointmentDuration: Duration(minutes: 60),
            ),
          ),
        ),
      ),
    );
  }

  void _onCalendarTapped(
      BuildContext context, CalendarTapDetails calendarTapDetails) {
    final rencanaBelajar = context.read<RencanaBelajarProvider>();

    if (kDebugMode) {
      logger.log('EVENT_CALENDER_WIDGET-OnCalendarTapped: '
          'Tap Detail >>\n'
          'TargetElement(${calendarTapDetails.targetElement.index}, ${calendarTapDetails.targetElement.name})\n'
          'CalenderCell(${CalendarElement.calendarCell.index}, ${CalendarElement.calendarCell.name})\n'
          'CalenderAgenda(${CalendarElement.agenda.index}, ${CalendarElement.agenda.name})\n'
          'CalenderAllDayPanel(${CalendarElement.allDayPanel.index}, ${CalendarElement.allDayPanel.name})\n'
          'CalenderAppointment(${CalendarElement.appointment.index}, ${CalendarElement.appointment.name})\n'
          'CalenderMoreAppointmentRegion(${CalendarElement.moreAppointmentRegion.index}, ${CalendarElement.moreAppointmentRegion.name})\n'
          'CalendarResource(${calendarTapDetails.resource?.id}, ${calendarTapDetails.resource?.image}'
          ' ${calendarTapDetails.resource?.displayName}, ${calendarTapDetails.resource?.color})\n'
          'Date >> ${calendarTapDetails.date}\n'
          'Appointments >> ${calendarTapDetails.appointments.toString()}');
    }

    bool isHeaderClicked =
        calendarTapDetails.targetElement == CalendarElement.header;

    bool isViewHeaderClicked =
        calendarTapDetails.targetElement == CalendarElement.viewHeader;

    bool isCalendarCellClicked =
        calendarTapDetails.targetElement == CalendarElement.calendarCell;

    bool isAppointmentClicked =
        calendarTapDetails.targetElement == CalendarElement.appointment;

    if (!isHeaderClicked &&
        !isViewHeaderClicked &&
        !isCalendarCellClicked &&
        !isAppointmentClicked) {
      return;
    }

    final DateTime clickedDate = calendarTapDetails.date ?? DateTime.now();

    if (kDebugMode) {
      logger.log('EVENT_CALENDER_WIDGET-OnCalendarTapped: '
          'Date >> $clickedDate || ${calendarTapDetails.date}');
    }

    if (!isAppointmentClicked &&
        widget.controller.view == CalendarView.schedule) {
      widget.controller.view = CalendarView.week;
      rencanaBelajar.calendarView = CalendarView.week;
      rencanaBelajar.startRencanaDate = clickedDate;

      if (calendarTapDetails.date?.day == DateTime.now().day &&
          calendarTapDetails.date?.month == DateTime.now().month &&
          calendarTapDetails.date?.year == DateTime.now().year) {
        widget.controller.displayDate = DateTime.now();
        widget.controller.selectedDate = DateTime.now();
      } else {
        widget.controller.displayDate = calendarTapDetails.date;
        widget.controller.selectedDate = calendarTapDetails.date;
      }
    } else {
      final RencanaBelajar? clickedRencana =
          calendarTapDetails.appointments?.first;

      if (kDebugMode) {
        logger.log(
            'EVENT_CALENDAR_WIDGET: Meeting Details >> ${clickedRencana?.menuLabel}');
      }

      rencanaBelajar.selectedRencana = clickedRencana;

      if (calendarTapDetails.appointments == null ||
          (calendarTapDetails.appointments?.length ?? 0) < 1) {
        rencanaBelajar.startRencanaDate = clickedDate;
        rencanaBelajar.endRencanaDate =
            clickedDate.add(const Duration(hours: 1));
      }

      Navigator.pushNamed(
        context,
        Constant.kRouteRencanaEditor,
        arguments: {'rencanaBelajar': clickedRencana},
      );
    }
  }
}
