import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:get/get.dart';

class ImagePreviewController extends GetxController {
  late final CricketImageSource source;

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    if (args is CricketImageSource) {
      source = args;
    }
  }
}
