import 'dart:convert';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:cs530_mobile/models/calendar_item.dart';
import 'package:cs530_mobile/views/upcoming_events.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final String subscribedCategories;
  const CalendarPage({required this.subscribedCategories, Key? key})
      : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<CalendarItem>> _events = {};
  late List<CalendarItem> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _events = {};
    // prefsData();
    _selectedDay = _focusedDay;
    _selectedEvents = [];
    _getCalendarItems().then((value) {
      setState(() {
        _downloadCalendarItemsDataCheck = false;

        for (var cl in _calendarItemsList) {
          DateTime groupDate = DateTime(
              cl.startTime!.year, cl.startTime!.month, cl.startTime!.day);
          if (cl.id != null) {
            List<CalendarItem>? list = _events[groupDate];
            if (list == null) {
              list = [cl];
            } else {
              list.add(cl);
            }
            _events[groupDate] = list;
          }
          // print(groupDate);
          // print(_events[groupDate]!.toList().toString());
        }
        // print(_events);
      });
    });
  }

  List<CalendarItem>? _getEventsForDay(DateTime day) {
    DateTime groupDate = DateTime(day.year, day.month, day.day);
    // print(groupDate);
    // Implementation example
    return _events[groupDate] ?? [];
  }

  prefsData() async {
    readContent("events").then((String value) {
      setState(() {
        _events = Map<DateTime, List<CalendarItem>>.from(
            decodeMap(jsonDecode(value)));
      });
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
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
            'SUBSCRIBED EVENTS',
            style: TextStyle(color: Colors.white),
          ),
          trailing: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.list_outlined),
            onPressed: ()  {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UpcomingViewCalendar(
                      subscribedCategories: widget.subscribedCategories,
                    )));
            },
        ),),
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
              Colors.indigo.shade300.withOpacity(.10),
              Colors.deepPurple.shade300.withOpacity(.10),
              Colors.indigo.shade300.withOpacity(.8),
              Colors.deepPurple.shade300.withOpacity(.8),
            ],
          )),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TableCalendar(
                  calendarStyle: const CalendarStyle(
                      canMarkersOverflow: true,
                      todayTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white,
                          backgroundColor: Colors.orange)),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    formatButtonShowsNext: false,
                  ),
                  weekendDays: const [DateTime.saturday, DateTime.sunday],
                  firstDay: DateTime.utc(2021, 01, 01),
                  lastDay: DateTime.utc(2030, 01, 01),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      // Call `setState()` when updating the selected day
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedEvents = _getEventsForDay(focusedDay)!;
                      });
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                    todayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                  ),
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      // Call `setState()` when updating calendar format
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    // No need to call `setState()` here
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    // print(_getEventsForDay(day)!.toString());
                    return _getEventsForDay(day)!;
                  },
                ),
                ..._selectedEvents.map((event) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: GestureDetector(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 1.2,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                border: Border.all(color: Colors.grey)),
                            child: Center(
                                child: Text(
                              event.summary ?? '',
                              style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            )),
                          ),
                          onTap: () {
                            _calendarDetailDialog(event);
                          },
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _calendarDetailDialog(CalendarItem event) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            buttonPadding: const EdgeInsets.all(25.0),
            title: Text(
              event.summary ?? '',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "START: ",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        formatDate(event.startTime!, [
                          mm,
                          '-',
                          dd,
                          '-',
                          yyyy,
                          ' ',
                          hh,
                          ':',
                          nn,
                          ' ',
                          am,
                        ]).toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "END: ",
                        style: TextStyle(
                          color: Colors.grey,
                          wordSpacing: 5.0,
                        ),
                      ),
                      event.endTime == null
                          ? const Text('')
                          : Text(
                              formatDate(event.endTime!, [
                                mm,
                                '-',
                                dd,
                                '-',
                                yyyy,
                                ' ',
                                hh,
                                ':',
                                nn,
                                ' ',
                                am,
                              ]).toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "CATEGORIES: ",
                        style: TextStyle(
                          color: Colors.grey,
                          wordSpacing: 5.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '[Dan, Will, Send]',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        "DESCRIPTION: ",
                        style: TextStyle(
                          color: Colors.grey,
                          wordSpacing: 5.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.description ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionChip(
                    backgroundColor: Colors.deepPurple[200],
                    avatar: const Icon(
                      Icons.dehaze_outlined,
                      color: Colors.white,
                      size: 20),
                    label: const Text(
                        "DETAIL",
                        style: TextStyle(
                          color: Colors.white
                        ),
                    ), onPressed: (){}),
                  FilterChip(
                    backgroundColor: Colors.deepPurple[200],
                    avatar: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 20),
                    label: const Text(
                        "MUTE",
                        style: TextStyle(
                          color: Colors.white
                        ),
                    ),
                    // selected: _filters.contains(company.name),
                    selected: true,
                    selectedColor: Colors.red,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          // _filters.add(company.name);
                        } else {
                          // _filters.removeWhere((String name) {
                          //   return name == company.name;
                          // });
                        }
                      });
                    },
                  ),                
                ],
              )
            ],
          );
        });
  }
}
