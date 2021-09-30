import 'package:avatar_glow/avatar_glow.dart';
import 'package:cs530_mobile/controllers/localdb.dart';
import 'package:cs530_mobile/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    _bc = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
    ba = CurvedAnimation(parent: _bc, curve: Curves.easeIn);
  }

  late Animation<double> ba;

  late AnimationController _bc;

  AlignmentTween aT =
      AlignmentTween(begin: Alignment.topRight, end: Alignment.topLeft);
  AlignmentTween aB =
      AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft);

  Animatable<Color?> darkBackground = TweenSequence<Color?>(
    [
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(
          begin: Colors.deepPurple.withOpacity(.8),
          end: Colors.deepPurple.withOpacity(.8),
        ),
      ),
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(
          begin: Colors.deepPurple.withOpacity(.8),
          end: Colors.deepPurple.withOpacity(.8),
        ),
      ),
    ],
  );

  Animatable<Color?> normalBackground = TweenSequence<Color?>(
    [
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(
          begin: Colors.deepPurple.withOpacity(.6),
          end: Colors.deepPurple.withOpacity(.6),
        ),
      ),
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(
          begin: Colors.deepPurple.withOpacity(.6),
          end: Colors.deepPurple.withOpacity(.6),
        ),
      ),
    ],
  );

  Animatable<Color?> lightBackground = TweenSequence<Color?>(
    [
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(
          begin: Colors.deepPurple.withOpacity(.4),
          end: Colors.indigo.withOpacity(.4),
        ),
      ),
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(
          begin: Colors.indigo.withOpacity(.4),
          end: Colors.deepPurple.withOpacity(.4),
        ),
      ),
    ],
  );


  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;
    const color = Colors.white;
    return _user == null
        ? Scaffold(
            body: Container(
              width: _w,
              height: _h,
              decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: aT.evaluate(ba),
                end: aB.evaluate(ba),
                colors: [
                  darkBackground.evaluate(ba)!,
                  normalBackground.evaluate(ba)!,
                  lightBackground.evaluate(ba)!,
                ],
              ),),
              child: Center(
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
                            child: Lottie.asset('assets/subscriber.json',
                              repeat: true,
                              reverse: true,
                              animate: true,
                              height: 150,
                              width: 150),
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
                        await writeContent("categories",[]);
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
