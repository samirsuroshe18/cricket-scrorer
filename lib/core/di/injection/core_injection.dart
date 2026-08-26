import 'package:cricket_scorer/config/flavor_config.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/socket_client_service.dart';
import 'package:cricket_scorer/core/services/compression_service.dart';
import 'package:cricket_scorer/core/services/firebase_service.dart';
import 'package:cricket_scorer/core/services/flavor_service.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/notification_service.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:get/get.dart';

class CoreInjection {
  CoreInjection._();

  static Future<void> init({required FlavorConfig flavorConfig}) async {
    await Get.putAsync<NotificationService>(
      () async => NotificationService(),
      permanent: true,
    );
    await Get.putAsync<FirebaseService>(
      () async => FirebaseService(),
      permanent: true,
    );
    await Get.putAsync<FlavorService>(
      () async => FlavorService(flavorConfig).init(),
      permanent: true,
    );
    await Get.putAsync<SharedPreferenceService>(
      () async => SharedPreferenceService().init(),
      permanent: true,
    );
    await Get.putAsync<SecureStorageService>(
      () async => SecureStorageService().init(),
      permanent: true,
    );
    await Get.putAsync<ApiClient>(
      () async => ApiClient().init(),
      permanent: true,
    );
    await Get.putAsync<SocketClientService>(
      () async => SocketClientService().init(),
      permanent: true,
    );
    await Get.putAsync<ThemeService>(
      () async => ThemeService(),
      permanent: true,
    );
    await Get.putAsync<LanguageService>(
      () async => LanguageService(),
      permanent: true,
    );
    await Get.putAsync<CompressionService>(
      () async => CompressionService(),
      permanent: true,
    );
  }
}
