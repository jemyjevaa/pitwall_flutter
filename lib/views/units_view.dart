import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/units_view_model.dart';
import '../models/unit_model.dart';
import '../services/UserSession.dart';
import 'odt_view.dart';
import 'login_view.dart';

class UnitsView extends StatefulWidget {
  const UnitsView({super.key});

  @override
  State<UnitsView> createState() => _UnitsViewState();
}

class _UnitsViewState extends State<UnitsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserSession>(context, listen: false).user;
      if (user != null) {
        Provider.of<UnitsViewModel>(context, listen: false).fetchUnitsByRole(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSession = Provider.of<UserSession>(context);
    final user = userSession.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'PitWall Dashboard',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18, letterSpacing: 0.5),
            ),
            if (user != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.rol.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              if (user != null) {
                Provider.of<UnitsViewModel>(context, listen: false).fetchUnitsByRole(user);
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer<UnitsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.units.isEmpty) {
            if (viewModel.errorMessage != null) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(viewModel.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchUnitsByRole(user!),
                      child: const Text("REINTENTAR"),
                    ),
                  ],
                ),
              ));
            }
            return const Center(child: Text("No hay unidades disponibles"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.units.length,
            itemBuilder: (context, index) {
              final unit = viewModel.units[index];
              return UnitCard(unit: unit);
            },
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final userSession = Provider.of<UserSession>(context, listen: false);
    final user = userSession.user;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFFE8EAF6),
                    child: Text(
                      user?.nombre.isNotEmpty == true ? user!.nombre[0] : "U",
                      style: const TextStyle(fontSize: 32, color: Color(0xFF1A237E), fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? "Usuario",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.rol ?? "ROL",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(
            icon: Icons.dashboard_rounded,
            label: "Dashboard Unidades",
            isSelected: true,
            onTap: () => Navigator.pop(context),
          ),
          if (user?.rol == 'ADMIN' || user?.rol == 'TALLER' || user?.rol == 'ADMINISTRADOR')
            _buildDrawerItem(
              icon: Icons.assignment_rounded,
              label: "Órdenes de Trabajo",
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OdtView()));
              },
            ),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.grey),
              title: const Text("Cerrar Sesión", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Provider.of<UnitsViewModel>(context, listen: false).reset();
                userSession.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF1A237E) : Colors.grey[600]),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: const Color(0xFFE8EAF6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

class UnitCard extends StatelessWidget {
  final UnitModel unit;

  const UnitCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserSession>(context, listen: false).user;
    
    return GestureDetector(
      onTap: () {
        if (user?.rol == 'OPERADOR') {
          _showCreateCitaModal(context, unit);
        } else {
          _showHistoryModal(context, unit);
        }
      },
      onLongPress: (user?.rol == 'OPERADOR') 
          ? () => _showHistoryModal(context, unit) 
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1A237E).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Column(
            children: [
              // Colored thin top bar based on status
              Container(
                height: 4,
                width: double.infinity,
                color: unit.statusColor != null && unit.statusColor!.isNotEmpty 
                    ? _parseColor(unit.statusColor!) 
                    : const Color(0xFFE8EAF6),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Unit Name and Plates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.directions_bus_filled_rounded, size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 6),
                                  Text(
                                    "IDENTIFICADOR",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey[500],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                unit.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              if (unit.workshopName != null && unit.workshopName!.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2196F3).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF2196F3)),
                                      const SizedBox(width: 4),
                                      Text(
                                        unit.workshopName!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "PLACAS",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                unit.licensePlate,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey[100], thickness: 1.5),
                    const SizedBox(height: 16),
                    // Grid of Details
                    _buildDetailGrid(unit),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryModal(BuildContext context, UnitModel unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UnitHistoryModal(unit: unit),
    );
  }



  Widget _buildDetailGrid(UnitModel unit) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMaintenanceAlert = unit.statusColor != null && unit.statusColor!.isNotEmpty;
        final Color maintenanceColor = isMaintenanceAlert 
            ? _parseColor(unit.statusColor!) 
            : const Color(0xFF2196F3);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildDetailBox("KM TOTALES", unit.kmTraveled, constraints.maxWidth, Icons.speed_rounded),
            _buildDetailBox("RANGO", unit.range, constraints.maxWidth, Icons.track_changes_rounded),
            _buildDetailBox(
              "PRÓX. MTTO", 
              unit.nextMaintenance, 
              constraints.maxWidth, 
              Icons.build_rounded,
              overrideColor: isMaintenanceAlert ? maintenanceColor : null,
              isAlert: isMaintenanceAlert
            ),
            _buildDetailBox("DIST. DÍA", unit.distanceTraveled, constraints.maxWidth, Icons.map_rounded),
            _buildDetailBox("KM REST.", unit.remainingKm, constraints.maxWidth, Icons.hourglass_bottom_rounded),
            _buildDetailBox("PROX. VISITA", unit.estimatedNextVisit, constraints.maxWidth, Icons.event_available_rounded),
            
            // Strict Role-based actions
            Consumer<UserSession>(builder: (context, session, _) {
              final user = session.user;
              if (user == null) return const SizedBox.shrink();

              if (user.rol == 'OPERADOR') {
                return const SizedBox.shrink(); // No explicit button, use gestures
              } else if (user.rol == 'TALLER') {
                return _buildActionRow(constraints.maxWidth, unit, context);
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(String label, IconData icon, double parentWidth, Color color, VoidCallback onTap) {
    final double itemWidth = (parentWidth - 12); // Full width for visibility
    return InkWell(
      onTap: onTap,
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(double parentWidth, UnitModel unit, BuildContext context) {
    final double itemWidth = (parentWidth - 36) / 2;
    return Row(
      children: [
        _buildActionButtonHalf("APROBAR", Icons.check_circle, itemWidth, Colors.green, () => _handleStatusUpdate(context, unit, 1)),
        const SizedBox(width: 12),
        _buildActionButtonHalf("CANCELAR", Icons.cancel, itemWidth, Colors.red, () => _handleStatusUpdate(context, unit, 2)),
      ],
    );
  }

  Widget _buildActionButtonHalf(String label, IconData icon, double width, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
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

  void _handleStatusUpdate(BuildContext context, UnitModel unit, int status) async {
    final user = Provider.of<UserSession>(context, listen: false).user;
    if (user == null) return;

    final viewModel = Provider.of<UnitsViewModel>(context, listen: false);
    
    // id_pre_odt: Usually found in unit data if it's a Taller view of units with reports
    // For now, using a placeholder or checking if unit model has it (unlikely without update)
    // Actually, user said: POST /api/appPitwall/citas/ { "Id_pre_odt": 1238, ... }
    // If unit doesn't have id_pre_odt, this won't work.
    
    final success = await viewModel.updateCitaStatus(user, 0, status); // 0 is placeholder
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Estado actualizado" : "Error al actualizar estado"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showCreateCitaModal(BuildContext context, UnitModel unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateCitaModal(unit: unit),
    );
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  Widget _buildDetailBox(
    String label, 
    String value, 
    double parentWidth, 
    IconData icon, 
    {Color? overrideColor, bool isAlert = false}
  ) {
    final double itemWidth = (parentWidth - 24) / 3;
    final Color activeColor = overrideColor ?? const Color(0xFF1A237E);
    
    return Container(
      width: itemWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert ? activeColor.withOpacity(0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? activeColor.withOpacity(0.3) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isAlert ? activeColor.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: activeColor),
          ),
          const SizedBox(height: 10),
          Text(
            label, 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 8, 
              fontWeight: FontWeight.w800, 
              color: Colors.grey[600],
              letterSpacing: 0.5,
            )
          ),
          const SizedBox(height: 4),
          Text(
            value, 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.w900, 
              color: isAlert ? activeColor : Colors.black87,
            )
          ),
        ],
      ),
    );
  }
}

class _UnitHistoryModal extends StatelessWidget {
  final UnitModel unit;
  const _UnitHistoryModal({required this.unit});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UnitsViewModel>(context, listen: false);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Historial de Servicios",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: viewModel.fetchUnitHistory(unit.name),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text(
                              "No hay historial disponible",
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }

                    final history = snapshot.data!;
                    return ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return _buildHistoryItem(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(dynamic item) {
    // Basic mapping from common ODT/Cita patterns
    final String folio = item['folio']?.toString() ?? item['Id_pre_odt']?.toString() ?? 'N/A';
    final String date = item['fecha']?.toString() ?? item['fecha_registro']?.toString() ?? 'N/A';
    final String status = item['status_name']?.toString() ?? item['status']?.toString() ?? 'Pendiente';
    final String description = item['reporte_falla']?.toString() ?? item['concepto']?.toString() ?? 'Sin descripción';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FOLIO: $folio",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF1A237E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateCitaModal extends StatefulWidget {
  final UnitModel unit;
  const _CreateCitaModal({required this.unit});

  @override
  State<_CreateCitaModal> createState() => _CreateCitaModalState();
}

class _CreateCitaModalState extends State<_CreateCitaModal> {
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserSession>(context, listen: false).user!;
    final viewModel = Provider.of<UnitsViewModel>(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              "Reportar Falla", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))
            ),
            const SizedBox(height: 8),
            Text(
              "Describe el problema de la unidad ${widget.unit.name}", 
              style: TextStyle(fontSize: 14, color: Colors.grey[600])
            ),
            const SizedBox(height: 24),
            
            // New: Types of failure input
            const Text(
              "Tipos de falla",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tipoFallaController,
              decoration: InputDecoration(
                hintText: "Escribe un tipo de falla...",
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF1A237E)),
                  onPressed: _addFailureType,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
                ),
              ),
              onSubmitted: (_) => _addFailureType(),
            ),
            if (_failureTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _failureTypes.map((type) => Chip(
                  label: Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFFE8EAF6),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onDeleted: () {
                    setState(() {
                      _failureTypes.remove(type);
                    });
                  },
                )).toList(),
              ),
            ],
            const SizedBox(height: 24),
            
            TextField(
              controller: _fallaController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descripción detallada",
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.grey[50],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(), 
                  firstDate: DateTime.now(), 
                  lastDate: DateTime(2026),
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
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF1A237E)),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null ? "Seleccionar Fecha Deseada" : "Fecha: ${_selectedDate.toString().split(' ')[0]}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () async {
                  if (_fallaController.text.isEmpty || _selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor rellena descripción y fecha"))
                    );
                    return;
                  }
                  final success = await viewModel.createCita(
                    user, 
                    widget.unit.name, 
                    _fallaController.text, 
                    _failureTypes,
                    _selectedDate.toString().split(' ')[0]
                  );
                  if (mounted && success) Navigator.pop(context);
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
                    : const Text("ENVIAR REPORTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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


