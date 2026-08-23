import 'dart:async';
import 'dart:io';

import 'package:cricket_scorer/config/flavors.dart';
import 'package:cricket_scorer/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cricket_scorer/firebase_options/firebase_options_dev.dart'
    as dev;
import 'package:cricket_scorer/firebase_options/firebase_options_prod.dart'
    as prod;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📩 Background message : ${message.data}');
  }
}

class FirebaseService extends GetxService {
  late FirebaseMessaging _messaging;

  FirebaseMessaging get messaging => _messaging;

  String? _token;

  @override
  Future<void> onInit() async {
    super.onInit();
    FirebaseOptions options;
    if (AppFlavor.appFlavor == Flavor.dev) {
      options = dev.DefaultFirebaseOptions.currentPlatform;
    } else {
      options = prod.DefaultFirebaseOptions.currentPlatform;
    }
    await Firebase.initializeApp(options: options);
    _messaging = FirebaseMessaging.instance;

    unawaited(generateToken());

    //Request permission for iOS
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print('Foreground message : ${message.data}');
      }

      if (Platform.isAndroid) {
        unawaited(
          Get.find<NotificationService>().show(
            title: message.notification?.title,
            body: message.notification?.body,
            payload: message.data.toString(),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Open from background data : ${message.data}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> generateToken() async {
    try {
      _token ??= await _messaging.getToken();
      if (kDebugMode) {
        print('🔑 Fcm Token : $_token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔑 Fcm Error : $e');
      }
    }
    return _token;
  }
}
