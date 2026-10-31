/// Which app is running. The server calls the customer app "user".
enum BarqAppKind { customer, driver }

/// Build-time settings. The key comes from --dart-define, never from code.
class BarqEnv {
  static const baseUrl = 'https://masar.toldpath.com/api/v1';
  static const projectKey = String.fromEnvironment('BARQ_PROJECT_KEY');
  static const devMember = String.fromEnvironment('BARQ_DEV');
}
