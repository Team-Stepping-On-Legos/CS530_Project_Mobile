import 'package:cs530_mobile/models/calendar_item.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventDetail extends StatefulWidget {
  final CalendarItem calendarItem;

  const EventDetail(this.calendarItem, {Key? key}) : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  late bool _onGoing;
  @override
  void initState() {
    _onGoing = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration _startDuration =
        widget.calendarItem.startTime!.difference(DateTime.now());
    Duration _endDuration =
        widget.calendarItem.endTime!.difference(DateTime.now());

    _startDuration.inSeconds.isNegative? setState(() => {
       _onGoing = true}) :setState(() => {_onGoing = false});

        print(DateTime.now());
        print(_startDuration);


    return Scaffold(
        appBar: CupertinoNavigationBar(
          backgroundColor: Colors.deepPurple,
          leading: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.navigate_before_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: Text(
            widget.calendarItem.title?.toUpperCase() ?? 'Event Details',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: _startDuration.inMicroseconds.compareTo(DateTime.now().difference(DateTime.now()).inMicroseconds) > 0 && !_endDuration.inMicroseconds.isNegative
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "UPCOMING EVENT STARTS IN",
                          style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 64.0,
                      child: FlipClock.reverseCountdown(
                        duration: _startDuration,
                        digitColor: Colors.white,
                        onDone: () => {
                          setState(() => {_onGoing = true})
                        },
                        backgroundColor: Colors.black87,
                        digitSize: 30.0,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3.0)),
                      ),
                    ),
                  ],
                ),
              )
            : _onGoing
                ? Column(
                    children: const [
                      Text('ON GOING'),
                    ],
                  )
                : Column(
                    children: const [
                      Text('PAST EVENT'),
                    ],
                  ));
  }
}
