import 'package:flutter/material.dart';

import '../../common/api_config.dart';
import '../../shared/presentation/app_theme.dart';
import '../data/monitoring_service.dart';
import '../domain/zone.dart';

/// Formulario para crear una zona nueva o editar una existente (si recibe [zone]).
/// Al guardar devuelve la zona creada o actualizada.
class ZoneFormPage extends StatefulWidget {
  final Zone? zone;

  const ZoneFormPage({this.zone, super.key});

  @override
  State<ZoneFormPage> createState() => _ZoneFormPageState();
}

class _ZoneFormPageState extends State<ZoneFormPage> {
  final _service = MonitoringService();
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.zone?.name ?? '');
  late final _descriptionController = TextEditingController(text: widget.zone?.description ?? '');
  late String _sensitivity = widget.zone?.sensitivity ?? 'Medium';

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.zone != null;

  static const _sensitivities = {
    'Low': 'Baja: tolera más gas antes de alertar',
    'Medium': 'Media: recomendada para cocinas',
    'High': 'Alta: alerta ante el mínimo cambio',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final zone = _isEditing
          ? await _service.updateZone(widget.zone!.id, name: name, description: description, sensitivity: _sensitivity)
          : await _service.createZone(name: name, description: description, sensitivity: _sensitivity);
      if (!mounted) return;
      Navigator.pop(context, zone);
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 409
          ? 'Tu plan no permite más zonas. Cambia de plan para agregar otra.'
          : 'No se pudo guardar la zona (${e.statusCode}).');
    } catch (_) {
      setState(() => _error = 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(10));

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar zona' : 'Nueva zona')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: 'Nombre', hintText: 'Cocina principal', border: border),
              validator: (value) => (value ?? '').trim().isEmpty ? 'Ingresa un nombre para la zona' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Cocina a gas de 6 hornillas junto a la ventana',
                border: border,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Sensibilidad de las alertas', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            RadioGroup<String>(
              groupValue: _sensitivity,
              onChanged: (value) => setState(() => _sensitivity = value ?? _sensitivity),
              child: Column(
                children: _sensitivities.entries
                    .map((entry) => RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: entry.key,
                          title: Text(entry.value),
                        ))
                    .toList(),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: AppColors.red)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Guardar cambios' : 'Crear zona'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
