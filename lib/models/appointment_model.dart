class ResponseCite{
  final int status;
  final List<AppointmentModel> data;

  ResponseCite({
    required this.status,
    required this.data
  });

  factory ResponseCite.fromJson(Map<String, dynamic> json) {
    return ResponseCite(
      status: json['status'],
      data: List<AppointmentModel>.from(json['data'].map((x) => AppointmentModel.fromJson(x))),
    );
  }

}

class AppointmentModel {
  final String id;
  final String unitId;
  final String operatorId;
  final String report;
  final String? dateRequest;
  final String dateCreate;
  final String assignedTime;
  final String urgency;
  final String? img1;
  final String? img2;
  final String? img3;
  final String workshop;
  final String nave;
  final String mechanic;
  final String? note;
  final String? activities;
  final String status;
  final String active;
  final String userCreated;
  final String? userCancel;
  final String? odtFolio;
  final String branch;
  final String gpsValidated;
  final String gpsTime;
  final String urgencia;
  final String subUrgencia;

  AppointmentModel({
    required this.id,
    required this.unitId,
    required this.operatorId,
    required this.report,
    this.dateRequest,
    required this.dateCreate,
    required this.assignedTime,
    required this.urgency,
    this.img1,
    this.img2,
    this.img3,
    required this.workshop,
    required this.nave,
    required this.mechanic,
    this.note,
    this.activities,
    required this.status,
    required this.active,
    required this.userCreated,
    this.userCancel,
    this.odtFolio,
    required this.branch,
    required this.gpsValidated,
    required this.gpsTime,
    required this.urgencia,
    required this.subUrgencia,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String? _parseNullableString(dynamic value) {
      if (value == null || value.toString() == 'null') {
        return null;
      }
      return value.toString();
    }

    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      unitId: json['id_unidad']?.toString() ?? '',
      operatorId: json['id_operador']?.toString() ?? '',
      report: json['report']?.toString() ?? '',
      dateRequest: _parseNullableString(json['date_request']),
      dateCreate: json['date_create']?.toString() ?? '',
      assignedTime: json['hora_asignada']?.toString() ?? '',
      urgency: json['urgency']?.toString() ?? '',
      img1: _parseNullableString(json['img_1']),
      img2: _parseNullableString(json['img_2']),
      img3: _parseNullableString(json['img_3']),
      workshop: json['Taller']?.toString() ?? '',
      nave: json['Nave']?.toString() ?? '',
      mechanic: json['mecanico']?.toString() ?? '',
      note: _parseNullableString(json['nota']),
      activities: _parseNullableString(json['actividades']),
      status: json['status']?.toString() ?? '',
      active: json['activo']?.toString() ?? '',
      userCreated: json['user_created']?.toString() ?? '',
      userCancel: _parseNullableString(json['user_cancel']),
      odtFolio: _parseNullableString(json['folio_odt']),
      branch: json['sucursal']?.toString() ?? '',
      gpsValidated: json['validadoGPS']?.toString() ?? '',
      gpsTime: json['horaGPS']?.toString() ?? '',
      urgencia: json['urgencia']?.toString() ?? '',
      subUrgencia: json['sub_urgencia']?.toString() ?? '',
    );
  }
}
