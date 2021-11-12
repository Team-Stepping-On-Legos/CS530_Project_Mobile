import 'dart:convert';

import 'controllers/api.dart';
import 'controllers/localdb.dart';
import 'views/event_detail.dart';
import 'views/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'models/calendar_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().whenComplete(() {
    print("Completed intializing Firebase Core");
  });

  //FBM SETUP
  FirebaseMessaging.instance.requestPermission();

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //  on Background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  List<dynamic> _mutedEventsList = [];
  await readContent("mutedevents").then((String? value) {
    if (value != null) {
      _mutedEventsList = jsonDecode(value);
    }
  });

  _mutedEventsList.isNotEmpty
      ? _mutedEventsList.forEach((mci) => {
            message.data.containsValue(mci.toString())
                ? {print('THIS MESSAGE SHOULD MUTE ITSELF')}
                : {
                    print(
                        "Handling a background message: ${message.messageId}"),
                    print(message.notification.toString())
                  }
          })
      : {
          print("Handling a background message: ${message.messageId}"),
          print(message.notification.toString())
        };
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      List<CalendarItem> _calendarItemsList = [];
      await API.getCalendarItems('All').then((response) {
        Iterable list = json.decode(response.body);
        _calendarItemsList =
            list.map((model) => CalendarItem.fromJson(model)).toList();
      });

      print("message recieved");
      print(message.notification!.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification!.title!),
              content: Text(message.notification!.body!),
              actions: [
                TextButton(
                  child: const Text("VIEW"),
                  onPressed: () {
                    for (var element in _calendarItemsList) {
                      if (message.data['eventId'] == element.id) {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EventDetail(element, false)));
                      }
                    }
                  },
                )
              ],
            );
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      List<CalendarItem> _calendarItemsList = [];
      await API.getCalendarItems('All').then((response) {
        Iterable list = json.decode(response.body);
        _calendarItemsList =
            list.map((model) => CalendarItem.fromJson(model)).toList();
      });
      _calendarItemsList.forEach((element) {
        if (message.data['eventId'] == element.id) {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EventDetail(element, false)));
        } else {
          Navigator.of(context).pop();
        }
      });
      print('Message clicked!');
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VOLUNTARY SPAM APP',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        secondaryHeaderColor: Colors.black87,
      ),
      home: const SplashScreen(),
    );
  }
}
