import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/api_config.dart';
import '../../common/session.dart';
import '../domain/sensor.dart';
import '../domain/sensor_reading.dart';
import '../domain/zone.dart';

/// Bounded context Kitchen Monitoring: zonas, sensores y lecturas.
class MonitoringService {
  Future<List<dynamic>> _getList(String path, int accountId) async {
    final response = await http.get(
      ApiConfig.uri(path, {'accountId': '$accountId'}),
      headers: ApiConfig.jsonHeaders,
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return json.decode(response.body) as List<dynamic>;
  }

  Future<List<Zone>> getZones(int accountId) async =>
      (await _getList('zones', accountId)).map((item) => Zone.fromJson(item)).toList();

  Future<List<Sensor>> getSensors(int accountId) async =>
      (await _getList('sensors', accountId)).map((item) => Sensor.fromJson(item)).toList();

  /// Lecturas ordenadas de la mas nueva a la mas antigua.
  Future<List<SensorReading>> getReadings(int accountId) async {
    final readings = (await _getList('sensor-readings', accountId)).map((item) => SensorReading.fromJson(item)).toList();
    readings.sort((a, b) => (b.time ?? DateTime(0)).compareTo(a.time ?? DateTime(0)));
    return readings;
  }

  /// POST /zones. 409 = el plan ya no permite mas zonas.
  Future<Zone> createZone({required String name, required String description, required String sensitivity}) async {
    final response = await http.post(
      ApiConfig.uri('zones'),
      headers: ApiConfig.jsonHeaders,
      body: json.encode({
        'accountId': Session.accountId,
        'name': name,
        'description': description,
        'sensitivity': sensitivity,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
    return Zone.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// PUT /zones/{id}
  Future<Zone> updateZone(int id, {required String name, required String description, required String sensitivity}) async {
    final response = await http.put(
      ApiConfig.uri('zones/$id'),
      headers: ApiConfig.jsonHeaders,
      body: json.encode({'name': name, 'description': description, 'sensitivity': sensitivity}),
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return Zone.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// DELETE /zones/{id}. 409 = la zona todavia tiene sensores.
  Future<void> deleteZone(int id) async {
    final response = await http.delete(ApiConfig.uri('zones/$id'), headers: ApiConfig.jsonHeaders);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  /// Zonas con la ultima lectura de cada una (gas y temperatura actuales).
  Future<List<Zone>> getZonesWithLatestReading(int accountId) async {
    final results = await Future.wait([getZones(accountId), getReadings(accountId)]);
    final zones = results[0] as List<Zone>;
    final readings = results[1] as List<SensorReading>;

    return zones.map((zone) {
      final latest = readings.where((r) => r.zoneId == zone.id);
      return latest.isEmpty ? zone : zone.withReading(latest.first.gas, latest.first.temperature);
    }).toList();
  }
}
