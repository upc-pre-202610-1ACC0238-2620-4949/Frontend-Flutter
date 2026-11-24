import 'dart:convert';

/// Datos que trae la etiqueta QR de un sensor SmartGas.
class SensorQr {
  final String code;
  final String? type;
  final String? name;

  SensorQr(this.code, {this.type, this.name});

  /// Acepta los mismos formatos que la app Android:
  /// JSON {"code":"GLP-CK-01","type":"Gas","name":"..."}, "SMARTGAS;code=...;type=..." o solo el codigo.
  static SensorQr? parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    if (text.startsWith('{')) {
      try {
        final data = json.decode(text) as Map<String, dynamic>;
        final code = '${data['code'] ?? ''}'.trim();
        if (code.isEmpty) return null;
        return SensorQr(code, type: data['type']?.toString(), name: data['name']?.toString());
      } catch (_) {
        return null;
      }
    }

    if (text.toUpperCase().startsWith('SMARTGAS;')) {
      final values = <String, String>{};
      for (final part in text.split(';').skip(1)) {
        final pair = part.split('=');
        if (pair.length == 2) values[pair[0].trim().toLowerCase()] = pair[1].trim();
      }
      final code = values['code'] ?? '';
      return code.isEmpty ? null : SensorQr(code, type: values['type'], name: values['name']);
    }

    return SensorQr(text);
  }
}
