const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

class AppConfig {
  AppConfig._();

  static bool get isProduction => _env == 'prod';

  /// Base URL sesuai environment
  static const String baseUrl = _env == 'prod'
      ? 'https://api.prod.amio.my.id' // URL Production
      : 'https://unipos-dev-unipos-api-dev.yi8k7d.easypanel.host'; // URL Dev
}
