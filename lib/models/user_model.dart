class UserModel {
  final String id;
  final String idUsuario;
  final String nombre;
  final String apPaterno;
  final String apMaterno;
  final String sucursal;
  final String rol;

  UserModel({
    required this.id,
    required this.idUsuario,
    required this.nombre,
    required this.apPaterno,
    required this.apMaterno,
    required this.sucursal,
    required this.rol,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      idUsuario: json['id_usuario'] ?? '',
      nombre: json['nombre'] ?? '',
      apPaterno: json['ap_paterno'] ?? '',
      apMaterno: json['ap_materno'] ?? '',
      sucursal: json['sucursal'] ?? '',
      rol: (json['rol'] ?? 'ADMIN').toString().toUpperCase(), // Normalizing to uppercase
    );
  }

  String get fullName => '$nombre $apPaterno $apMaterno';
}
