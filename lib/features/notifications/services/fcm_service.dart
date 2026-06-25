import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permissions for iOS
    await _messaging.requestPermission();
    
    // Get token
    // final token = await _messaging.getToken();
    // print('FCM Token: $token');
  }

  Future<void> subscribeToTopic(String topic) async {
    // e.g. "teknoloji"
    await _messaging.subscribeToTopic(topic.toLowerCase().replaceAll(' ', '_'));
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic.toLowerCase().replaceAll(' ', '_'));
  }
}
