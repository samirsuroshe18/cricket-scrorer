import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:get/get.dart';

class OrganizationsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrganizationsListController>(
      () => OrganizationsListController(
        getMyOrganizationsUseCase: Get.find<GetMyOrganizationsUseCase>(),
        createOrganizationUseCase: Get.find<CreateOrganizationUseCase>(),
      ),
    );
  }
}
