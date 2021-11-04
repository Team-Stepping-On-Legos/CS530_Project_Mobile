import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/models/calendar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            'UPCOMING EVENTS',
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
              Colors.white.withOpacity(.15),
              Colors.indigo.shade300.withOpacity(.5),
              Colors.deepPurple.shade300.withOpacity(.5),
              Colors.indigo.withOpacity(.15),
            ],
          )),
          child: SfCalendar(
              backgroundColor: Colors.transparent,
              dataSource: _getCalendarDataSource(_calendarItemsList),
              view: CalendarView.schedule,
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
                        height: details.bounds.height),
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
                        totalRepeatCount: 2,
                        pause: const Duration(milliseconds: 1000),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                    )
                  ],
                );
              },
              showDatePickerButton: true),
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
        startTime: cli.startTime ?? DateTime.now(),
        endTime: cli.endTime ?? DateTime.now().add(const Duration(minutes: 1)),
        isAllDay: cli.isAllDay ?? false,
        subject: cli.summary ?? "",
        color: Colors.blue,
        startTimeZone: '',
        endTimeZone: ''));
  }

  return DataSource(appointments);
}
