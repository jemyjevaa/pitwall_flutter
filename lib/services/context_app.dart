import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

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

  // --- Manejo del Objeto UserModel ---

  UserModel? get user {
    final String? userStr = _prefs?.getString('user_data');
    if (userStr == null || userStr.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(userStr));
    } catch (e) {
      return null;
    }
  }

  set user(UserModel? value) {
    if (value == null) {
      _prefs?.remove('user_data');
    } else {
      _prefs?.setString('user_data', jsonEncode(value.toJson()));
    }
  }

  // --- Estados de sesión ---

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
  String? get fullNameOperator => _prefs?.getString('fullNameOperator');
  set fullNameOperator(String? value) => _prefs?.setString('fullNameOperator', value ?? '');

  String? get firstLastNameOperator => _prefs?.getString('firstLastNameOperator');
  set firstLastNameOperator(String? value) => _prefs?.setString('firstLastNameOperator', value ?? '');

  String? get secondLastNameOperator => _prefs?.getString('secondLastNameOperator');
  set secondLastNameOperator(String? value) => _prefs?.setString('secondLastNameOperator', value ?? '');
  
  String? get unitAssOperator => _prefs?.getString('unitAssOperator');
  set unitAssOperator(String? value) => _prefs?.setString('unitAssOperator', value ?? '');
  // endregion only operator

  // Limpiar datos
  Future<void> clear() async {
    isLogin = false;
    user = null;
    idUser = null;
    rol = null;
    fullNameOperator = null;
    firstLastNameOperator = null;
    secondLastNameOperator = null;
  }
}
