import 'package:flutter/cupertino.dart';

class FormOperatorViewModel extends ChangeNotifier {
  final nombreController = TextEditingController();
  final apPaternoController = TextEditingController();
  final apMaternoController = TextEditingController();
  final unidadController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    apPaternoController.dispose();
    apMaternoController.dispose();
    unidadController.dispose();
    super.dispose();
  }

}