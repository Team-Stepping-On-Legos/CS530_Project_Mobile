import 'package:firebase_messaging/firebase_messaging.dart';

class FBM{

final fbm = FirebaseMessaging.instance;
 

Future<void> subscribeTopics(List<String> topics) async {
  for(String topic in topics){    
    // subscribe to topic on each app start-up
    await fbm.subscribeToTopic(topic);
  }  
}

Future<void> subscribeTopic(String topic) async {   
    // subscribe to topic on each app start-up
    await fbm.subscribeToTopic(topic);
}

Future<void> unSubscribeTopic(String topic) async {   
    // subscribe to topic on each app start-up
    await fbm.unsubscribeFromTopic(topic);
}

}