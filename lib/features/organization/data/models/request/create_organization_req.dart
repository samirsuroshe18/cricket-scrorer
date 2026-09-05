import 'package:json_annotation/json_annotation.dart';

part 'create_organization_req.g.dart';

@JsonSerializable()
class CreateOrganizationReq {
  final String name;

  CreateOrganizationReq({required this.name});

  factory CreateOrganizationReq.fromJson(Map<String, dynamic> json) =>
      _$CreateOrganizationReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrganizationReqToJson(this);
}
