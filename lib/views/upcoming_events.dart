import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/models/calendar_item.dart';
import 'package:cs530_mobile/views/calendar.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class UpcomingViewCalendar extends StatefulWidget {
  final String subscribedCategories;

  const UpcomingViewCalendar({Key? key, required this.subscribedCategories})
      : super(key: key);

  @override
  _UpcomingViewCalendarState createState() => _UpcomingViewCalendarState();
}

class _UpcomingViewCalendarState extends State<UpcomingViewCalendar> {
  bool _downloadCalendarItemsDataCheck = true;
  List<CalendarItem> _calendarItemsList = [];

  Future<void> _getCalendarItems() async {
    return API.getCalendarItems(widget.subscribedCategories).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        _calendarItemsList =
            list.map((model) => CalendarItem.fromJson(model)).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getCalendarItems().then((value) => {
          setState(() {
            _downloadCalendarItemsDataCheck = false;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _downloadCalendarItemsDataCheck,
      child: Scaffold(
        appBar: CupertinoNavigationBar(
          backgroundColor: Colors.deepPurple,
          leading: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.navigate_before_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: const Text(
            'EVENTS CALENDAR',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: const [
              0.1,
              0.4,
              0.6,
              0.9,
            ],
            colors: [
              Colors.white.withOpacity(.01),
              Colors.indigo.shade300.withOpacity(.3),
              Colors.deepPurple.shade300.withOpacity(.3),
              Colors.indigo.withOpacity(.01),
            ],
          )),
          child: SfCalendar(
            headerStyle: const CalendarHeaderStyle(
                textStyle: TextStyle(
                    color: Colors.black, fontSize: 18, letterSpacing: 1.5),
                backgroundColor: Color.fromARGB(10, 10, 10, 10)),
            backgroundColor: Colors.transparent,
            dataSource: _getCalendarDataSource(_calendarItemsList),
            onTap: calendarTapped,
            view: CalendarView.schedule,
            monthViewSettings: const MonthViewSettings(showAgenda: true),
            scheduleViewMonthHeaderBuilder: (BuildContext buildContext,
                ScheduleViewMonthHeaderDetails details) {
              final String monthName = _getMonthDate(details.date.month);
              return Stack(
                children: [
                  Image(
                    image: ExactAssetImage(
                        'assets/monthImages/' + monthName + '.png'),
                    fit: BoxFit.cover,
                    width: details.bounds.width,
                    height: details.bounds.height,
                    color: Colors.white.withOpacity(0.9),
                    colorBlendMode: BlendMode.dstATop,
                  ),
                  Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          monthName.toUpperCase() +
                              ' ' +
                              details.date.year.toString(),
                          textStyle: GoogleFonts.robotoCondensed(
                              color: Colors.white70,
                              fontSize: 24,
                              letterSpacing: 1.5,
                              wordSpacing: 2.0,
                              fontWeight: FontWeight.w900),
                          speed: const Duration(milliseconds: 200),
                        ),
                      ],
                      totalRepeatCount: 1,
                      pause: const Duration(milliseconds: 1000),
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                    ),
                  )
                ],
              );
            },
            showDatePickerButton: true,
            allowViewNavigation: true,
            allowedViews: const [
              CalendarView.month,
              CalendarView.week,
              CalendarView.day,
              CalendarView.schedule,
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthDate(int m) {
    switch (m) {
      case 1:
        {
          return "January";
        }
      case 2:
        {
          return "February";
        }
      case 3:
        {
          return "March";
        }
      case 4:
        {
          return "April";
        }
      case 5:
        {
          return "May";
        }
      case 6:
        {
          return "June";
        }
      case 7:
        {
          return "July";
        }
      case 8:
        {
          return "August";
        }
      case 9:
        {
          return "September";
        }
      case 10:
        {
          return "October";
        }
      case 11:
        {
          return "November";
        }
      case 12:
        {
          return "December";
        }
      default:
        {
          return "January";
        }
    }
  }

  String? _apptID = '',      
      _apptTitle = '',
      _apptDescription = '',     
      _startTimeText = '',
      _endTimeText = '',
      _dateText = '',
      _timeDetails = '';

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Appointment appointmentDetails = details.appointments![0];
      _apptID = appointmentDetails.id.toString();
      _apptTitle = appointmentDetails.subject;
      _apptDescription = appointmentDetails.notes ?? '';
      _dateText = DateFormat('MMMM dd, yyyy')
          .format(appointmentDetails.startTime)
          .toString();
      _startTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.startTime).toString();
      _endTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.endTime).toString();
      if (appointmentDetails.isAllDay) {
        _timeDetails = 'All day';
      } else {
        _timeDetails = '$_startTimeText - $_endTimeText';
      }
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_apptTitle',
                style: const TextStyle(
                    textBaseline: TextBaseline.ideographic,
                    fontSize: 22,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          message: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$_apptDescription",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                "$_dateText",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                _timeDetails!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),

          // message: const Text('Message'),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: const Text('Mute'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Open'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    }
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

DataSource _getCalendarDataSource(List<CalendarItem> _calendarItemsList) {
  List<Appointment> appointments = <Appointment>[];
  for (var cli in _calendarItemsList) {
    appointments.add(Appointment(
        id: cli.id,
        startTime: cli.startTime ?? DateTime.now(),
        endTime: cli.endTime ?? DateTime.now().add(const Duration(minutes: 1)),
        isAllDay: cli.isAllDay ?? false,
        subject: cli.summary ?? '',
        notes: cli.description ?? '',
        color: Colors.blue,
        startTimeZone: '',
        endTimeZone: ''));
  }

  return DataSource(appointments);
}
