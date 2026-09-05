import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/organization/data/data_sources/remote/organization_api_service.dart';
import 'package:cricket_scorer/features/organization/data/organization_endpoint.dart';
import 'package:cricket_scorer/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:cricket_scorer/features/organization/domain/repositories/organization_repository.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_organization.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:get/get.dart';

class OrganizationInjection {
  OrganizationInjection._();

  static void init() {
    const organizationEndpoint = OrganizationEndpoint();

    Get.lazyPut<OrganizationApiService>(
      () => OrganizationApiService(
        apiClient: Get.find<ApiClient>(),
        organizationEndpoint: organizationEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<OrganizationRepository>(
      () => OrganizationRepositoryImpl(
        organizationApiService: Get.find<OrganizationApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateOrganizationUseCase>(
      () => CreateOrganizationUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetMyOrganizationsUseCase>(
      () => GetMyOrganizationsUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetOrganizationUseCase>(
      () => GetOrganizationUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AddOrganizationMemberUseCase>(
      () => AddOrganizationMemberUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RemoveOrganizationMemberUseCase>(
      () => RemoveOrganizationMemberUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateOrganizationTeamUseCase>(
      () => CreateOrganizationTeamUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteOrganizationUseCase>(
      () => DeleteOrganizationUseCase(
        organizationRepository: Get.find<OrganizationRepository>(),
      ),
      fenix: true,
    );

    // Lives on ScoringInjection's MatchRepository, not OrganizationRepository
    // — see this use case's own file comment. Registered here (not in
    // scoring_injection.dart) because it's conceptually an organization
    // action, and ScoringInjection.init() already runs before this file's
    // init() (see injection_container.dart), so MatchRepository exists by
    // the time this resolves it.
    Get.lazyPut<UpdateTeamOrganizationUseCase>(
      () => UpdateTeamOrganizationUseCase(
        matchRepository: Get.find<MatchRepository>(),
      ),
      fenix: true,
    );
  }
}
