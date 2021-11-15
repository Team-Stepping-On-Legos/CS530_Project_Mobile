import 'dart:convert';
import 'dart:ui';

import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/utils.dart';
import 'package:cs530_mobile/models/calendar_item.dart';
import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:cs530_mobile/widgets/notification_tile.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

class EventDetail extends StatefulWidget {
  final CalendarItem calendarItem;
  final bool isMuted;

  const EventDetail(this.calendarItem, this.isMuted, {Key? key})
      : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  bool _downloadNotificationDataCheck = true;
  List<NotificationHistoryData> _notificationHistoryList = [];
  List<NotificationHistoryData> _eventSpecificNotificationHistoryList = [];
  String subscribedCats = '';

  Future<void> _getNotificationHistory() async {
    await readContent("categories").then((String? value) {
      List<dynamic> readCategoryList = jsonDecode(value ?? '');
      subscribedCats = getListAsCommaSepratedString(readCategoryList, "Uncat");
    });

    return API.getNotificationHistory(subscribedCats).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        _notificationHistoryList = list
            .map((model) => NotificationHistoryData.fromJson(model))
            .toList();

        // _eventSpecificNotificationHistoryList = _notificationHistoryList
        //     .where((element) => _notificationHistoryList
        //         .contains(element.eventId == widget.calendarItem.id))
        //     .toList();

        _notificationHistoryList.forEach((element) {
          if(element.eventId==widget.calendarItem.id){
            _eventSpecificNotificationHistoryList.add(element);
          }
        });
      });
    });
  }

//   Future<void> _getNotificationHistory() async {
//     await readContent("categories").then((String? value) {
//       List<dynamic> readCategoryList = jsonDecode(value ?? '');
//       subscribedCats = getListAsCommaSepratedString(readCategoryList, "Uncat");
//     });
//  print('${subscribedCats} and ${widget.calendarItem.id}');

//     return API.getNotificationHistory(subscribedCats).then((response) {
//       setState(() {
//         Iterable list = json.decode(response.body);
//         _notificationHistoryList = list
//             .map((model) => NotificationHistoryData.fromJson(model))
//             .toList();

  // _notificationHistoryList.forEach((element) {
  //     print('${element.eventID} and ${widget.calendarItem.id}');
  //   if(element.eventID == widget.calendarItem.id){
  //     print(element);
  //     _eventSpecificNotificationHistoryList.add(element);
  //   }
  // });

//         _eventSpecificNotificationHistoryList = _notificationHistoryList
//             .where((element) =>
//                 _notificationHistoryList.contains(element.eventID == widget.calendarItem.id))
//             .toList();

//         print(_eventSpecificNotificationHistoryList);
//       });
//     });
//   }

  late bool _onGoing;
  @override
  void initState() {
    _onGoing = false;
    _getNotificationHistory().then((value) {
      setState(() {
        _downloadNotificationDataCheck = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration _startDuration =
        widget.calendarItem.startTime!.difference(DateTime.now());
    Duration _endDuration =
        widget.calendarItem.endTime!.difference(DateTime.now());

    !_endDuration.inMicroseconds.isNegative
        ? setState(() => {_onGoing = true})
        : setState(() => {_onGoing = false});

    return ModalProgressHUD(
      inAsyncCall: _downloadNotificationDataCheck,
      child: Scaffold(
          appBar: CupertinoNavigationBar(
            backgroundColor: Colors.deepPurple,
            leading: Material(
              color: Colors.deepPurple,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.navigate_before_outlined),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            middle: const Text(
              'EVENT DETAIL',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: _startDuration.inMicroseconds.compareTo(DateTime.now()
                            .difference(DateTime.now())
                            .inMicroseconds) >
                        0 &&
                    _endDuration.inMicroseconds.compareTo(DateTime.now()
                            .difference(DateTime.now())
                            .inMicroseconds) >
                        0
                ? Column(
                    children: [
                      Hero(
                        tag: 'HeroOne',
                        child: Container(
                          height: 25,
                          decoration: BoxDecoration(
                              color: Colors.indigo.withAlpha(150)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'UPCOMING EVENT',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 64.0,
                        child: FlipClock.reverseCountdown(
                          duration: _startDuration,
                          digitColor: Colors.white,
                          //NOT WORKING
                          onDone: () => {
                            setState(() => {_onGoing = true}),
                            print("ON DONE CALLED"),
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        super.widget))
                          },
                          backgroundColor: Colors.black87,
                          digitSize: 30.0,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3.0)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _eventDetailView(context),
                    ],
                  )
                : _onGoing
                    ? Column(
                        children: [
                          Hero(
                            tag: 'HeroOne',
                            child: Container(
                              height: 25,
                              decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(150)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'ON-GOING EVENT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _eventDetailView(context)
                        ],
                      )
                    : Column(
                        children: [
                          Hero(
                            tag: 'HeroOne',
                            child: Container(
                              height: 25,
                              decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(150)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'PAST EVENT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      letterSpacing: 1.0,
                                      color: Colors.white.withOpacity(1.0),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _eventDetailView(context)
                        ],
                      ),
          )),
    );
  }

  Container _eventDetailView(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.calendarItem.title ?? 'TITLE',
                  style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold),
                ),
                widget.isMuted
                    ? Image.asset(
                        'assets/notification_off.png',
                        height: 25,
                        width: 25,
                      )
                    : Image.asset('assets/notification_on.png',
                        height: 25, width: 25)
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'START:  ' +
                  DateFormat('MMM dd, yyyy hh:mm a')
                      .format(widget.calendarItem.startTime!)
                      .toString(),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'END:      ' +
                  DateFormat('MMM dd, yyyy hh:mm a')
                      .format(widget.calendarItem.endTime!)
                      .toString(),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              'DESCRIPTION: ${widget.calendarItem.description ?? ''}',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            const Center(
              child:  Text(
                'NOTIFICATION HISTORY',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),
            _eventSpecificNotificationHistoryList.isEmpty
                ? const SizedBox(
                    height: 0,
                  )
                : Expanded(
                  child: StickyGroupedListView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    reverse: false,
                    floatingHeader: false,
                    order: StickyGroupedListOrder.DESC,
                    elements: _eventSpecificNotificationHistoryList,
                    itemBuilder: (_, NotificationHistoryData element) {
                      return Center(
                          child: NotificationTile(
                              element,
                              _eventSpecificNotificationHistoryList
                                  .indexOf(element)));
                    },
                    groupBy: (NotificationHistoryData element) => DateTime(
                        DateTime.parse(element.time.toString())
                            .toLocal()
                            .year,
                        DateTime.parse(element.time.toString())
                            .toLocal()
                            .month,
                        DateTime.parse(element.time.toString())
                            .toLocal()
                            .day),
                    groupSeparatorBuilder:
                        (NotificationHistoryData element) => Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent.withAlpha(20)),
                      height: 50,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withAlpha(60),
                            border: Border.all(
                              color: Colors.black87.withAlpha(20),
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat("MMM dd, yyyy  EEEE").format(
                                  DateTime.parse(element.time.toString())
                                      .toLocal()),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
