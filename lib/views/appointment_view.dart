import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/UserSession.dart';
import '../services/context_app.dart';
import '../view_models/units_view_model.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';

class AppointmentView extends StatefulWidget {
  final UnitModel unit;

  const AppointmentView({super.key, required this.unit});

  @override
  State<AppointmentView> createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  final _fallaController = TextEditingController();
  final _tipoFallaController = TextEditingController();
  final List<String> _failureTypes = [];
  DateTime? _selectedDate;

  void _addFailureType() {
    final text = _tipoFallaController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        if (!_failureTypes.contains(text)) {
          _failureTypes.add(text);
        }
        _tipoFallaController.clear();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A237E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showComprobante(UserModel user, String fechaPedida) {
    final now = TimeOfDay.now();
    final horaActual = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Cita Agendada!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comprobante de solicitud',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                
                // Comprobante body
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _comprobanteRow(Icons.directions_bus_rounded, 'Unidad', widget.unit.name),
                      const Divider(height: 24),
                      _comprobanteRow(Icons.person_outline_rounded, 'Operador', user.fullName),
                      const Divider(height: 24),
                      _comprobanteRow(Icons.calendar_today_rounded, 'Fecha solicitada', fechaPedida),
                      const Divider(height: 24),
                      _comprobanteRow(Icons.access_time_rounded, 'Hora de registro', horaActual),
                      if (_failureTypes.isNotEmpty) ...[
                        const Divider(height: 24),
                        _comprobanteRow(
                          Icons.warning_amber_rounded,
                          'Tipos de falla',
                          _failureTypes.join(', '),
                        ),
                      ],
                      if (_fallaController.text.isNotEmpty) ...[
                        const Divider(height: 24),
                        _comprobanteRow(
                          Icons.description_rounded,
                          'Descripción',
                          _fallaController.text,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Status note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'En espera de aprobación del supervisor',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);      // close dialog
                      Navigator.pop(context);  // go back to unit card
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('ENTENDIDO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _comprobanteRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1A237E)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[500], letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ContextApp().user;//Provider.of<UserSession>(context).user;
    final viewModel = Provider.of<UnitsViewModel>(context);

    if (user == null) return const Scaffold(body: Center(child: Text("No session")));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Programar Cita", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUnitHeader(),
            const SizedBox(height: 32),
            _buildSectionHeader("TIPOS DE FALLA", Icons.warning_amber_rounded),
            const SizedBox(height: 12),
            _buildFailureTypeInput(),
            if (_failureTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _failureTypes.map((type) => Chip(
                  label: Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  backgroundColor: const Color(0xFFE8EAF6),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onDeleted: () => setState(() => _failureTypes.remove(type)),
                  deleteIconColor: const Color(0xFF1A237E),
                )).toList(),
              ),
            ],
            const SizedBox(height: 32),
            _buildSectionHeader("DETALLES DE LA FALLA", Icons.description_rounded),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _fallaController,
              hint: "Describe el problema detalladamente...",
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("FECHA DESEADA", Icons.calendar_month_rounded),
            const SizedBox(height: 12),
            _buildDatePickerBox(),
            const SizedBox(height: 48),
            _buildSubmitButton(viewModel, user),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1A237E).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.directions_bus_filled_rounded, color: Color(0xFF1A237E)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("UNIDAD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[500], letterSpacing: 1)),
              Text(widget.unit.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1A237E), letterSpacing: 1)),
      ],
    );
  }

  Widget _buildFailureTypeInput() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _tipoFallaController,
            hint: "Eje. Frenos, Luces...",
            onSubmitted: (_) => _addFailureType(),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _addFailureType,
          icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF1A237E), size: 36),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, Function(String)? onSubmitted}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5)),
      ),
    );
  }

  Widget _buildDatePickerBox() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Text(
              _selectedDate == null ? "Seleccionar Fecha" : "Fecha: ${_selectedDate.toString().split(' ')[0]}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _selectedDate == null ? Colors.grey[400] : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(UnitsViewModel viewModel, UserModel user) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () async {
          if (_fallaController.text.isEmpty || _selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor completa los campos requeridos")));
            return;
          }
          final fecha = _selectedDate.toString().split(' ')[0];
          final success = await viewModel.createCita(
            user,
            widget.unit.id,
            _fallaController.text,
            _failureTypes,
            fecha,
          );
          if (mounted && success) {
            _showComprobante(user, fecha);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al programar la cita")));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: viewModel.isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("SOLICITAR CITA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
      ),
    );
  }

  @override
  void dispose() {
    _fallaController.dispose();
    _tipoFallaController.dispose();
    super.dispose();
  }
}
