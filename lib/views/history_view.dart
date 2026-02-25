import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unit_model.dart';
import '../models/report_model.dart';
import '../services/UserSession.dart';
import '../services/context_app.dart';
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
      final user = ContextApp().user;
      if (user != null) {
        Provider.of<UnitsViewModel>(context, listen: false).fetchUnitHistory(user, widget.unit.id);
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

  /// Resolves the best available description from a history record.
  String _resolveDescription(ReportModel item) {
    if (item.actividades.isNotEmpty) return item.actividades;
    if (item.detalle.isNotEmpty) {
      return item.detalle.map((d) => d.descripcion).join(', ');
    }
    return 'Sin descripción';
  }

  Widget _buildHistoryCard(ReportModel item) {
    final String folio = item.folioOdt != null ? "FOLIO: ${item.folioOdt}":"Cita: ${item.id}";
    final String date = item.dateCreate;
    final String concepto = _resolveDescription(item);
    final String mecanico = item.mecanico ?? item.userCreated;
    final String status = item.status;
    final int? idPreOdt = int.tryParse(item.id);

    final bool isPending = status.toLowerCase().contains('pendiente');

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
                  folio,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1A237E)),
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            date,
            style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
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
          
          // Role-based actions for Supervisors on pending items
          Consumer<UserSession>(builder: (context, session, _) {
            final user = session.user;
            final bool isSupervisor = user != null && (user.rol.toUpperCase() == 'SUPERVISOR' || user.rol.toUpperCase() == 'ADMIN' || user.rol.toUpperCase() == 'ADMINISTRADOR');
            
            if (isSupervisor && isPending && idPreOdt != null && idPreOdt > 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildActionButton("APROBAR", Icons.check_circle_rounded, Colors.green, () => _handleStatusUpdate(context, idPreOdt, 1))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionButton("RECHAZAR", Icons.cancel_rounded, Colors.red, () => _showRejectionModal(context, idPreOdt))),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = const Color(0xFF1A237E);
    if (status.toLowerCase().contains('pendiente')) color = Colors.orange;
    if (status.toLowerCase().contains('aprobado')) color = Colors.green;
    if (status.toLowerCase().contains('rechazado')) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  void _handleStatusUpdate(BuildContext context, int idPreOdt, int status, {String? motivo}) async {
    final user = Provider.of<UserSession>(context, listen: false).user;
    if (user == null) return;

    final viewModel = Provider.of<UnitsViewModel>(context, listen: false);
    final success = await viewModel.updateCitaStatus(user, idPreOdt, status, motivo: motivo);
    if (!context.mounted) return;
    
    if (success) {
      // Use unit.id (numeric) for re-fetching history
      await viewModel.fetchUnitHistory(user, widget.unit.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 1 ? '✅ Cita aprobada' : '❌ Cita rechazada')),
      );
    }
  }

  void _showRejectionModal(BuildContext context, int idPreOdt) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Motivo de Rechazo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe la razón aquí...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (controller.text.trim().isEmpty) return;
                      Navigator.pop(context);
                      _handleStatusUpdate(context, idPreOdt, 2, motivo: controller.text.trim());
                    },
                    child: const Text("RECHAZAR", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
