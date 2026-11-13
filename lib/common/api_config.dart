/// Direccion del backend SmartGas.Api (el mismo que usan la web y la app Android).
class ApiConfig {
  /// Backend desplegado en Render. Para probar con la API local desde el emulador usar
  /// http://10.0.2.2:5048/api/v1 (10.0.2.2 es la PC vista desde el emulador de Android).
  static const String baseUrl = 'https://backend-rxmh.onrender.com/api/v1';

  static Uri uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl/$path').replace(queryParameters: query);

  static const Map<String, String> jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}

/// Error de la API con el codigo HTTP (401 = credenciales invalidas, etc.).
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
