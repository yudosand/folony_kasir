class NetworkConfig {
  // 10.0.2.2 points the Android emulator back to the host machine.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const int connectTimeoutSeconds = int.fromEnvironment(
    'API_CONNECT_TIMEOUT_SECONDS',
    defaultValue: 30,
  );

  static const int receiveTimeoutSeconds = int.fromEnvironment(
    'API_RECEIVE_TIMEOUT_SECONDS',
    defaultValue: 60,
  );

  static const int sendTimeoutSeconds = int.fromEnvironment(
    'API_SEND_TIMEOUT_SECONDS',
    defaultValue: 60,
  );

  static const bool enableNetworkLogs = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGS',
    defaultValue: true,
  );

  const NetworkConfig._();
}
