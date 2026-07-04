import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService{
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin get plugin => _flutterLocalNotificationsPlugin;

  //Android settings
  final AndroidInitializationSettings _initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  
  //iOS settings
  final DarwinInitializationSettings _initializationSettingsDarwin = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    defaultPresentAlert: true,
    defaultPresentBadge: true,
    defaultPresentSound: true,
  );
  
  //Notification channel details (Android)
  final AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    // ticker: 'ticker',
    ongoing: true,
    autoCancel: true,
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList(const[0, 500, 200, 500]),
  );
  
  //iOS notification details
  final DarwinNotificationDetails _iosDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'default',
    threadIdentifier: 'cricket'
  );
  
  @override
  Future<void> onInit() async {
    super.onInit();
    final settings = InitializationSettings(
      android: _initializationSettingsAndroid,
      iOS: _initializationSettingsDarwin
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onSelectNotification
    );
  }
  
  Future<void> _onSelectNotification(NotificationResponse response)async {
    if(response.payload != null){
      if (kDebugMode) {
        print('Notification Payload : ${response.payload}');
      }
    }
  }

  void cancelAll(){
    plugin.cancelAll();
  }

  Future<void> show({
    required String? title,
    required String? body,
    String? payload,
  }) async {
    final details = NotificationDetails(
      android: _androidDetails,
      iOS: _iosDetails
    );

    await _flutterLocalNotificationsPlugin.show(
      id: Random().nextInt(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}