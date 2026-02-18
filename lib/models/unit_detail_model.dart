class ResponseUnitModel{
  // final String status;
}

class UnitDetailModel {
  final Unidad unidad;
  final Maintenance maintenance;
  final dynamic ubicacion;
  final String? nameGeofence;

  UnitDetailModel({
    required this.unidad,
    required this.maintenance,
    this.ubicacion,
    this.nameGeofence,
  });

  factory UnitDetailModel.fromJson(Map<String, dynamic> json) {
    return UnitDetailModel(
      unidad: Unidad.fromJson(json['unidad'] ?? {}),
      maintenance: Maintenance.fromJson(json['maintenance'] ?? {}),
      ubicacion: json['ubicacion'],
      nameGeofence: json['name_geofence'],
    );
  }
}

class Unidad {
  final String? id;
  final String? sucursal;
  final String? nombre;
  final String? tipo;
  final String? propiedad;
  final String? marca;
  final String? modelo;
  final String? placas;
  final String? noMotor;
  final String? tipoMotor;
  final String? carroceria;
  final String? empresa;
  final String? noSerie;
  final String? hp;
  final String? capPasajeros;
  final String? aireAc;
  final String? tipoCombustible;
  final String? activa;
  final String? tanque;
  final String? indComb;
  final String? poliza;
  final String? seguro;
  final String? fechaVencimiento;
  final String? tc;
  final String? verificacion;
  final String? ifm;
  final String? permiso;
  final String? adeudoEstatal;
  final String? factura;
  final String? tieneGps;
  final String? usuarioActualizo;
  final String? fechaActualizacion;
  final String? usuarioRegistro;
  final String? fechaRegistro;
  final String? cliente;
  final String? empleadoAuto;
  final String? proveedorGaso;
  final String? observaciones;
  final String? supervisor;
  final String? ubicacionMot;
  final String? tipoPlacas;
  final String? uso;
  final String? pesoUnidad;
  final String? kmArranque;
  final String? corralon;
  final String? tipoChasis;
  final String? idGeovoy;
  final String? capAceite;
  final String? subMarca;
  final String? idCliente;
  final String? ruta;
  final String? supervisorN;
  final String? nombreDepto;
  final String? nombreCliente;
  final String? operadorId;
  final String? operadorN;
  final String? fechaUltimaAsignacion;

  Unidad({
    this.id,
    this.sucursal,
    this.nombre,
    this.tipo,
    this.propiedad,
    this.marca,
    this.modelo,
    this.placas,
    this.noMotor,
    this.tipoMotor,
    this.carroceria,
    this.empresa,
    this.noSerie,
    this.hp,
    this.capPasajeros,
    this.aireAc,
    this.tipoCombustible,
    this.activa,
    this.tanque,
    this.indComb,
    this.poliza,
    this.seguro,
    this.fechaVencimiento,
    this.tc,
    this.verificacion,
    this.ifm,
    this.permiso,
    this.adeudoEstatal,
    this.factura,
    this.tieneGps,
    this.usuarioActualizo,
    this.fechaActualizacion,
    this.usuarioRegistro,
    this.fechaRegistro,
    this.cliente,
    this.empleadoAuto,
    this.proveedorGaso,
    this.observaciones,
    this.supervisor,
    this.ubicacionMot,
    this.tipoPlacas,
    this.uso,
    this.pesoUnidad,
    this.kmArranque,
    this.corralon,
    this.tipoChasis,
    this.idGeovoy,
    this.capAceite,
    this.subMarca,
    this.idCliente,
    this.ruta,
    this.supervisorN,
    this.nombreDepto,
    this.nombreCliente,
    this.operadorId,
    this.operadorN,
    this.fechaUltimaAsignacion,
  });

  factory Unidad.fromJson(Map<String, dynamic> json) {
    return Unidad(
      id: json['id'],
      sucursal: json['sucursal'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      propiedad: json['propiedad'],
      marca: json['marca'],
      modelo: json['modelo'],
      placas: json['placas'],
      noMotor: json['no_motor'],
      tipoMotor: json['tipo_motor'],
      carroceria: json['carroceria'],
      empresa: json['empresa'],
      noSerie: json['no_serie'],
      hp: json['hp'],
      capPasajeros: json['cap_pasajeros'],
      aireAc: json['aire_ac'],
      tipoCombustible: json['tipoCombustible'],
      activa: json['activa'],
      tanque: json['tanque'],
      indComb: json['ind_comb'],
      poliza: json['poliza'],
      seguro: json['seguro'],
      fechaVencimiento: json['fecha_vencimiento'],
      tc: json['T_C'],
      verificacion: json['verificacion'],
      ifm: json['I_F_M'],
      permiso: json['permiso'],
      adeudoEstatal: json['adeudo_estatal'],
      factura: json['factura'],
      tieneGps: json['tiene_gps'],
      usuarioActualizo: json['usuario_actualizo'],
      fechaActualizacion: json['fecha_actualizacion'],
      usuarioRegistro: json['usuario_registro'],
      fechaRegistro: json['fecha_registro'],
      cliente: json['cliente'],
      empleadoAuto: json['empleado_auto'],
      proveedorGaso: json['proveedor_gaso'],
      observaciones: json['observaciones'],
      supervisor: json['supervisor'],
      ubicacionMot: json['ubicacion_mot'],
      tipoPlacas: json['tipo_placas'],
      uso: json['uso'],
      pesoUnidad: json['peso_unidad'],
      kmArranque: json['km_arranque'],
      corralon: json['corralon'],
      tipoChasis: json['tipo_chasis'],
      idGeovoy: json['id_geovoy'],
      capAceite: json['cap_aceite'],
      subMarca: json['sub_marca'],
      idCliente: json['id_cliente'],
      ruta: json['ruta'],
      supervisorN: json['supervisorN'],
      nombreDepto: json['nombreDepto'],
      nombreCliente: json['nombreCliente'],
      operadorId: json['operadorId'],
      operadorN: json['operadorN'],
      fechaUltimaAsignacion: json['fecha_ultima_asignacion'],
    );
  }
}

class Maintenance {
  final double? kmRecorridos;
  final int? rango;
  final String? tipoMantenimiento;
  final double? kmRestantes;
  final double? kmDia;
  final String? proxVisita1;
  final String? proxVisita2;
  final String? urgencia;
  final int? diasFuncionando;
  final String? color;

  Maintenance({
    this.kmRecorridos,
    this.rango,
    this.tipoMantenimiento,
    this.kmRestantes,
    this.kmDia,
    this.proxVisita1,
    this.proxVisita2,
    this.urgencia,
    this.diasFuncionando,
    this.color,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      kmRecorridos: (json['km_recorridos'] as num?)?.toDouble(),
      rango: json['rango'] as int?,
      tipoMantenimiento: json['tipoMantenimiento'],
      kmRestantes: (json['kmRestantes'] as num?)?.toDouble(),
      kmDia: (json['km_dia'] as num?)?.toDouble(),
      proxVisita1: json['proxVisita1'],
      proxVisita2: json['proxVisita2'],
      urgencia: json['urgencia'],
      diasFuncionando: json['dias_funcionando'] as int?,
      color: json['color'],
    );
  }
}
