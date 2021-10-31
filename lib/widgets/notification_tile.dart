import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotificationTile extends StatelessWidget {
  NotificationHistoryData ntData;
  int n;

  NotificationTile(this.ntData, this.n, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: n,
      delay: const Duration(milliseconds: 20),
      child: ScaleAnimation(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInCubic,
        child: SlideAnimation(
          duration: const Duration(milliseconds: 300),
          horizontalOffset: -300,
          verticalOffset: -250,
          curve: Curves.easeInCubic,
          child: Card(
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
                    formatDate(DateTime.parse(ntData.time), [
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
                      am
                    ]).toString(),
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
                      backgroundColor: Colors.orange,
                      child: Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                      )),
                  trailing: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
