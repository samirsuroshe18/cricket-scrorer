import 'package:cricket_scorer/core/global/presentation/controllers/image_preview_controller.dart';
import 'package:get/get.dart';

class ImagePreviewBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=> ImagePreviewController());
  }
}