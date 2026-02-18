import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  SharedPreferences? _prefs;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isLogin => _prefs?.getBool('isLogin') ?? false;
  set isLogin(bool value) => _prefs?.setBool('isLogin', value);

  // region persist data user

  String  get rolUser => _prefs?.getString('rolUser') ?? "";
  set rolUser(String value) => _prefs?.setString('rolUser', value);



  // Limpiar datos
  Future<void> clear() async {
    isLogin = false;
    rolUser = "";
  }
}
