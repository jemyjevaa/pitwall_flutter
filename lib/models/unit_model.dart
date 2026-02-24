
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
  final String? workshopName; 
  final int? idPreOdt;

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
    this.idPreOdt,
  });
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final unitData = json['unidad'] ?? {};
    final maintenanceData = json['maintenance'] ?? {};

    return UnitModel(
      id: unitData['id']?.toString() ?? '',
      name: unitData['nombre']?.toString() ?? 'N/A',
      licensePlate: unitData['placas']?.toString() ?? 'N/A',
      kmTraveled: _formatNumber(maintenanceData['km_recorridos']),
      range: _formatNumber(maintenanceData['rango']),
      nextMaintenance: maintenanceData['tipoMantenimiento']?.toString() ?? 'N/A',
      distanceTraveled: _formatNumber(maintenanceData['km_dia']),
      remainingKm: _formatNumber(maintenanceData['kmRestantes']),
      estimatedNextVisit: maintenanceData['proxVisita1']?.toString() ?? 'N/A',
      statusColor: maintenanceData['color']?.toString(),
      operadorId: unitData['operadorId']?.toString(),
      workshopName: json['name_geofence']?.toString(),
      idPreOdt: _parseIdPreOdt(json, unitData, maintenanceData),
    );
  }

  static int? _parseIdPreOdt(Map<String, dynamic> json, Map<String, dynamic> unidad, Map<String, dynamic> maintenance) {
    final rawValue = json['Id_pre_odt'] ?? 
                     unidad['Id_pre_odt'] ?? 
                     maintenance['Id_pre_odt'] ??
                     json['id_pre_odt'] ?? 
                     unidad['id_pre_odt'] ??
                     maintenance['id_pre_odt'] ??
                     json['preodt_id'] ??
                     unidad['preodt_id'] ??
                     maintenance['preodt_id'] ??
                     json['id_cita'] ??
                     unidad['id_cita'] ??
                     maintenance['id_cita'] ??
                     json['cita_id'] ??
                     unidad['cita_id'] ??
                     maintenance['cita_id'] ??
                     json['id_solicitud'] ??
                     unidad['id_solicitud'] ??
                     maintenance['id_solicitud'] ??
                     json['solicitud_id'] ??
                     unidad['solicitud_id'] ??
                     maintenance['solicitud_id'];
    
    if (rawValue == null || rawValue.toString() == '0' || rawValue.toString().isEmpty) return null;
    return int.tryParse(rawValue.toString());
  }

  static String _formatNumber(dynamic value) {
    if (value == null) return "0";
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  UnitModel copyWith({
    String? id,
    String? name,
    String? licensePlate,
    String? kmTraveled,
    String? range,
    String? nextMaintenance,
    String? distanceTraveled,
    String? remainingKm,
    String? estimatedNextVisit,
    String? statusColor,
    String? operadorId,
    String? workshopName,
    int? idPreOdt,
  }) {
    return UnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      licensePlate: licensePlate ?? this.licensePlate,
      kmTraveled: kmTraveled ?? this.kmTraveled,
      range: range ?? this.range,
      nextMaintenance: nextMaintenance ?? this.nextMaintenance,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      remainingKm: remainingKm ?? this.remainingKm,
      estimatedNextVisit: estimatedNextVisit ?? this.estimatedNextVisit,
      statusColor: statusColor ?? this.statusColor,
      operadorId: operadorId ?? this.operadorId,
      workshopName: workshopName ?? this.workshopName,
      idPreOdt: idPreOdt ?? this.idPreOdt,
    );
  }
}
