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
    required this.isFinished,
    required this.statusLabel,
  });

  factory OdtService.fromJson(Map<String, dynamic> json) {
    // Determine mechanic photo
    // API returns: "..\/inspeccion\/rw\/images\/operadores\/18778\/18778.jpg"
    // We want: "https://nuevosistema.busmen.net/inspeccion/rw/images/operadores/18778/18778.jpg"
    final String rawImg = json['imagen_mecanico']?.toString() ?? '';
    String photoUrl = "https://i.pravatar.cc/150"; // Fallback
    
    if (rawImg.isNotEmpty) {
       // Clean path: remove ".." and ensure domain
       String cleanPath = rawImg.replaceAll(r'..', '');
       if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
       photoUrl = "https://nuevosistema.busmen.net$cleanPath";
    }

    return OdtService(
      serviceId: json['servicio_id']?.toString() ?? '',
      folio: json['folioOdt']?.toString() ?? 'N/A',
      mechanicPhoto: photoUrl,
      activity: json['concepto']?.toString() ?? 'Sin Actividad',
      maintenanceCode: json['codigo_mtto']?.toString() ?? 'N/A',
      family: json['familia']?.toString() ?? 'SERVICIOS',
      time: "${json['tiempo']?.toString() ?? '0'} min", 
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
    final fam = json['por_familia'] as Map<String, dynamic>? ?? {};
    final Map<String, int> familyMap = {};
    fam.forEach((k, v) => familyMap[k] = int.parse(v.toString()));

    return OdtSummary(
      total: int.parse(json['total_servicios']?.toString() ?? '0'),
      unfinished: int.parse(json['sinterminar']?.toString() ?? '0'),
      finished: int.parse(json['terminados']?.toString() ?? '0'),
      byFamily: familyMap,
    );
  }
  
  // Empty state
  factory OdtSummary.empty() {
    return OdtSummary(total: 0, unfinished: 0, finished: 0, byFamily: {});
  }
}
