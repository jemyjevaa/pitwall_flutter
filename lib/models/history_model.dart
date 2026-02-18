class HistoryModel {
  final String preodtId;
  final String dateCreate;
  final String dateRequest;
  final String actividades;
  final String userCreated;
  final String status;
  final String folioOdt;
  final String sucursal;
  final String id;
  final String idPreOdt;
  final String que;
  final String cuando;
  final String donde;
  final String quien;
  final String porque;
  final String comentario;
  final String fechaCreacion;
  final String idUsuarioCreado;

  HistoryModel({
    required this.preodtId,
    required this.dateCreate,
    required this.dateRequest,
    required this.actividades,
    required this.userCreated,
    required this.status,
    required this.folioOdt,
    required this.sucursal,
    required this.id,
    required this.idPreOdt,
    required this.que,
    required this.cuando,
    required this.donde,
    required this.quien,
    required this.porque,
    required this.comentario,
    required this.fechaCreacion,
    required this.idUsuarioCreado,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      preodtId: json['preodt_id']?.toString() ?? '',
      dateCreate: json['date_create']?.toString() ?? '',
      dateRequest: json['date_request']?.toString() ?? '',
      actividades: json['actividades']?.toString() ?? '',
      userCreated: json['user_created']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      folioOdt: json['folio_odt']?.toString() ?? '',
      sucursal: json['sucursal']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      idPreOdt: json['id_pre_odt']?.toString() ?? '',
      que: json['que']?.toString() ?? '',
      cuando: json['cuando']?.toString() ?? '',
      donde: json['donde']?.toString() ?? '',
      quien: json['quien']?.toString() ?? '',
      porque: json['porque']?.toString() ?? '',
      comentario: json['comentario']?.toString() ?? '',
      fechaCreacion: json['fecha_creacion']?.toString() ?? '',
      idUsuarioCreado: json['id_usuario_creado']?.toString() ?? '',
    );
  }
}
