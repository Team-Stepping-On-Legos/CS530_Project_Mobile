import 'dart:convert';

import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late TextEditingController _eventController;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _events = {};
    prefsData();
    _selectedDay = _focusedDay;
    _selectedEvents = [];
    _eventController = TextEditingController();
  }

  List<dynamic>? _getEventsForDay(DateTime day) {
    // Implementation example
    return _events[day] ?? [];
  }

  prefsData() async {
    readContent("events").then((String value) {
      setState(() {
        _events =
            Map<DateTime, List<dynamic>>.from(decodeMap(jsonDecode(value)));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUBSCRIBED EVENTS'),
      ),
      body: SingleChildScrollView(
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
                return _getEventsForDay(day)!;
              },
            ),
            ..._selectedEvents.map((event) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: GestureDetector(
                  child: Container(
                    height: MediaQuery.of(context).size.height/20,
                    width: MediaQuery.of(context).size.width/1.2,              
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey)
                    ),
                    child: Center(
                        child: Text(event,
                          style: const TextStyle(color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,fontSize: 16),)
                    ),
                  ),
                  onTap: () { showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            //Here we will build the content of the dialog
                            return AlertDialog(
                              title: Text(event, textAlign: TextAlign.center,),
                              content: Lottie.asset(
                                'assets/404.json',
                                repeat: true,
                                reverse: true,
                                animate: true,
                                height: 150,
                                width: 150,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });},
                ),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }

  _showAddDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white70,
              title: const Text("Add Events"),
              content: TextField(
                controller: _eventController,
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (_eventController.text.isEmpty) return;
                    setState(() {
                      if (_events[_selectedDay] != null) {
                        _events[_selectedDay]!.add(_eventController.text);
                      } else {
                        _events[_selectedDay!] = [_eventController.text];
                      }
                      _eventController.clear();
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            ));
  }
}
