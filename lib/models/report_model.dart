class ReportResponse {
  final int status;
  final List<ReportModel> reportes;

  ReportResponse({
    required this.status,
    required this.reportes,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      reportes: (json['reportes'] as List?)
              ?.map((i) => ReportModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class ReportModel {
  final String id;
  final String idUnidad;
  final String idOperador;
  final String? report;
  final String dateRequest;
  final String dateCreate;
  final String horaAsignada;
  final String? urgency;
  final String? img1;
  final String? img2;
  final String? img3;
  final String? taller;
  final String? nave;
  final String? mecanico;
  final String? nota;
  final String actividades;
  final String status;
  final String? activo;
  final String userCreated;
  final String? userCancel;
  final String? folioOdt;
  final String sucursal;
  final String? validadoGps;
  final String? horaGps;
  final String urgencia;
  final String subUrgencia;
  final List<ReportDetailModel> detalle;

  ReportModel({
    required this.id,
    required this.idUnidad,
    required this.idOperador,
    this.report,
    required this.dateRequest,
    required this.dateCreate,
    required this.horaAsignada,
    this.urgency,
    this.img1,
    this.img2,
    this.img3,
    this.taller,
    this.nave,
    this.mecanico,
    this.nota,
    required this.actividades,
    required this.status,
    this.activo,
    required this.userCreated,
    this.userCancel,
    this.folioOdt,
    required this.sucursal,
    this.validadoGps,
    this.horaGps,
    required this.urgencia,
    required this.subUrgencia,
    required this.detalle,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      idUnidad: json['id_unit']?.toString() ?? json['id_unidad']?.toString() ?? '',
      idOperador: json['id_operador']?.toString() ?? '',
      report: json['report']?.toString(),
      dateRequest: json['date_request']?.toString() ?? '',
      dateCreate: json['date_create']?.toString() ?? '',
      horaAsignada: json['hora_asignada']?.toString() ?? '',
      urgency: json['urgency']?.toString(),
      img1: json['img_1']?.toString(),
      img2: json['img_2']?.toString(),
      img3: json['img_3']?.toString(),
      taller: json['Taller']?.toString(),
      nave: json['Nave']?.toString(),
      mecanico: json['mecanico']?.toString(),
      nota: json['nota']?.toString(),
      actividades: json['actividades']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      activo: json['activo']?.toString(),
      userCreated: json['user_created']?.toString() ?? '',
      userCancel: json['user_cancel']?.toString(),
      folioOdt: json['folio_odt']?.toString(),
      sucursal: json['sucursal']?.toString() ?? '',
      validadoGps: json['validadoGPS']?.toString(),
      horaGps: json['horaGPS']?.toString(),
      urgencia: json['urgencia']?.toString() ?? '0',
      subUrgencia: json['sub_urgencia']?.toString() ?? '0',
      detalle: (json['detalle'] as List?)
              ?.map((i) => ReportDetailModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class ReportDetailModel {
  final String descripcion;
  final String status;
  final String usuarioRegistro;
  final String? usuarioValida;
  final String fechaValidacion;

  ReportDetailModel({
    required this.descripcion,
    required this.status,
    required this.usuarioRegistro,
    this.usuarioValida,
    required this.fechaValidacion,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    return ReportDetailModel(
      descripcion: json['descripcion']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      usuarioRegistro: json['usuario_registro']?.toString() ?? '',
      usuarioValida: json['usuario_valida']?.toString(),
      fechaValidacion: json['fecha_validacion']?.toString() ?? '',
    );
  }
}
