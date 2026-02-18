import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/login_view.dart';
import 'views/units_view.dart';
import 'views/operator_data_view.dart';
import 'view_models/login_view_model.dart';
import 'view_models/units_view_model.dart';
import 'services/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userSession = UserSession();
  await userSession.loadSession();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userSession),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => UnitsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PitBus Units',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF03A9F4),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: Consumer<UserSession>(
        builder: (context, userSession, child) {
          if (!userSession.isLoggedIn) {
            return const LoginView();
          }
          
          final user = userSession.user;
          // If operator hasn't filled manual data (assignedUnit is missing), send to collection view
          if (user?.rol == 'OPERADOR' && (user?.assignedUnit == null || user!.assignedUnit!.isEmpty)) {
            return const OperatorDataView();
          }
          
          return const UnitsView();
        },
      ),
    );
  }
}
