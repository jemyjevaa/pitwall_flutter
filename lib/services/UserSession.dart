<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  SharedPreferences? _prefs;

<<<<<<<< HEAD:lib/services/UserSession.dart
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_sessionKey);
    if (sessionData != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(sessionData));
        notifyListeners();
      } catch (e) {
        await prefs.remove(_sessionKey);
      }
    }
  }

  void setUser(UserModel user, {bool persist = true}) {
    _user = user;
    if (persist) {
      _saveSession(user);
    }
    notifyListeners();
========
  factory UserSession() {
    return _instance;
>>>>>>>> parent of 6464dde (Add new functionalitys for views):lib/services/user_session_service.dart
  }

  UserSession._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isLogin => _prefs?.getBool('isLogin') ?? false;
  set isLogin(bool value) => _prefs?.setBool('isLogin', value);

<<<<<<<< HEAD:lib/services/UserSession.dart
  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
========
  // region persist data user

  String  get rolUser => _prefs?.getString('rolUser') ?? "admin";
  set rolUser(String value) => _prefs?.setString('rolUser', value);



  // Limpiar datos
  Future<void> clear() async {
    isLogin = false;
    rolUser = "";
>>>>>>>> parent of 6464dde (Add new functionalitys for views):lib/services/user_session_service.dart
=======
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserSession extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
>>>>>>> parent of 6464dde (Add new functionalitys for views)
  }
}
