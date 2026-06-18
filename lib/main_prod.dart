import 'package:cricket_scorer/config/app_config.dart';
import 'package:cricket_scorer/config/flavor_config.dart';
import 'package:cricket_scorer/config/flavors.dart';
import 'package:cricket_scorer/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  AppFlavor.setAppFlavor(Flavor.prod);
  await InjectionContainer.init(flavorConfig: ProdFlavorConfig());
  await AppConfig.setup();
}
