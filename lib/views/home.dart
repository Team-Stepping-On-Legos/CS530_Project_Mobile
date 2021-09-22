import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  
  const HomeScreen({ Key? key }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOLUNTARY SPAM APP'),    
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: Center(
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,    
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('HOME PAGE\nCOMING SOON',style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}