import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/UserSession.dart';
import '../services/context_app.dart';
import '../view_models/units_view_model.dart';
import '../models/unit_model.dart';
import 'appointment_view.dart';
import 'history_view.dart';
import 'odt_view.dart';
import 'login_view.dart';
import 'supervisor_citations_view.dart';
import 'operator_citations_view.dart';

class UnitsView extends StatefulWidget {
  const UnitsView({super.key});

  @override
  State<UnitsView> createState() => _UnitsViewState();
}

class _UnitsViewState extends State<UnitsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    if( ContextApp().isDebugMode ){
      print(" [ ISLOGIN ] USER => ${ContextApp().user} | "
          "| idUser: ${ContextApp().idUser} "
          "| nameUser: ${ContextApp().nameUser} "
          "| rol: ${ContextApp().rol} "
      );
      if( ContextApp().rol == "OPERADOR" ){
        print(" [ ISLOGIN ] OPERATOR => "
            "| fullNameOperator: ${ContextApp().fullNameOperator} "
            "| firstLastNameOperator: ${ContextApp().firstLastNameOperator} "
            "| secondLastNameOperator: ${ContextApp().secondLastNameOperator} "
            "| unitAssOperator: ${ContextApp().unitAssOperator} "
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final session = Provider.of<UserSession>(context, listen: false);
      Provider.of<UnitsViewModel>(context, listen: false).fetchUnitsByRole(ContextApp().user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UnitsViewModel>(context);
    final user = ContextApp().user!;
    final bool isOperator = user.rol.toUpperCase() == 'OPERADOR';


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          "PITWALL",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // Show citation management button for management roles
          if (user != null && (user.rol.toUpperCase() == 'TALLER' ||user.rol.toUpperCase() == 'SUPERVISOR' || user.rol.toUpperCase() == 'ADMIN' || user.rol.toUpperCase() == 'ADMINISTRADOR'))
            IconButton(
              icon: const Icon(Icons.pending_actions_rounded, color: Colors.white),
              tooltip: 'Gestionar Citas',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupervisorCitationsView()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => viewModel.fetchUnitsByRole(user!),
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : Column(
              children: [
                _buildHeader(user, viewModel),
                Expanded(
                  child: viewModel.units.isEmpty
                      ? _buildEmptyState(viewModel.showOnlyCitations)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          itemCount: viewModel.units.length,
                          itemBuilder: (context, index) {
                            return UnitCard(unit: viewModel.units[index]);
                          },
                        ),
                ),
                _buildPaginationControls(viewModel, user),
              ],
            ),
    );
  }

  Widget _buildHeader(dynamic user, UnitsViewModel viewModel) {
    final bool isSupervisor = user != null && 
        (user.rol.toUpperCase() == 'SUPERVISOR' || 
         user.rol.toUpperCase() == 'ADMIN' || 
         user.rol.toUpperCase() == 'ADMINISTRADOR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenido,",
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      ContextApp().rol == "OPERADOR"?
                      ContextApp().fullNameOperator:
                      (user?.fullName ?? "Usuario"),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                  ],
                ),
              ),
              if (isSupervisor)
                _buildFilterToggle(viewModel),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user?.rol.toUpperCase() ?? "ROL",
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(UnitsViewModel viewModel) {
    return InkWell(
      onTap: () => viewModel.toggleShowOnlyCitations(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleItem("TODAS", !viewModel.showOnlyCitations),
            _buildToggleItem("CITAS", viewModel.showOnlyCitations),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF1A237E) : Colors.white.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildPaginationControls(UnitsViewModel viewModel, dynamic user) {
    // No pagination footer for operators (they only see their unit) or if only 1 page
    if (viewModel.totalPages <= 1 || (user?.rol.toUpperCase() == 'OPERADOR')) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page_rounded),
            onPressed: viewModel.page > 1 ? () => viewModel.goToFirstPage(user!) : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: viewModel.page > 1 ? () => viewModel.previousPage(user!) : null,
          ),
          Text(
            "Página ${viewModel.page} de ${viewModel.totalPages}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onPressed: viewModel.page < viewModel.totalPages ? () => viewModel.nextPage(user!) : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page_rounded),
            onPressed: viewModel.page < viewModel.totalPages ? () => viewModel.goToLastPage(user!) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.event_busy_rounded : Icons.directions_bus_filled_rounded, 
            size: 80, 
            color: Colors.grey[300]
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? "No hay citas pendientes" : "No se encontraron unidades", 
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A237E)),
            accountName: Text(user?.fullName ?? "Cargando..."),
            accountEmail: Text(user?.rol ?? "Rol"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF1A237E))),
          ),
          _buildDrawerItem(Icons.dashboard_rounded, "Dashboard", () => Navigator.pop(context)),
          if (user?.rol.toUpperCase() != 'OPERADOR')
            _buildDrawerItem(Icons.assignment_rounded, "Órdenes de Trabajo", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OdtView()));
            }),
          const Spacer(),
          const Divider(),
          _buildDrawerItem(Icons.logout_rounded, "Cerrar Sesión", () {
            Provider.of<UserSession>(context, listen: false).logout();
            ContextApp().clear();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (route) => false);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A237E)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}

