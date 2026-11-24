import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/api_config.dart';
import '../../common/session.dart';
import '../domain/sensor.dart';

/// Bounded context Kitchen Monitoring: alta, edicion y baja de sensores.
class SensorService {
  /// POST /sensors. 409 = el codigo ya existe o el plan no permite mas sensores.
  Future<Sensor> createSensor({
    required int zoneId,
    required String code,
    required String name,
    required String type,
    required String locationDetail,
  }) async {
    final response = await http.post(
      ApiConfig.uri('sensors'),
      headers: ApiConfig.jsonHeaders,
      body: json.encode({
        'accountId': Session.accountId,
        'zoneId': zoneId,
        'code': code,
        'name': name,
        'type': type,
        'locationDetail': locationDetail,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
    return Sensor.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// PATCH /sensors/{id}: solo se envian los campos que cambian.
  Future<Sensor> updateSensor(
    int id, {
    int? zoneId,
    String? code,
    String? name,
    String? type,
    String? locationDetail,
  }) async {
    final response = await http.patch(
      ApiConfig.uri('sensors/$id'),
      headers: ApiConfig.jsonHeaders,
      body: json.encode({
        'zoneId': ?zoneId,
        'code': ?code,
        'name': ?name,
        'type': ?type,
        'locationDetail': ?locationDetail,
      }),
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return Sensor.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// DELETE /sensors/{id}: tambien borra sus lecturas e incidentes.
  Future<void> deleteSensor(int id) async {
    final response = await http.delete(ApiConfig.uri('sensors/$id'), headers: ApiConfig.jsonHeaders);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }
}
