import 'package:flutter/material.dart';
import 'package:pitbus_app/services/request_service.dart';
import 'package:provider/provider.dart';
import 'views/units_view.dart';
import 'view_models/units_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UnitsViewModel()),
      ],
      child: MaterialApp(
        title: 'PitBus Units',
        debugShowCheckedModeBanner: RequestServ.modeDebug,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            primary: const Color(0xFF2196F3),
            secondary: const Color(0xFF03A9F4),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto', // Default professional font
        ),
        home: const UnitsView(),
      ),
    );
  }
}