class UnitCard extends StatelessWidget {
  final UnitModel unit;
  const UnitCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserSession>(context).user;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          onExpansionChanged: (expanded) {
            // Optional: load fresh data on expansion
          },
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_bus_filled_rounded, color: Color(0xFF1A237E)),
          ),
          title: Text(
            unit.name,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1A237E)),
          ),
          subtitle: Text(
            "Placas: ${unit.licensePlate}",
            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600, fontSize: 12),
          ),
          trailing: _buildStatusIndicator(),
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildDetailGrid(unit),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallActionButton(
                          "HISTORIAL", 
                          Icons.history_rounded, 
                          Colors.grey[700]!, 
                          () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => HistoryView(unit: unit))
                          ).then((_) {
                            if (!context.mounted) return;
                            final user = Provider.of<UserSession>(context, listen: false).user;
                            if (user != null) {
                              Provider.of<UnitsViewModel>(context, listen: false).fetchUnitsByRole(user);
                            }
                          })
                        ),
                      ),
                      const SizedBox(width: 12),
                      ContextApp().rol == 'OPERADOR'? Expanded(
                        child: _buildSmallActionButton(
                          "AGENDAR CITA", 
                          Icons.calendar_today_rounded, 
                          const Color(0xFF1A237E), 
                          () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => AppointmentView(unit: unit))
                          ).then((_) {
                            if (!context.mounted) return;
                            final user = Provider.of<UserSession>(context, listen: false).user;
                            if (user != null) {
                              Provider.of<UnitsViewModel>(context, listen: false).fetchUnitsByRole(user);
                            }
                          })
                        ),
                      ):const SizedBox(width: 12),
                    ],
                  ),
                  // "Mis Citas" row — only for OPERADOR role
                  if ((user?.rol.toUpperCase() ?? '') == 'OPERADOR') ...[  
                    const SizedBox(height: 12),
                    _buildSmallActionButton(
                      "MIS CITAS",
                      Icons.pending_actions_rounded,
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OperatorCitationsView(unit: unit)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final bool isAlert = unit.statusColor != null && unit.statusColor!.isNotEmpty;
    final Color color = isAlert ? _parseColor(unit.statusColor!) : Colors.green;
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)],
      ),
    );
  }

  Widget _buildSmallActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.08),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
      ),
    );
  }

  Widget _buildDetailGrid(UnitModel unit) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMaintenanceAlert = unit.statusColor != null && unit.statusColor!.isNotEmpty;
        final Color maintenanceColor = isMaintenanceAlert ? _parseColor(unit.statusColor!) : const Color(0xFF2196F3);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildDetailBox("KM TOTALES", unit.kmTraveled, constraints.maxWidth, Icons.speed_rounded),
            _buildDetailBox("RANGO", unit.range, constraints.maxWidth, Icons.track_changes_rounded),
            _buildDetailBox("PRÓX. MTTO", unit.nextMaintenance, constraints.maxWidth, Icons.build_rounded, overrideColor: isMaintenanceAlert ? maintenanceColor : null, isAlert: isMaintenanceAlert),
            _buildDetailBox("DIST. DÍA", unit.distanceTraveled, constraints.maxWidth, Icons.map_rounded),
            _buildDetailBox("KM REST.", unit.remainingKm, constraints.maxWidth, Icons.hourglass_bottom_rounded),
            _buildDetailBox("PROX. VISITA", unit.estimatedNextVisit, constraints.maxWidth, Icons.event_available_rounded),
            
            Consumer<UserSession>(builder: (context, session, _) {
              final user = session.user;
              if (user == null) return const SizedBox.shrink();
              final String role = user.rol.toUpperCase();
              
              // Management roles that can Approve/Reject
              final bool canManage = role == 'SUPERVISOR' || role == "ADMIN" || role == "ADMINISTRADOR";


              if (unit.idPreOdt != null && unit.idPreOdt! > 0) {
                if (canManage) {
                  return _buildActionRow(constraints.maxWidth, unit, context);
                } else if (role == 'TALLER') {
                  return _buildPendingLabel("CITACIÓN PENDIENTE DE APROBACIÓN");
                }
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
    );
  }

  Widget _buildActionRow(double parentWidth, UnitModel unit, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPendingLabel("CITACIÓN PENDIENTE"),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.pending_actions_rounded, size: 18),
              label: const Text("GESTIONAR CITA", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupervisorCitationsView()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF1A237E).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF1A237E), letterSpacing: 0.5)),
    );
  }

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF2196F3);
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  Widget _buildDetailBox(String label, String value, double parentWidth, IconData icon, {Color? overrideColor, bool isAlert = false}) {
    final double itemWidth = (parentWidth - 24) / 3;
    final Color activeColor = overrideColor ?? const Color(0xFF1A237E);
    
    return Container(
      width: itemWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert ? activeColor.withOpacity(0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isAlert ? activeColor.withOpacity(0.3) : Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: isAlert ? activeColor.withOpacity(0.1) : Colors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: activeColor),
          ),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isAlert ? activeColor : Colors.black87)),
        ],
      ),
    );
  }
}
