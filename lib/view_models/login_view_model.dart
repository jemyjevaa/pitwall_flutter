import 'package:flutter/material.dart';
import '../services/RequestServ.dart';
import '../services/ResponseServ.dart';
import '../services/UserSession.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';

import '../services/context_app.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RequestServ requestSer = RequestServ.instance;


  Future<bool> login(BuildContext context, String usuario, String password, {bool persist = false}) async {
    _isLoading = true;
    notifyListeners();
    bool validateLogin = false;


    try {

      ResponseLogin? responseLogin = await requestSer.handlingRequestParsed(
          urlParam: "/api/appPitwall/login/",
          method: "POST",
          asJson: true,
          params: {
            "usuario": usuario,
            "password": password,
            "accion": "getSession"
          },
          fromJson: (json) {
            print("ResponseLogin.json => $json");
            return ResponseLogin.fromJson(json);
          }
      );

      if( responseLogin == null){
        if( RequestServ.modeDebug ){
          print("[ ERROR ] responseLogin => ${responseLogin}");
        }
        _isLoading = validateLogin;
        return validateLogin;
      }

      if( !responseLogin.success ){
        if( RequestServ.modeDebug ){
          print("[ LoginViewModel ] responseLogin-error => ${responseLogin.error}");
        }
        if( context.mounted ){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${responseLogin.error}'),
                backgroundColor: Colors.red,
              )
          );
        }
        _isLoading = validateLogin;
        return validateLogin;
      }


      ContextApp().isLogin = responseLogin.success;

      _isLoading = validateLogin;

      if( RequestServ.modeDebug ){
        print("[ LoginViewModel ] responseLogin => ${ContextApp().isLogin} | ${responseLogin.user}");
      }
      if( ContextApp().isLogin ){
        final user = responseLogin.user!;

        ContextApp().user = user;
        ContextApp().idUser = int.parse(user.id.toString());
        ContextApp().nameUser = user.idUsuario;
        ContextApp().rol = user.rol;
        if (context.mounted) {
          Provider.of<UserSession>(context, listen: false).setUser(user, persist: persist);
        }
        if( RequestServ.modeDebug ){
          print("[ SAVE CONTEXT ] responseLogin => "
              "user: ${ContextApp().user} | "
              "idUser: ${ContextApp().idUser} | "
              "nameUser: ${ContextApp().nameUser} | "
              "rol: ${ContextApp().rol}");
        }

      }

      notifyListeners();
      return !validateLogin;
    } catch (e) {
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      return validateLogin;
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }
}
