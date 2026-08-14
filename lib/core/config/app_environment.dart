/// Runtime environment for the Customer app.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'development':
      case 'dev':
      case 'debug':
      default:
        return AppEnvironment.development;
    }
  }

  String get label => name;
}
