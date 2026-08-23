import 'package:cricket_scorer/config/flavor_config.dart';
import 'package:cricket_scorer/core/services/flavor_service.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClientService extends GetxService {
  late final io.Socket _socket;

  late FlavorConfig _flavorConfig;

  io.Socket get socket => _socket;

  Future<SocketClientService> init() async {
    _flavorConfig = Get.find<FlavorService>().config;

    final socketUrl = _flavorConfig.baseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    return this;
  }
}
