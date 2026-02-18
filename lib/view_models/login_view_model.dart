import 'package:flutter/material.dart';
import '../services/RequestServ.dart';
import '../services/ResponseServ.dart';
import '../services/UserSession.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(BuildContext context, String usuario, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "usuario": usuario,
        "password": password,
        "accion": "getSession"
      };

      final response = await RequestServ.post('/api/appPitwall/login/', body);
      final data = ResponseServ.handleResponse(response);
      
      final user = UserModel.fromJson(data);
      Provider.of<UserSession>(context, listen: false).setUser(user);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      return false;
    }
  }
}
