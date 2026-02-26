import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';
import '../services/UserSession.dart';
import '../services/context_app.dart';
import '../view_models/units_view_model.dart';

class SupervisorCitationsView extends StatefulWidget {
  const SupervisorCitationsView({super.key});

  @override
  State<SupervisorCitationsView> createState() => _SupervisorCitationsViewState();
}

class _SupervisorCitationsViewState extends State<SupervisorCitationsView> {
  // Track validation per citation item: citationKey -> {itemIndex -> isValidated}
  // true = SI, false = NO
  final Map<String, Map<int, bool>> _itemValidations = {};
  UserModel? _rolUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ContextApp().user;
      if (user != null) {
        Provider.of<UnitsViewModel>(context, listen: false).fetchAllPendingCitations(user);
      }
      setState(() {
        _rolUser = user;
      });
    });
  }

  String _getCitationKey(AppointmentModel citation) {
    return citation.id;
  }

  List<dynamic> _parseActivities(dynamic activities) {
    if (activities == null) return [];
    if (activities is List) return activities;
    if (activities is String && activities.isNotEmpty) {
      final String trimmed = activities.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {}
      }
      // Fallback: split by comma or semi-colon if it looks like a list of strings
      return trimmed.split(RegExp(r'[,;]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  // ──────────────────────────── ACTIONS ──────────────────────────────────────

  Future<void> _approve(BuildContext ctx, AppointmentModel citation) async {
    final user = ContextApp().user; //Provider.of<UserSession>(ctx, listen: false).user;
    if (user == null) return;
    final idPreOdt = int.tryParse(citation.id);
    if (idPreOdt == null || idPreOdt == 0) return;

    final vm = Provider.of<UnitsViewModel>(ctx, listen: false);
    final ok = await vm.updateCitaStatus(user, idPreOdt, 1);
    if (!ctx.mounted) return;

    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(ok ? '✅ Cita aprobada' : 'Error al aprobar'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
    if (ok) vm.fetchAllPendingCitations(user);
  }

  void _showRejectionModal(BuildContext ctx, AppointmentModel citation) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Motivo de Rechazo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A237E)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Unidad ID: ${citation.unitId}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Escribe la razón del rechazo...',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final motivo = controller.text.trim();
                        if (motivo.isEmpty) {
                          ScaffoldMessenger.of(sheetCtx).showSnackBar(
                            const SnackBar(content: Text('Por favor escribe el motivo')),
                          );
                          return;
                        }
                        Navigator.pop(sheetCtx);
                        await _reject(ctx, citation, motivo);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('RECHAZAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reject(BuildContext ctx, AppointmentModel citation, String motivo) async {
    final user = Provider.of<UserSession>(ctx, listen: false).user;
    if (user == null) return;
    final idPreOdt = int.tryParse(citation.id);
    if (idPreOdt == null || idPreOdt == 0) return;

    final vm = Provider.of<UnitsViewModel>(ctx, listen: false);
    final ok = await vm.updateCitaStatus(user, idPreOdt, 2, motivo: motivo);
    if (!ctx.mounted) return;

    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(ok ? '❌ Cita rechazada' : 'Error al rechazar'),
      backgroundColor: ok ? Colors.orange : Colors.red,
    ));
    if (ok) vm.fetchAllPendingCitations(user);
  }

  // ──────────────────────────── BUILD ────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Citas Pendientes',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
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
              icon: vm.isLoadingCitations
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: vm.isLoadingCitations
                  ? null
                  : () {
                      final user = ContextApp().user;
                      if (user != null) vm.fetchAllPendingCitations(user);
                    },
            ),
          ),
        ],
      ),
      body: Consumer<UnitsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoadingCitations) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1A237E)),
                  SizedBox(height: 16),
                  Text('Buscando citas pendientes...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (vm.pendingCitations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Sin citas pendientes!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay citas pendientes de aprobación.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSummaryBar(vm.pendingCitations.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: vm.pendingCitations.length,
                  itemBuilder: (context, index) {
                    return _buildCitationCard(context, vm.pendingCitations[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryBar(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            '$count citas pendientes de revisión',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationCard(BuildContext ctx, AppointmentModel citation) {
    final List<dynamic> itemList = _parseActivities(citation.activities);
    final String citationKey = _getCitationKey(citation);
    
    // Check if all items are validated (if there are any)
    bool allValidated = true;
    bool anyRejected = false;
    bool allApproved = true;

    if (itemList.isNotEmpty) {
      for (int i = 0; i < itemList.length; i++) {
        final val = _itemValidations[citationKey]?[i];
        if (val == null) {
          allValidated = false;
          allApproved = false;
        } else if (val == false) {
          anyRejected = true;
          allApproved = false;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: anyRejected ? Colors.red.withOpacity(0.08) : Colors.orange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Unit badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_bus_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(citation.unitId,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: anyRejected ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: anyRejected ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        itemList.isEmpty ? 'SIN FALLAS' : 'CON FALLAS',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: anyRejected ? Colors.red : Colors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Folio & date
                Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text('Folio cita: ${citation.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(citation.dateRequest ?? citation.dateCreate,
                        style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  "report: ${citation.report}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  "activities :${citation.activities}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                // Operator
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Operador ID: ${citation.operatorId}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items (actividades) breakdown
          if (itemList.isNotEmpty && (_rolUser?.rol.toUpperCase() == "SUPERVISOR" || _rolUser?.rol.toUpperCase() == "TALLER")) ...[
            Divider(height: 1, color: Colors.grey[100]),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'VALIDAR FALLAS (${itemList.length})',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1A237E), letterSpacing: 1),
                  ),
                  const Spacer(),
                  if (!allValidated)
                    const Text(
                      'Faltan validaciones',
                      style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            ...List.generate(itemList.length, (index) {
              return _buildValidationRow(citationKey, index, itemList[index]);
            }),
            const SizedBox(height: 12),
          ],

          // Rejection warning if any NO is selected
          if (anyRejected)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hay fallas marcadas como NO. La cita debe ser rechazada.',
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: allApproved ? 1.0 : 0.5,
                    child: _buildActionButton(
                      'APROBAR',
                      Icons.check_circle_rounded,
                      Colors.green,
                      !allApproved ? () => _approve(ctx, citation) : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'RECHAZAR',
                    Icons.cancel_rounded,
                    Colors.red,
                    () => _showRejectionModal(ctx, citation),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cleanDescription(dynamic item) {
    if (item == null) return 'Sin descripción';
    
    if (item is Map) {
      final val = item['descripcion'] ?? item['description'] ?? item['name'] ?? item['value'] ?? item['text'];
      if (val != null) return val.toString();
      for (var v in item.values) {
        if (v is String && v.isNotEmpty) return v;
      }
    }
    
    String s = item.toString().trim();
    if (s.startsWith('{') && s.endsWith('}')) s = s.substring(1, s.length - 1);
    
    if (s.toLowerCase().contains('descripcion') && s.contains(':')) {
      final parts = s.split(':');
      if (parts.length > 1) {
        String val = parts.sublist(1).join(':').trim();
        if (val.startsWith('"') && val.endsWith('"')) val = val.substring(1, val.length - 1);
        if (val.startsWith("'") && val.endsWith("'")) val = val.substring(1, val.length - 1);
        return val;
      }
    }
    
    return s;
  }

  Widget _buildValidationRow(String citationKey, int index, dynamic item) {
    final String desc = _cleanDescription(item);
    final bool? currentVal = _itemValidations[citationKey]?[index];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentVal == null 
              ? Colors.transparent 
              : (currentVal ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FALLA REPORTADA',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey[500], letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // SI Button
          _buildToggleButton(
            'SI', 
            Icons.check_rounded, 
            Colors.green, 
            currentVal == true,
            () {
              setState(() {
                if (!_itemValidations.containsKey(citationKey)) {
                  _itemValidations[citationKey] = <int, bool>{};
                }
                _itemValidations[citationKey]![index] = true;
              });
            }
          ),
          const SizedBox(width: 8),
          // NO Button
          _buildToggleButton(
            'NO', 
            Icons.close_rounded, 
            Colors.red, 
            currentVal == false,
            () {
              setState(() {
                if (!_itemValidations.containsKey(citationKey)) {
                  _itemValidations[citationKey] = <int, bool>{};
                }
                _itemValidations[citationKey]![index] = false;
              });
            }
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: isSelected ? Colors.white : Colors.grey[500]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback? onTap) {
    final bool isDisabled = onTap == null;
    return Material(
      color: isDisabled ? Colors.grey[200] : color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDisabled ? Colors.grey[300]! : color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isDisabled ? Colors.grey[400] : color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: isDisabled ? Colors.grey[400] : color)),
            ],
          ),
        ),
      ),
    );
  }
}
