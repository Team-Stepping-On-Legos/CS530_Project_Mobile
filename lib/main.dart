import 'dart:convert';

import 'package:cs530_mobile/views/event_detail.dart';
import 'package:cs530_mobile/views/splash.dart';
import 'package:cs530_mobile/views/upcoming_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'controllers/api.dart';
import 'controllers/localdb.dart';
import 'models/calendar_item.dart';

void main() async {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          // ledColor: Colors.white
        )
      ]);

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

// FCM ON BACKGROUND HANDLE MESSAGE RECIEVED
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  print(message.data.toString());

  List<dynamic> _mutedEventsList = [];
  await readContent("mutedevents").then((String? value) {
    if (value != null) {
      _mutedEventsList = jsonDecode(value);
    }
  });

  bool muteNotification = false;
  if (_mutedEventsList.isNotEmpty) {
    _mutedEventsList.forEach((mci) => {
          if (message.data['eventId'] == (mci.toString()))
            {print('THIS MESSAGE SHOULD MUTE ITSELF'), muteNotification = true}
        });
  }
  if (!muteNotification) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: DateTime.now().microsecond,
            channelKey: 'basic_channel',
            title: message.data['title']!,
            body: message.data['body']!));
  }
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

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Allow Notifications'),
                  content: const Text(
                      'Volutary Spam App would like to spam you with notifications'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Don\'t Allow',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        )),
                    TextButton(
                      onPressed: () => AwesomeNotifications()
                          .requestPermissionToSendNotifications()
                          .then((value) => Navigator.pop(context)),
                      child: const Text(
                        'Allow',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ));
      }
    });

    AwesomeNotifications().actionStream.listen((event) {

      if(event.channelKey == 'basic_channel' ){
        AwesomeNotifications().getGlobalBadgeCounter().then((value) => 
        AwesomeNotifications().setGlobalBadgeCounter(value-1)
        );
      }

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const UpcomingViewCalendar(
                subscribedCategories: 'All',
              )));
      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> const UpcomingViewCalendar(subscribedCategories: 'All',)), (route) => false);
    });

    

    //FCM ON FOREGROUND MESSAGE RECIEVED
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("message recieved");
      List<CalendarItem> _calendarItemsList = [];
      CalendarItem? cl;
      await API.getCalendarItems('All').then((response) {
        Iterable list = json.decode(response.body);
        _calendarItemsList =
            list.map((model) => CalendarItem.fromJson(model)).toList();
      });

      List<dynamic> _mutedEventsList = [];
      await readContent("mutedevents").then((String? value) {
        if (value != null) {
          _mutedEventsList = jsonDecode(value);
        }
      });

      bool muteNotification = false;
      if (_mutedEventsList.isNotEmpty) {
        _mutedEventsList.forEach((mci) => {
              if (message.data['eventId'] == (mci.toString()))
                {
                  print('THIS MESSAGE SHOULD MUTE ITSELF'),
                  muteNotification = true
                }
            });
      }
      if (!muteNotification) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: DateTime.now().microsecond,
                channelKey: 'basic_channel',
                title: message.data['title']!,
                body: message.data['body']!));
      }
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       bool eventFound = false;
      //       for (var element in _calendarItemsList) {
      //         if (message.data['eventId'] == element.id) {
      //           eventFound = true;
      //           cl = element;
      //         }
      //       }
      //       return AlertDialog(
      //         title: Text(message.data['title']!),
      //         content: Text(message.data['body']!),
      //         actions: [
      //           TextButton(
      //             child: eventFound ? const Text("VIEW") : const Text("CLOSE"),
      //             onPressed: () {
      //               eventFound
      //                   ? {
      //                       Navigator.of(context).pop(),
      //                       Navigator.of(context).push(MaterialPageRoute(
      //                           builder: (context) => EventDetail(cl!, false)))
      //                     }
      //                   : Navigator.of(context).pop();
      //             },
      //           )
      //         ],
      //       );
      //     });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    super.dispose();
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
