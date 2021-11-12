import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class NotificationTile extends StatelessWidget {
  NotificationHistoryData ntData;
  int n;

  NotificationTile(this.ntData, this.n, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

  var dateUtc = ntData.time;
  var strToDateTime = DateTime.parse(dateUtc.toString());
  final convertLocal = strToDateTime.toLocal();
  var newFormat = DateFormat("MMM dd, yyyy hh:mm aaa");
  String dateLocal = newFormat.format(convertLocal);

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
                   dateLocal.toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(ntData.title),
                  subtitle: Text(ntData.message),
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Lottie.asset(
                      'assets/notification_bell.json',
                      repeat: true,
                      animate: true,
                      height: 50,
                      width: 50,
                    ),
                  ),
                  // trailing: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
