class UserModel {
  final String id;
  final String idUsuario;
  final String nombre;
  final String apPaterno;
  final String apMaterno;
  final String sucursal;
  final String rol;
  final String? assignedUnit; // New field for manual assignment

  UserModel({
    required this.id,
    required this.idUsuario,
    required this.nombre,
    required this.apPaterno,
    required this.apMaterno,
    required this.sucursal,
    required this.rol,
    this.assignedUnit,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      idUsuario: json['id_usuario'] ?? '',
      nombre: json['nombre'] ?? '',
      apPaterno: json['ap_paterno'] ?? '',
      apMaterno: json['ap_materno'] ?? '',
      sucursal: json['sucursal'] ?? '',
      rol: (json['rol'] ?? 'ADMIN').toString().toUpperCase(),
      assignedUnit: json['assigned_unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'nombre': nombre,
      'ap_paterno': apPaterno,
      'ap_materno': apMaterno,
      'sucursal': sucursal,
      'rol': rol,
      'assigned_unit': assignedUnit,
    };
  }

  UserModel copyWith({
    String? nombre,
    String? apPaterno,
    String? apMaterno,
    String? assignedUnit,
  }) {
    return UserModel(
      id: this.id,
      idUsuario: this.idUsuario,
      nombre: nombre ?? this.nombre,
      apPaterno: apPaterno ?? this.apPaterno,
      apMaterno: apMaterno ?? this.apMaterno,
      sucursal: this.sucursal,
      rol: this.rol,
      assignedUnit: assignedUnit ?? this.assignedUnit,
    );
  }

  String get fullName => '$nombre $apPaterno $apMaterno';
}
