import 'package:flutter/material.dart';

import '../../common/api_config.dart';
import '../../common/json_utils.dart';
import '../../common/session.dart';
import '../../shared/presentation/app_theme.dart';
import '../../shared/presentation/widgets.dart';
import '../data/monitoring_service.dart';
import '../domain/sensor.dart';
import '../domain/sensor_reading.dart';
import '../domain/zone.dart';
import 'zone_form_page.dart';

/// Umbral de gas por defecto (el mismo que usa la app Android si no hay ajustes).
const double gasThreshold = 50;

/// Diseno 06: detalle de zona con su estado, ultimas lecturas y sensores.
class ZoneDetailPage extends StatefulWidget {
  final Zone zone;

  const ZoneDetailPage(this.zone, {super.key});

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  final _service = MonitoringService();

  late Zone _zone = widget.zone;
  bool _changed = false;
  List<Sensor> _sensors = [];
  List<SensorReading> _readings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final accountId = Session.accountId;
      final results = await Future.wait([_service.getSensors(accountId), _service.getReadings(accountId)]);
      setState(() {
        _sensors = (results[0] as List<Sensor>).where((s) => s.zoneId == _zone.id).toList();
        _readings = (results[1] as List<SensorReading>).where((r) => r.zoneId == _zone.id).toList();
      });
    } catch (_) {
      setState(() => _error = 'No se pudieron cargar los sensores.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Ultima lectura de un sensor (para "41 ppm" a la derecha de cada sensor).
  SensorReading? _latestFor(Sensor sensor) {
    for (final reading in _readings) {
      if (reading.sensorId == sensor.id) return reading;
    }
    return null;
  }

  Future<void> _editZone() async {
    final updated = await Navigator.push<Zone>(context, MaterialPageRoute(builder: (_) => ZoneFormPage(zone: _zone)));
    if (updated == null) return;
    setState(() {
      _zone = updated.withReading(_zone.gasLevel, _zone.temperature);
      _changed = true;
    });
  }

  Future<void> _deleteZone() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar zona'),
        content: Text('¿Eliminar «${_zone.name}»? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await MonitoringService().deleteZone(_zone.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.statusCode == 409
            ? 'La zona todavía tiene sensores. Elimínalos primero.'
            : 'No se pudo eliminar la zona (${e.statusCode}).'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo conectar con el servidor.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final zone = _zone;
    final color = statusColor(zone.status);
    final gas = _readings.isNotEmpty ? (_readings.first.gas ?? zone.gasLevel) : zone.gasLevel;
    final percent = gas == null ? null : (gas / gasThreshold * 100).round();

    return PopScope(
      canPop: false,
      // Al volver avisa a la lista si la zona cambio, para que se recargue
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(zone.name),
          actions: [
            IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Editar zona', onPressed: _editZone),
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Eliminar zona', onPressed: _deleteZone),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tarjeta de estado de la zona
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estado de la zona', style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text(zone.status, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          Text(
                            gas == null
                                ? 'Sin lecturas de gas'
                                : 'Gas en ${formatNumber(gas)} ppm · $percent % del umbral de ${gasThreshold.toInt()} ppm',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      zone.status.toLowerCase() == 'safe' ? Icons.verified_user_outlined : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ],
                ),
              ),
              if (zone.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(zone.description, style: const TextStyle(color: AppColors.muted)),
              ],
              const SizedBox(height: 16),
              const Text('Últimas lecturas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Card(
                child: _readings.isEmpty
                    ? const Padding(padding: EdgeInsets.all(16), child: Text('Aún no hay lecturas en esta zona.'))
                    : Column(
                        children: _readings
                            .take(5)
                            .map((r) => ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: (r.gas ?? 0) >= gasThreshold ? AppColors.red : AppColors.green,
                                  ),
                                  title: Text('Gas ${formatNumber(r.gas)} ppm · Temp ${formatNumber(r.temperature)} °C'),
                                  trailing: Text(formatShortDate(r.time), style: const TextStyle(color: AppColors.muted)),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 16),
              const Text('Sensores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_loading && _sensors.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_error != null)
                ErrorRetry(_error!, _loadData)
              else if (_sensors.isEmpty)
                const Text('Esta zona no tiene sensores.')
              else
                Card(
                  child: Column(
                    children: _sensors.map((sensor) {
                      final latest = _latestFor(sensor);
                      final isTemp = sensor.type.toLowerCase().contains('temp');
                      final value = isTemp ? '${formatNumber(latest?.temperature)} °C' : '${formatNumber(latest?.gas)} ppm';
                      return ListTile(
                        leading: const IconTile(Icons.sensors),
                        title: Text('${sensor.code} · ${sensor.type}'),
                        subtitle: Text('Batería ${formatNumber(sensor.battery)} %'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            StatusPill(sensor.status, statusColor(sensor.status)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
