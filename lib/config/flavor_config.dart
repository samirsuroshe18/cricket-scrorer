import 'package:cricket_scorer/config/environment/app_environment.dart';

abstract class FlavorConfig {
  String get baseUrl;
}

class DevFlavorConfig extends FlavorConfig {
  @override
  String get baseUrl => AppEnvironment.devBaseUrl;
}

class UatFlavorConfig extends FlavorConfig {
  @override
  String get baseUrl => AppEnvironment.uatBaseUrl;
}

class ProdFlavorConfig extends FlavorConfig {
  @override
  String get baseUrl => AppEnvironment.prodBaseUrl;
}
