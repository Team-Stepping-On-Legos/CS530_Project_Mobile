import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class HomeTopViewWidget extends StatelessWidget {
  const HomeTopViewWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.deepPurple,
      decoration: const BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/bg.jpg"), fit: BoxFit.fill)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 60,
            ),
            Lottie.asset('assets/subscriber.json',
                repeat: true,
                reverse: true,
                animate: true,
                height: 150,
                width: 150),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'VOLUNTARY SPAM\nAPP',
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      height: 310,
    );
  }
}
