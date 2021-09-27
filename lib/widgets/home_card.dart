
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeCardWidget extends StatelessWidget {
  final String assetName, name;
  const HomeCardWidget({
    Key? key, required this.assetName, required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 40,
      child: Column(
        children: [
          Lottie.asset(
            'assets/'+assetName+'.json',
            repeat: true,
            reverse: true,
            animate: true,
            height: 150,
            width: 150,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
