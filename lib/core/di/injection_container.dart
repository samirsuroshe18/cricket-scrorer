import 'package:cricket_scorer/config/flavor_config.dart';
import 'package:cricket_scorer/core/di/injection/auth_injection.dart';
import 'package:cricket_scorer/core/di/injection/core_injection.dart';

class InjectionContainer {
  const InjectionContainer._();

  static Future<void> init({required FlavorConfig flavorConfig}) async {
    await CoreInjection.init(flavorConfig: flavorConfig);

    AuthInjection.init();
  }
}
