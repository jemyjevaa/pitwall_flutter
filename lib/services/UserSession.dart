import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserSession extends ChangeNotifier {
  UserModel? _user;
  static const String _sessionKey = 'user_session';

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
  }

  void updateUserDetails({
    String? nombre,
    String? apPaterno,
    String? apMaterno,
    String? assignedUnit,
    bool persist = true,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        nombre: nombre,
        apPaterno: apPaterno,
        apMaterno: apMaterno,
        assignedUnit: assignedUnit,
      );
      if (persist) {
        _saveSession(_user!);
      }
      notifyListeners();
    }
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }
}
