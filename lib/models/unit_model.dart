class UnitModel {
  final String id;
  final String name; // "Unidad"
  final String licensePlate; // "Placas"
  final String kmTraveled; // "KM RECORRIDOS"
  final String range; // "RANGO"
  final String nextMaintenance; // "PRÓX MANTENIMIENTO"
  final String distanceTraveled; // "DISTANCIA RECORRIDA"
  final String remainingKm; // "KM RESTANTES"
  final String estimatedNextVisit; // "ESTIMACION PROX. VISITA"
  final String? statusColor; // Hex string from API, e.g., "#C2240E"
  final String? operadorId;
  final String? workshopName; // "name_geofence" in JSON

  UnitModel({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.kmTraveled,
    required this.range,
    required this.nextMaintenance,
    required this.distanceTraveled,
    required this.remainingKm,
    required this.estimatedNextVisit,
    this.statusColor,
    this.operadorId,
    this.workshopName,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final unidad = json['unidad'] ?? {};
    final maintenance = json['maintenance'] ?? {};

    return UnitModel(
      id: unidad['id']?.toString() ?? '',
      name: unidad['nombre']?.toString() ?? 'N/A',
      licensePlate: unidad['placas']?.toString() ?? 'N/A',
      kmTraveled: _formatNumber(maintenance['km_recorridos']),
      range: _formatNumber(maintenance['rango']),
      nextMaintenance: maintenance['tipoMantenimiento']?.toString() ?? 'N/A',
      distanceTraveled: _formatNumber(maintenance['km_dia']), // Using daily km as requested
      remainingKm: _formatNumber(maintenance['kmRestantes']),
      estimatedNextVisit: maintenance['proxVisita1']?.toString() ?? 'N/A', // Using proxVisita1
      statusColor: maintenance['color']?.toString(),
      operadorId: unidad['operadorId']?.toString(),
      workshopName: json['name_geofence']?.toString(),
    );
  }

  static String _formatNumber(dynamic value) {
    if (value == null) return "0";
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }
}
