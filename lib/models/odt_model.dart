class OdtService {
  final String serviceId;
  final String folio;
  final String mechanicPhoto;
  final String activity; // concepto
  final String maintenanceCode; // codigo_mtto
  final String family; // familia
  final String time; // tiempo
  final List<String> parts; // refacciones
  final String mainMechanicName; // mecanicoName
  final String leadTime;
  final bool isFinished; // termino_servicio != "SIN TERMINAR"
  final String statusLabel; // "SIN TERMINAR" or others

  OdtService({
    required this.serviceId,
    required this.folio,
    required this.mechanicPhoto,
    required this.activity,
    required this.maintenanceCode,
    required this.family,
    required this.time,
    required this.parts,
    required this.mainMechanicName,
    required this.leadTime,
    required this.isFinished,
    required this.statusLabel,
  });

  static String formatMinutes(String? minutes) {
    if (minutes == null || minutes.isEmpty) return "0 min";
    final int totalMinutes = int.tryParse(minutes) ?? 0;
    
    if (totalMinutes < 60) {
      return "$totalMinutes min";
    }
    
    final int hours = totalMinutes ~/ 60;
    final int remainingMinutes = totalMinutes % 60;
    
    if (remainingMinutes == 0) {
      return "$hours ${hours == 1 ? 'hr' : 'hrs'}";
    }

    return "${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')} hrs";
  }

  static String formatDate(String dateStr) {
    if (dateStr == 'N/A' || dateStr.isEmpty) return dateStr;
    try {
      // Input: yyyy-mm-dd
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}"; // Output: dd/mm/yyyy
      }
    } catch (_) {}
    return dateStr;
  }

  factory OdtService.fromJson(Map<String, dynamic> json) {
    // Determine mechanic photo
    final String rawImg = json['imagen_mecanico']?.toString() ?? '';
    String photoUrl = "https://i.pravatar.cc/150"; // Fallback
    
    if (rawImg.isNotEmpty) {
       String cleanPath = rawImg.replaceAll(r'..', '');
       if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
       photoUrl = "https://nuevosistema.busmen.net$cleanPath";
    }

    final String rawTime = json['tiempo']?.toString() ?? '0';
    
    // Clean leadTime: if it's a list or comma-separated string, take the first item
    String rawLeadTime = json["fechas_entrega"]?.toString() ?? 'N/A';
    if (rawLeadTime.contains(',')) {
      rawLeadTime = rawLeadTime.split(',').first.trim();
    }

    return OdtService(
      serviceId: json['servicio_id']?.toString() ?? '',
      folio: json['folioOdt']?.toString() ?? 'N/A',
      mechanicPhoto: photoUrl,
      activity: json['concepto']?.toString() ?? 'Sin Actividad',
      maintenanceCode: json['codigo_mtto']?.toString() ?? 'N/A',
      family: json['familia']?.toString() ?? 'SERVICIOS',
      time: formatMinutes(rawTime),
      leadTime: formatDate(rawLeadTime),
      parts: (json['refacciones']?.toString() ?? '').split(',').where((e) => e.isNotEmpty && e.trim() != '').toList(),
      mainMechanicName: json['mecanicoName']?.toString() ?? 'N/A',
      statusLabel: json['termino_servicio']?.toString() ?? 'SIN TERMINAR',
      isFinished: (json['termino_servicio']?.toString() ?? 'SIN TERMINAR') != 'SIN TERMINAR',
    );
  }
}

class OdtSummary {
  final int total;
  final int unfinished;
  final int finished;
  final Map<String, int> byFamily;

  OdtSummary({
    required this.total,
    required this.unfinished,
    required this.finished,
    required this.byFamily,
  });
  
  factory OdtSummary.fromJson(Map<String, dynamic> json) {
    final dynamic porFamiliaRaw = json['por_familia'];
    final Map<String, int> familyMap = {};
    
    if (porFamiliaRaw is Map) {
      porFamiliaRaw.forEach((k, v) => familyMap[k.toString()] = int.parse(v.toString()));
    }

    return OdtSummary(
      total: int.parse(json['total_servicios']?.toString() ?? '0'),
      unfinished: int.parse(json['sinterminar']?.toString() ?? '0'),
      finished: int.parse(json['terminados']?.toString() ?? '0'),
      byFamily: familyMap,
    );
  }
  
  factory OdtSummary.empty() {
    return OdtSummary(total: 0, unfinished: 0, finished: 0, byFamily: {});
  }
}
