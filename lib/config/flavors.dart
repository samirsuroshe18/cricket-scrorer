
enum Flavor {
  /// DEV enviornemnt
  dev,

  /// UAT enviornment
  uat,

  /// PROD enviornment
  prod,
}

class AppFlavor {
  static Flavor appFlavor = Flavor.prod;

  static String get name => appFlavor.name;

  /// set flavor name
  static void setAppFlavor(Flavor flavor) {
    appFlavor = flavor;
  }

  /// returns app Title based on Flavor environment
  static String get title => switch (appFlavor) {
    Flavor.dev  => 'Cricket Scorer Dev',
    Flavor.uat  => 'Cricket Scorer Uat',
    Flavor.prod => 'Cricket Scorer',
  };
}