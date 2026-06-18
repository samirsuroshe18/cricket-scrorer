import 'package:get/get.dart';
import 'package:cricket_scorer/config/flavor_config.dart';

class FlavorService extends GetxService {
  final FlavorConfig config;

  FlavorService(this.config);

  Future<FlavorService> init() async {
    return this;
  }
}