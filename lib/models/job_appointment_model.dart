class ResponseJobCite{
  int status;
  List<JobAppointmentModel> data;

  ResponseJobCite({
    required this.status,
    required this.data,
  });

  factory ResponseJobCite.fromJson(Map<String, dynamic> json) {
    return ResponseJobCite(
      status: json['status'] is int ? json['status'] : int.tryParse(json['status'].toString()) ?? 0,
      data: JobAppointmentModel.fromJsonList(json['data']),
    );
  }

}

class JobAppointmentModel {
  final int id;
  final int idPreOdt;
  final String descripcion;
  final String status;
  final dynamic usuarioRegistro;
  final dynamic usuarioValida;
  final String fechaValidacion;

  JobAppointmentModel({
    required this.id,
    required this.idPreOdt,
    required this.descripcion,
    required this.status,
    this.usuarioRegistro,
    this.usuarioValida,
    required this.fechaValidacion,
  });

  factory JobAppointmentModel.fromJson(Map<String, dynamic> json) {
    return JobAppointmentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      idPreOdt: json['id_pre_odt'] is int ? json['id_pre_odt'] : int.tryParse(json['id_pre_odt'].toString()) ?? 0,
      descripcion: json['descripcion'] ?? '',
      status: json['status'] ?? '',
      usuarioRegistro: json['usuario_registro'],
      usuarioValida: json['usuario_valida'],
      fechaValidacion: json['fecha_validacion'] ?? '',
    );
  }

  static List<JobAppointmentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => JobAppointmentModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pre_odt': idPreOdt,
      'descripcion': descripcion,
      'status': status,
      'usuario_registro': usuarioRegistro,
      'usuario_valida': usuarioValida,
      'fecha_validacion': fechaValidacion,
    };
  }
}
