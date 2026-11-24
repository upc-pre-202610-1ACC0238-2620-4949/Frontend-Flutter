import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/api_config.dart';
import '../domain/account.dart';

/// Bounded context IAM: inicio de sesion contra POST /auth/sign-in.
class AuthService {
  Future<Account> signIn(String email, String password) async {
    final response = await http.post(
      ApiConfig.uri('auth/sign-in'),
      headers: ApiConfig.jsonHeaders,
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return Account.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// POST /auth/sign-up. role: HomeOwner (hogar) o RestaurantAdministrator (restaurante).
  /// 409 = el correo ya esta registrado.
  Future<Account> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? businessName,
    String? phone,
    String? district,
  }) async {
    final response = await http.post(
      ApiConfig.uri('auth/sign-up'),
      headers: ApiConfig.jsonHeaders,
      body: json.encode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        'businessName': businessName,
        'phone': phone,
        'district': district,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
    return Account.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
