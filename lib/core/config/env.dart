class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3333/',
  );
  static const logNetwork = bool.fromEnvironment(
    'LOG_NETWORK',
    defaultValue: true,
  );
}
