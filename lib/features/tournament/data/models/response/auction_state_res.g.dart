// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_state_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuctionStartRes _$AuctionStartResFromJson(Map<String, dynamic> json) =>
    AuctionStartRes(
      tournamentId: json['tournamentId'] as String,
      sessionId: json['sessionId'] as String,
      status: json['status'] as String,
      lotCount: (json['lotCount'] as num).toInt(),
    );

Map<String, dynamic> _$AuctionStartResToJson(AuctionStartRes instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'sessionId': instance.sessionId,
      'status': instance.status,
      'lotCount': instance.lotCount,
    };

AuctionPauseResumeRes _$AuctionPauseResumeResFromJson(
  Map<String, dynamic> json,
) => AuctionPauseResumeRes(
  tournamentId: json['tournamentId'] as String,
  status: json['status'] as String,
  currentLotEndsAt: json['currentLotEndsAt'] == null
      ? null
      : DateTime.parse(json['currentLotEndsAt'] as String),
);

Map<String, dynamic> _$AuctionPauseResumeResToJson(
  AuctionPauseResumeRes instance,
) => <String, dynamic>{
  'tournamentId': instance.tournamentId,
  'status': instance.status,
  'currentLotEndsAt': instance.currentLotEndsAt?.toIso8601String(),
};

AuctionNextLotRes _$AuctionNextLotResFromJson(Map<String, dynamic> json) =>
    AuctionNextLotRes(
      tournamentId: json['tournamentId'] as String,
      completed: json['completed'] as bool,
      lot: json['lot'] == null
          ? null
          : AuctionLotRes.fromJson(json['lot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuctionNextLotResToJson(AuctionNextLotRes instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'completed': instance.completed,
      'lot': instance.lot?.toJson(),
    };

AuctionStateRes _$AuctionStateResFromJson(Map<String, dynamic> json) =>
    AuctionStateRes(
      sessionStatus: json['sessionStatus'] as String?,
      lot: json['lot'] == null
          ? null
          : AuctionLotRes.fromJson(json['lot'] as Map<String, dynamic>),
      bidHistory: (json['bidHistory'] as List<dynamic>)
          .map((e) => AuctionBidEventRes.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgets: (json['budgets'] as List<dynamic>)
          .map((e) => AuctionBudgetRes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuctionStateResToJson(AuctionStateRes instance) =>
    <String, dynamic>{
      'sessionStatus': instance.sessionStatus,
      'lot': instance.lot?.toJson(),
      'bidHistory': instance.bidHistory.map((e) => e.toJson()).toList(),
      'budgets': instance.budgets.map((e) => e.toJson()).toList(),
    };

AuctionLotRes _$AuctionLotResFromJson(Map<String, dynamic> json) =>
    AuctionLotRes(
      lotId: json['lotId'] as String,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String?,
      playerRole: json['playerRole'] as String?,
      basePrice: (json['basePrice'] as num).toInt(),
      currentBid: (json['currentBid'] as num).toInt(),
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
    );

Map<String, dynamic> _$AuctionLotResToJson(AuctionLotRes instance) =>
    <String, dynamic>{
      'lotId': instance.lotId,
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'playerRole': instance.playerRole,
      'basePrice': instance.basePrice,
      'currentBid': instance.currentBid,
      'endsAt': instance.endsAt?.toIso8601String(),
    };

AuctionBidEventRes _$AuctionBidEventResFromJson(Map<String, dynamic> json) =>
    AuctionBidEventRes(
      bidderTeamId: json['bidderTeamId'] as String,
      bidderTeamName: json['bidderTeamName'] as String,
      amount: (json['amount'] as num).toInt(),
      at: DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$AuctionBidEventResToJson(AuctionBidEventRes instance) =>
    <String, dynamic>{
      'bidderTeamId': instance.bidderTeamId,
      'bidderTeamName': instance.bidderTeamName,
      'amount': instance.amount,
      'at': instance.at.toIso8601String(),
    };

AuctionBudgetRes _$AuctionBudgetResFromJson(Map<String, dynamic> json) =>
    AuctionBudgetRes(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      ownerId: json['ownerId'] as String,
      budget: (json['budget'] as num).toInt(),
      spent: (json['spent'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
    );

Map<String, dynamic> _$AuctionBudgetResToJson(AuctionBudgetRes instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'ownerId': instance.ownerId,
      'budget': instance.budget,
      'spent': instance.spent,
      'remaining': instance.remaining,
    };
