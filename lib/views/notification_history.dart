import 'dart:convert';

import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:cs530_mobile/widgets/notification_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class NotificationHistory extends StatefulWidget {
  final String subscribedCategories;

  const NotificationHistory({required this.subscribedCategories, Key? key})
      : super(key: key);

  @override
  _NotificationHistoryState createState() => _NotificationHistoryState();
}

class _NotificationHistoryState extends State<NotificationHistory> {
  bool _downloadNotificationDataCheck = true;
  List<NotificationHistoryData> _notificationHistoryList = [];

  Future<void> _getNotificationHistory() async {
    return API
        .getNotificationHistory(widget.subscribedCategories)
        .then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        _notificationHistoryList = list
            .map((model) => NotificationHistoryData.fromJson(model))
            .toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getNotificationHistory().then((value) {
      setState(() {
        _downloadNotificationDataCheck = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: _downloadNotificationDataCheck,
      child: RefreshIndicator(
        onRefresh: () => _getNotificationHistory(),
        child: Scaffold(
          appBar: CupertinoNavigationBar(
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.navigate_before_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            middle: const Text(
              'NOTIFICATION HISTORY',
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
                Colors.indigo.shade300.withOpacity(.10),
                Colors.deepPurple.shade300.withOpacity(.10),
                Colors.indigo.shade300.withOpacity(.8),
                Colors.deepPurple.shade300.withOpacity(.8),
              ],
            )),
            child: AnimationLimiter(
              child: ListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                reverse: true,
                shrinkWrap: true,
                children: [                  
                  ..._notificationHistoryList.reversed.map((event) {
                    return Center(child: NotificationTile(event,_notificationHistoryList.indexOf(event)));
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
