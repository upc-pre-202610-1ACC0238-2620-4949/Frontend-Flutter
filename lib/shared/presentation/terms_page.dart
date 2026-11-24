import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Terminos y Condiciones y Politica de Privacidad de SmartGas.
/// Se abre desde el registro (hay que aceptarlos) y desde la app en cualquier momento.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const _sections = [
    (
      '1. Sobre SmartGas',
      'SmartGas es un servicio de FireSecure que monitorea niveles de gas y temperatura en cocinas de hogares y '
          'restaurantes mediante sensores IoT, y envía alertas cuando detecta valores peligrosos.',
    ),
    (
      '2. Uso del servicio',
      'Te comprometes a registrar datos verdaderos, a mantener tus sensores instalados según las indicaciones y a '
          'no usar la app para fines distintos a la prevención de incidentes en tu cocina.',
    ),
    (
      '3. Alertas y limitaciones',
      'Las alertas dependen de que los sensores, la conexión a internet y el celular funcionen correctamente. '
          'SmartGas es una herramienta de prevención y no reemplaza a los bomberos, a los servicios de emergencia '
          'ni al mantenimiento de tus instalaciones de gas. Ante una fuga, ventila el ambiente y llama al 116.',
    ),
    (
      '4. Planes y pagos',
      'El plan elegido define cuántas zonas y sensores puedes registrar. Puedes cambiar de plan desde la app; '
          'el cambio se aplica en el siguiente periodo de facturación.',
    ),
    (
      '5. Datos personales',
      'Guardamos tu nombre, correo, teléfono, distrito, tus zonas, sensores, lecturas e incidentes para prestarte '
          'el servicio. No vendemos tus datos. Puedes pedir la eliminación de tu cuenta escribiendo a '
          'soporte@smartgas.pe, de acuerdo con la Ley N.° 29733 de Protección de Datos Personales.',
    ),
    (
      '6. Datos en tu celular',
      'La app guarda en tu teléfono tu sesión y las últimas zonas consultadas para funcionar sin conexión. '
          'Esta información se borra al cerrar sesión.',
    ),
    (
      '7. Cambios en los términos',
      'Si cambiamos estos términos te avisaremos dentro de la app. Seguir usando SmartGas significa que aceptas '
          'la versión vigente.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Términos y condiciones')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text('Última actualización: noviembre de 2026', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          for (final (title, body) in _sections) ...[
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
