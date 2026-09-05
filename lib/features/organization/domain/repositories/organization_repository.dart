import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/request/add_organization_member_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_req.dart';
import 'package:cricket_scorer/features/organization/data/models/request/create_organization_team_req.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';

abstract class OrganizationRepository {
  /// `POST /v1/organization` — caller becomes owner.
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  createOrganization({required CreateOrganizationReq? params});

  /// `GET /v1/organization` — every org the caller owns or belongs to.
  Future<Either<CricketResponse<MyOrganizationsRes>, CricketFailure>>
  getMyOrganizations();

  /// `GET /v1/organization/:orgId` — full member/team detail. Requires
  /// membership; `403 NOT_ORG_MEMBER` if the caller isn't in it.
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>>
  getOrganization({required String orgId});

  /// `POST /v1/organization/:orgId/members` — owner-only, adds an existing
  /// account by exact email.
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>>
  addMember({required String orgId, required AddOrganizationMemberReq? params});

  /// `DELETE /v1/organization/:orgId/members/:userId` — owner removes
  /// anyone but themselves, or a member removes themselves (leave).
  Future<Either<CricketResponse<void>, CricketFailure>> removeMember({
    required String orgId,
    required String userId,
  });

  /// `POST /v1/organization/:orgId/teams` — owner-only, creates a new team
  /// directly under the org.
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>>
  createTeam({
    required String orgId,
    required CreateOrganizationTeamReq? params,
  });

  /// `DELETE /v1/organization/:orgId` — owner-only, soft-deletes; the org's
  /// teams orphan back to standalone server-side.
  Future<Either<CricketResponse<void>, CricketFailure>> deleteOrganization({
    required String orgId,
  });
}
