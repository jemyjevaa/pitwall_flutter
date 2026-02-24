import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/UserSession.dart';
import '../view_models/units_view_model.dart';
import '../models/unit_model.dart';

/// Screen for operators to view their scheduled citations and their status.
class OperatorCitationsView extends StatefulWidget {
  final UnitModel unit;

  const OperatorCitationsView({super.key, required this.unit});

  @override
  State<OperatorCitationsView> createState() => _OperatorCitationsViewState();
}

class _OperatorCitationsViewState extends State<OperatorCitationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserSession>(context, listen: false).user;
      if (user != null) {
        Provider.of<UnitsViewModel>(context, listen: false)
            .fetchUnitHistory(user, widget.unit.id);
      }
    });
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('aprobad') || s.contains('aceptad')) return Colors.green;
    if (s.contains('rechazad') || s.contains('cancelad')) return Colors.red;
    if (s.contains('pendiente')) return Colors.orange;
    return const Color(0xFF1A237E);
  }

  IconData _statusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('aprobad') || s.contains('aceptad')) return Icons.check_circle_rounded;
    if (s.contains('rechazad') || s.contains('cancelad')) return Icons.cancel_rounded;
    if (s.contains('pendiente')) return Icons.pending_actions_rounded;
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          'Mis Citas — ${widget.unit.name}',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
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
        actions: [
          Consumer<UnitsViewModel>(
            builder: (_, vm, __) => IconButton(
              icon: vm.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: vm.isLoading
                  ? null
                  : () {
                      final user =
                          Provider.of<UserSession>(context, listen: false).user;
                      if (user != null) {
                        vm.fetchUnitHistory(user, widget.unit.id);
                      }
                    },
            ),
          ),
        ],
      ),
      body: Consumer<UnitsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            );
          }

          if (vm.unitHistory.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: vm.unitHistory.length,
            itemBuilder: (context, index) {
              return _buildCitationCard(vm.unitHistory[index]);
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
          Icon(Icons.event_busy_rounded, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No tienes citas agendadas',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agenda una cita desde la pantalla principal.',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationCard(dynamic item) {
    final String folio = item['folio']?.toString() ??
        item['Id_pre_odt']?.toString() ??
        item['id_pre_odt']?.toString() ??
        'N/A';
    final String date = item['date_create']?.toString() ??
        item['fecha']?.toString() ??
        item['fecha_registro']?.toString() ??
        'N/A';

    // Resolve description
    String descripcion = 'Sin descripción';
    final concepto = item['concepto']?.toString();
    final reporte = item['reporte_falla']?.toString();
    final act = item['actividades'];
    if (concepto != null && concepto.isNotEmpty) {
      descripcion = concepto;
    } else if (reporte != null && reporte.isNotEmpty) {
      descripcion = reporte;
    } else if (act is List && act.isNotEmpty) {
      descripcion = act.map((a) => a['descripcion']?.toString() ?? a.toString()).join(', ');
    } else if (act is String && act.isNotEmpty) {
      descripcion = act;
    }

    final String status =
        (item['status_name'] ?? item['status'] ?? 'Pendiente').toString();
    final Color color = _statusColor(status);
    final IconData icon = _statusIcon(status);

    // Rejection reason if available
    final String? motivo = item['motivo']?.toString() ??
        item['motivo_rechazo']?.toString() ??
        item['razon']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Folio: $folio',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 12, color: color),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              descripcion,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),

            // Rejection reason (if rejected)
            if (motivo != null && motivo.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 13, color: Colors.red),
                        const SizedBox(width: 6),
                        Text(
                          'Motivo de rechazo',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.red[700],
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      motivo,
                      style: TextStyle(fontSize: 13, color: Colors.red[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
