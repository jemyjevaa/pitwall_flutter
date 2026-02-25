import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/UserSession.dart';
import '../services/context_app.dart';
import '../view_models/form_operator_view_model.dart';
import 'units_view.dart';

class OperatorDataView extends StatefulWidget {
  const OperatorDataView({super.key});

  @override
  State<OperatorDataView> createState() => _OperatorDataViewState();
}

class _OperatorDataViewState extends State<OperatorDataView> {

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FormOperatorViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF2196F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 64,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Datos del Operador',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Por favor, ingresa tus datos para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: viewModel.nombreController,
                          label: 'Nombre(s)',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: viewModel.apPaternoController,
                          label: 'Apellido Paterno',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: viewModel.apMaternoController,
                          label: 'Apellido Materno',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: viewModel.unidadController,
                          label: 'Número de Unidad (ej. B1019)',
                          icon: Icons.directions_bus_filled_rounded,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            if (_validate(viewModel)) {
                              final session = Provider.of<UserSession>(context, listen: false);
                              session.updateUserDetails(
                                nombre: viewModel.nombreController.text.trim(),
                                apPaterno: viewModel.apPaternoController.text.trim(),
                                apMaterno: viewModel.apMaternoController.text.trim(),
                                assignedUnit: viewModel.unidadController.text.trim().toUpperCase(),
                              );
                              
                              ContextApp().fullNameOperator = viewModel.nombreController.text;
                              ContextApp().firstLastNameOperator = viewModel.apPaternoController.text;
                              ContextApp().secondLastNameOperator = viewModel.apMaternoController.text;
                              ContextApp().unitAssOperator = viewModel.unidadController.text;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const UnitsView()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validate(FormOperatorViewModel viewModel) {
    if (viewModel.nombreController.text.isEmpty ||
        viewModel.apPaternoController.text.isEmpty ||
        viewModel.apMaternoController.text.isEmpty ||
        viewModel.unidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son requeridos')),
      );
      return false;
    }
    return true;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w500),
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
