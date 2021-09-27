import 'dart:async';
import 'package:cs530_mobile/views/get_started.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    Timer(
        const Duration(seconds: 4),
        () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
               return const GetStarted();
            })));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg.jpg"), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'VOLUNTARY SPAM',
                style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'APP',
                style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 45,
              ),
              Lottie.asset('assets/subscriber.json',
                  repeat: false, reverse: false, animate: true),
            ],
          ),
        ),
      ),
    );
  }
}
