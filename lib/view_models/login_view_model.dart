import 'package:flutter/material.dart';
import '../services/request_service.dart';
import '../services/response_service.dart';
import '../services/user_session_service.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(BuildContext context, String usuario, String password, {bool persist = false}) async {
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
      if (context.mounted) {
        Provider.of<UserSession>(context, listen: false).setUser(user, persist: persist);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      return false;
    }
  }
}
