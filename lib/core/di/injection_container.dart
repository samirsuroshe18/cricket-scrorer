import 'package:cricket_scorer/config/flavor_config.dart';
import 'package:cricket_scorer/core/di/injection/auth_injection.dart';
import 'package:cricket_scorer/core/di/injection/core_injection.dart';
import 'package:cricket_scorer/core/di/injection/global_injection.dart';
import 'package:cricket_scorer/core/di/injection/organization_injection.dart';
import 'package:cricket_scorer/core/di/injection/scoring_injection.dart';
import 'package:cricket_scorer/core/di/injection/search_injection.dart';
import 'package:cricket_scorer/core/di/injection/tournament_injection.dart';

class InjectionContainer {
  const InjectionContainer._();

  static Future<void> init({required FlavorConfig flavorConfig}) async {
    await CoreInjection.init(flavorConfig: flavorConfig);

    GlobalInjection.init();
    AuthInjection.init();
    ScoringInjection.init();
    OrganizationInjection.init();
    TournamentInjection.init();
    SearchInjection.init();
  }
}
