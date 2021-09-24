import 'package:avatar_glow/avatar_glow.dart';
import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:cs530_mobile/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    const color = Colors.white;
    return _user == null
        ? Scaffold(
            backgroundColor: const Color(0xFF8185E2),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AvatarGlow(
                    endRadius: 90,
                    duration: const Duration(seconds: 2),
                    glowColor: Colors.white24,
                    repeat: true,
                    repeatPauseDuration: const Duration(seconds: 2),
                    startDelay: const Duration(seconds: 1),
                    child: Material(
                        elevation: 8.0,
                        shape: const CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 50.0,
                            color: Color(0xFF8185E2),
                          ),
                          radius: 50.0,
                        )),
                  ),
                  const Center(
                    child: Text(
                      "Hello!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35.0,
                          color: color),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Welcome to Voluntary Spam",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                          color: color),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  const Center(
                    child: Text(
                      "We noticed",
                      style: TextStyle(fontSize: 20.0, color: color),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "It is your first time here",
                      style: TextStyle(fontSize: 20.0, color: color),
                    ),
                  ),
                  const SizedBox(
                    height: 100.0,
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Center(
                      child: TextButton(
                    onPressed: () async {                      
                      await writeContent([]);
                      signInAnonymously();
                    },
                    child: Text(
                      "Get Started".toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: color),
                    ),
                  )),
                ],
              ),
            ))
        : const HomeScreen();
  }

  void signInAnonymously() {
    _auth.signInAnonymously().then((result) {
      setState(() {
        _user = result.user;
      });
    });
  }
}
