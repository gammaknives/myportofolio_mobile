/// Base URL of the Django REST Framework backend.
///
/// Defaults to `http://10.0.2.2:8000` (alamat mesin pengembangan yang dapat
/// dijangkau dari emulator Android).
/// Override dengan `--dart-define=API_BASE_URL=http://localhost:8000` jika
/// menguji di Chrome/Web.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
