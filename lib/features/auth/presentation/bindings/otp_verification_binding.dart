import 'package:cricket_scorer/features/auth/domain/usecases/resend_otp.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/verify_otp.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/otp_verification_controller.dart';
import 'package:get/get.dart';

class OtpVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpVerificationController>(
      () => OtpVerificationController(
        verifyOtpUseCase: Get.find<VerifyOtpUseCase>(),
        resendOtpUseCase: Get.find<ResendOtpUseCase>(),
      ),
    );
  }
}
