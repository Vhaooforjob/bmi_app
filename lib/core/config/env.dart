class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bmi-server-tj6r.onrender.com/',
  );
  static const logNetwork = bool.fromEnvironment(
    'LOG_NETWORK',
    defaultValue: true,
  );
}
