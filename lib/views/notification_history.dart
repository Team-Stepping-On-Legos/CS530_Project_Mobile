import 'dart:convert';

import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return ModalProgressHUD(
      inAsyncCall: _downloadNotificationDataCheck,
      child: RefreshIndicator(
        onRefresh: () => _getNotificationHistory(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('NOTIFICATION HISTORY'),
          ),
          body: ListView(
            reverse: true,
            shrinkWrap: true,
            children: [
              ..._notificationHistoryList.reversed.map((event) {
                return Center(child: Tile(event));
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  NotificationHistoryData ntData;

  Tile(this.ntData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 10.0),
            child: Text(
              formatDate(DateTime.parse(ntData.time),
                  [mm, '-', dd, '-', yyyy, ' ', HH, ':', nn]).toString(),
              style: const TextStyle(
                color: Colors.grey,
                wordSpacing: 5.0,
              ),
            ),
          ),
          ListTile(
            title: Text(ntData.title),
            subtitle: Text(ntData.message),
            isThreeLine: true,
            leading: const CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.orange,
                )),
            trailing: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
