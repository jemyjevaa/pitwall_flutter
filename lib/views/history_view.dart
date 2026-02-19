import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unit_model.dart';
import '../services/UserSession.dart';
import '../view_models/units_view_model.dart';

class HistoryView extends StatefulWidget {
  final UnitModel unit;

  const HistoryView({super.key, required this.unit});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserSession>(context, listen: false).user;
      if (user != null) {
        Provider.of<UnitsViewModel>(context, listen: false).fetchUnitHistory(user, widget.unit.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text("Historial: ${widget.unit.name}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
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
      body: Consumer<UnitsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
          }

          if (viewModel.unitHistory.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: viewModel.unitHistory.length,
            itemBuilder: (context, index) {
              final item = viewModel.unitHistory[index];
              return _buildHistoryCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Sin historial de servicios",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            "No se encontraron registros para esta unidad.",
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    // Mapping keys based on API history patterns
    final String folio = item['folio']?.toString() ?? item['Id_pre_odt']?.toString() ?? 'N/A';
    final String date = item['fecha']?.toString() ?? item['fecha_registro']?.toString() ?? 'N/A';
    final String concepto = item['concepto']?.toString() ?? item['reporte_falla']?.toString() ?? 'Sin descripción';
    final String mecanico = item['mecanico']?.toString() ?? 'Taller Central';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF1A237E).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "FOLIO: $folio",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1A237E)),
                ),
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            concepto,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[100]),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                mecanico,
                style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
