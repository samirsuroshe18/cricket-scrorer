// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_event_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuctionBidAcceptedRes _$AuctionBidAcceptedResFromJson(
  Map<String, dynamic> json,
) => AuctionBidAcceptedRes(
  lotId: json['lotId'] as String,
  amount: (json['amount'] as num).toInt(),
  bidderTeamId: json['bidderTeamId'] as String,
  bidderTeamName: json['bidderTeamName'] as String,
  endsAt: DateTime.parse(json['endsAt'] as String),
);

Map<String, dynamic> _$AuctionBidAcceptedResToJson(
  AuctionBidAcceptedRes instance,
) => <String, dynamic>{
  'lotId': instance.lotId,
  'amount': instance.amount,
  'bidderTeamId': instance.bidderTeamId,
  'bidderTeamName': instance.bidderTeamName,
  'endsAt': instance.endsAt.toIso8601String(),
};

AuctionBidRejectedRes _$AuctionBidRejectedResFromJson(
  Map<String, dynamic> json,
) => AuctionBidRejectedRes(
  code: json['code'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$AuctionBidRejectedResToJson(
  AuctionBidRejectedRes instance,
) => <String, dynamic>{'code': instance.code, 'message': instance.message};

AuctionLotResolvedRes _$AuctionLotResolvedResFromJson(
  Map<String, dynamic> json,
) => AuctionLotResolvedRes(
  lotId: json['lotId'] as String,
  outcome: json['outcome'] as String,
  soldPrice: (json['soldPrice'] as num?)?.toInt(),
  soldTo: json['soldTo'] as String?,
  spent: (json['spent'] as num?)?.toInt(),
  remaining: (json['remaining'] as num?)?.toInt(),
);

Map<String, dynamic> _$AuctionLotResolvedResToJson(
  AuctionLotResolvedRes instance,
) => <String, dynamic>{
  'lotId': instance.lotId,
  'outcome': instance.outcome,
  'soldPrice': instance.soldPrice,
  'soldTo': instance.soldTo,
  'spent': instance.spent,
  'remaining': instance.remaining,
};

AuctionResumedRes _$AuctionResumedResFromJson(Map<String, dynamic> json) =>
    AuctionResumedRes(
      currentLotEndsAt: json['currentLotEndsAt'] == null
          ? null
          : DateTime.parse(json['currentLotEndsAt'] as String),
    );

Map<String, dynamic> _$AuctionResumedResToJson(AuctionResumedRes instance) =>
    <String, dynamic>{
      'currentLotEndsAt': instance.currentLotEndsAt?.toIso8601String(),
    };
