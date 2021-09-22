import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  
  const HomeScreen({ Key? key }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOLUNTARY SPAM'),    
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: Column(      
        children: const [

        ],
      ),
    );
  }
}