import 'package:json_annotation/json_annotation.dart';

part 'add_organization_member_req.g.dart';

@JsonSerializable()
class AddOrganizationMemberReq {
  final String email;

  AddOrganizationMemberReq({required this.email});

  factory AddOrganizationMemberReq.fromJson(Map<String, dynamic> json) =>
      _$AddOrganizationMemberReqFromJson(json);

  Map<String, dynamic> toJson() => _$AddOrganizationMemberReqToJson(this);
}
