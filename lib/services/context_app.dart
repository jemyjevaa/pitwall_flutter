import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ResponseServ.dart';

class ContextApp {
  static final ContextApp _instance = ContextApp._internal();
  SharedPreferences? _prefs;

  factory ContextApp() {
    return _instance;
  }

  ContextApp._internal();

  // Inicializar SharedPreferences una sola vez (ejecutar al iniciar la app)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool isDebugMode = true;

  bool get isLogin => _prefs?.getBool('isLogin') ?? false;
  set isLogin(bool value) => _prefs?.setBool('isLogin', value);


  bool get isPersist => _prefs?.getBool('isPersist') ?? false;
  set isPersist(bool value) => _prefs?.setBool('isPersist', value);

  String? get email => _prefs?.getString('email');
  set email(String? value) => _prefs?.setString('email', value ?? '');

  String? get token => _prefs?.getString('token');
  set token(String? value) => _prefs?.setString('token', value ?? '');

  // region persist data user

  int get idUser => _prefs?.getInt('idUser')?? 0;
  set idUser(int? value) => _prefs?.setInt('idUser', value ?? 0);

  String? get nameUser => _prefs?.getString('nameUser');
  set nameUser(String? value) => _prefs?.setString('nameUser', value ?? '');

  String? get rol => _prefs?.getString('rol');
  set rol(String? value) => _prefs?.setString('rol', value ?? '');

  //  only operator
  String? get fullName => _prefs?.getString('fullName');
  set fullName(String? value) => _prefs?.setString('fullName', value ?? '');

  String? get firstLastName => _prefs?.getString('firstLastName');
  set firstLastName(String? value) => _prefs?.setString('firstLastName', value ?? '');

  String? get secondLastName => _prefs?.getString('secondLastName');
  set secondLastName(String? value) => _prefs?.setString('secondLastName', value ?? '');
  // endregion only operator

  // endregion persist data user

  // Limpiar datos
  Future<void> clear() async {
    isLogin = false;
    idUser = null;
    rol = null;
    fullName = null;
    firstLastName = null;
    secondLastName = null;
  }
}
