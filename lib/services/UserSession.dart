import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserSession extends ChangeNotifier {
  UserModel? _user;
  static const String _sessionKey = 'user_session';
  static const String _unitKey = 'operator_assigned_unit';

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_sessionKey);
    if (sessionData != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(sessionData));
        // Restore unit ID from dedicated persistence if session lacks it
        final savedUnit = prefs.getString(_unitKey);
        if (savedUnit != null && (_user!.assignedUnit == null || _user!.assignedUnit!.isEmpty)) {
          _user = _user!.copyWith(assignedUnit: savedUnit);
        }
        notifyListeners();
      } catch (e) {
        await prefs.remove(_sessionKey);
      }
    } else {
      // Even if no session, we might have a saved unit ID for when they log back in
      final savedUnit = prefs.getString(_unitKey);
      if (savedUnit != null && _user != null) {
         _user = _user!.copyWith(assignedUnit: savedUnit);
         notifyListeners();
      }
    }
  }


  void setUser(UserModel newUser, {bool persist = true}) async {
    _user = newUser;
    if (persist) {
      _saveSession(_user!);
    }
    notifyListeners();
  }

  void updateUserDetails({
    String? nombre,
    String? apPaterno,
    String? apMaterno,
    String? assignedUnit,
    bool persist = true,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        nombre: nombre,
        apPaterno: apPaterno,
        apMaterno: apMaterno,
        assignedUnit: assignedUnit,
      );
      
      if (assignedUnit != null && assignedUnit.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_unitKey, assignedUnit);
      }

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
