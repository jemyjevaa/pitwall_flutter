class OperatorModel {
  final String id;
  final String name;

  OperatorModel({required this.id, required this.name});

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id']?.toString() ?? '',
      name: json['nombre']?.toString() ?? 'Desconocido',
    );
  }
}
