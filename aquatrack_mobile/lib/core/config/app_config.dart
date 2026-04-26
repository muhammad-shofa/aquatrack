class AppConfig {
  // Ubah nilai ini sesuai IP lokal laptop/PC backend kamu.
  // Contoh: 192.168.1.10
  static const String serverHost = '192.168.1.14';
  static const int serverPort = 8000;
  static const String apiPrefix = '/api/v1';

  static String get baseUrl => 'http://$serverHost:$serverPort$apiPrefix';
}
