import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento local del telefono (SharedPreferences): sesion, ultimo correo y datos en cache.
class LocalStorage {
  static const _accountKey = 'session_account';
  static const _lastEmailKey = 'last_email';
  static const _zonesKey = 'cached_zones';
  static const _zonesTimeKey = 'cached_zones_time';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Map<String, dynamic>? loadAccount() {
    final raw = _prefs.getString(_accountKey);
    return raw == null ? null : json.decode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveAccount(Map<String, dynamic> account) =>
      _prefs.setString(_accountKey, json.encode(account));

  static Future<void> clearAccount() async {
    await _prefs.remove(_accountKey);
    await _prefs.remove(_zonesKey);
    await _prefs.remove(_zonesTimeKey);
  }

  static String get lastEmail => _prefs.getString(_lastEmailKey) ?? '';

  static Future<void> saveLastEmail(String email) => _prefs.setString(_lastEmailKey, email);

  /// Ultimas zonas descargadas, para mostrarlas sin conexion.
  static Future<void> cacheZones(List<Map<String, dynamic>> zones) async {
    await _prefs.setString(_zonesKey, json.encode(zones));
    await _prefs.setString(_zonesTimeKey, DateTime.now().toIso8601String());
  }

  static List<Map<String, dynamic>> get cachedZones {
    final raw = _prefs.getString(_zonesKey);
    if (raw == null) return [];
    return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static DateTime? get cachedZonesTime => DateTime.tryParse(_prefs.getString(_zonesTimeKey) ?? '');
}
