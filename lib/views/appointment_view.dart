import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unit_model.dart';
import '../models/user_model.dart';
import '../services/UserSession.dart';
import '../view_models/units_view_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserSession>(context).user;
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
          BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1A237E).withOpacity(0.1), shape: BoxShape.circle),
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
          final success = await viewModel.createCita(
            user, 
            widget.unit.name, 
            _fallaController.text, 
            _failureTypes, 
            _selectedDate.toString().split(' ')[0]
          );
          if (mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita programada con éxito")));
            Navigator.pop(context);
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
}
