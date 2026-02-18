import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/units_view_model.dart';
import '../models/unit_model.dart';
import 'odt_view.dart'; // Import OdtView

class UnitsView extends StatelessWidget {
  const UnitsView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light grey background
      appBar: AppBar(
        title: const Text(
          'Lista de Unidades',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF99A25), // Brand color
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: Consumer<UnitsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.units.isEmpty) {
             // Basic error handling display
             if (viewModel.errorMessage != null) {
                return Center(child: Text(viewModel.errorMessage!));
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
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF99A25), Color(0xFFE88A15)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text("A", style: TextStyle(fontSize: 28, color: Color(0xFFF99A25), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text("Administrador", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("admin@busmen.com", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.directions_bus, color: Color(0xFFF99A25)),
            title: const Text("UNIDADES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onTap: () => Navigator.pop(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          ),
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.grey),
            title: const Text("ODT", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            onTap: () {
               Navigator.pop(context); // Close drawer
               Navigator.push(context, MaterialPageRoute(builder: (_) => const OdtView()));
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          ),
           const Spacer(),
           const Divider(),
            ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("CERRAR SESIÓN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
             onTap: () => Navigator.pop(context),
          ),
           const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class UnitCard extends StatelessWidget {
  final UnitModel unit;

  const UnitCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showHistoryModal(context, unit),
      onLongPress: () => _showCreateAppointmentModal(context, unit),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Unit Name and Plates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Unidad",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Placas",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                           letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.licensePlate,
                        style: const TextStyle(
                           fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Divider
              Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
               const SizedBox(height: 24),
              // Grid of Details
              _buildDetailGrid(unit),
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

  void _showCreateAppointmentModal(BuildContext context, UnitModel unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateAppointmentModal(unit: unit),
    );
  }

  Widget _buildDetailGrid(UnitModel unit) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we have a robust status color (e.g. red for alert)
        // If unit.statusColor is present (e.g. #C2240E), we use it for "PRÓX MANTENIMIENTO"
        final bool isMaintenanceAlert = unit.statusColor != null && unit.statusColor!.isNotEmpty;
        final Color maintenanceColor = isMaintenanceAlert 
            ? _parseColor(unit.statusColor!) 
            : const Color(0xFFF99A25); // Default brand color

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildDetailBox("KM RECORRIDOS", unit.kmTraveled, constraints.maxWidth, Icons.speed),
            _buildDetailBox("RANGO", unit.range, constraints.maxWidth, Icons.local_gas_station_rounded),
            
            // Special handling for Maintenance Box
            _buildDetailBox(
              "PRÓX MANTENIMIENTO", 
              unit.nextMaintenance, 
              constraints.maxWidth, 
              Icons.build_circle_outlined,
              overrideColor: isMaintenanceAlert ? maintenanceColor : null,
              isAlert: isMaintenanceAlert
            ),
            
            _buildDetailBox("DISTANCIA RECORRIDA", unit.distanceTraveled, constraints.maxWidth, Icons.map_outlined),
            _buildDetailBox("KM RESTANTES", unit.remainingKm, constraints.maxWidth, Icons.timelapse),
            _buildDetailBox("ESTIMACION PROX. VISITA", unit.estimatedNextVisit, constraints.maxWidth, Icons.calendar_month_outlined),
          ],
        );
      },
    );
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFFF99A25);
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
    const Color defaultBrandColor = Color(0xFFF99A25);
    final Color activeColor = overrideColor ?? defaultBrandColor;
    
    // Alert Style: Border of active color, soft background of active color
    // Normal Style: White background, subtle grey border
    final Color bgColor = isAlert ? activeColor.withOpacity(0.05) : Colors.white;
    final Color borderColor = isAlert ? activeColor : Colors.grey.withOpacity(0.1);
    
    // Text Colors
    final Color textColor = isAlert ? activeColor : Colors.black87;
    final Color labelColor = isAlert ? activeColor.withOpacity(0.8) : Colors.grey;
    
    // Icon Colors
    final Color iconBg = isAlert ? activeColor.withOpacity(0.1) : activeColor.withOpacity(0.1);
    final Color iconColor = activeColor;

    return Container(
      width: itemWidth,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isAlert ? 1.5 : 1.0),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 0.5,
            ),
             maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
             textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
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
    // Mock history data
    final List<Map<String, dynamic>> historyItems = [
      {
        "date": "06/01/2026",
        "status": "En Ruta",
        "activity": "Mantenimiento Preventivo",
        "user": "Juan Perez",
        "branch": "Norte",
        "odt": "ODT-2026-001",
        "registration_date": "01/01/2026"
      },
      {
        "date": "15/12/2025",
        "status": "En Taller",
        "activity": "Cambio de Aceite",
        "user": "Maria Garcia",
        "branch": "Sur",
        "odt": "ODT-2025-892",
        "registration_date": "10/12/2025"
      },
      {
        "date": "20/11/2025",
        "status": "Disponible",
        "activity": "Revisión General",
        "user": "Carlos Lopez",
        "branch": "Central",
        "odt": "ODT-2025-543",
        "registration_date": "15/11/2025"
      }
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F7), // Light grey background
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: historyItems.length + 1, // +1 for Header
                  separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Historial de la Unidad",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final item = historyItems[index - 1];
                    return _HistoryCard(unit: unit, data: item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final UnitModel unit;
  final Map<String, dynamic> data;

  const _HistoryCard({required this.unit, required this.data});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFFF99A25);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of the card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: brandColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      data['date'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: brandColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    data['status'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildRow("Unidad", unit.name),
                _buildRow("Placas", unit.licensePlate),
                _buildRow("Estatus", data['status']),
                _buildRow("Actividad", data['activity']),
                _buildRow("Usuario", data['user']),
                _buildRow("Sucursal", data['branch']),
                _buildRow("ODT", data['odt']),
                _buildRow("Fecha de registro", data['registration_date']),
                _buildRow("Proyección entrada", "12/06/2026"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateAppointmentModal extends StatefulWidget {
  final UnitModel unit;

  const _CreateAppointmentModal({required this.unit});

  @override
  State<_CreateAppointmentModal> createState() => _CreateAppointmentModalState();
}

class _CreateAppointmentModalState extends State<_CreateAppointmentModal> {
  final _serviceController = TextEditingController();
  final List<String> _services = [];
  String? _selectedOperatorId;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitsViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Crear Cita de Mantenimiento",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Unidad: ${widget.unit.name} - ${widget.unit.licensePlate}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 1. Add Service
              Row(
                children: [
                   Expanded(
                    child: TextField(
                      controller: _serviceController,
                      decoration: InputDecoration(
                        labelText: "Agregar Servicio/Actividad",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_serviceController.text.isNotEmpty) {
                        setState(() {
                          _services.add(_serviceController.text);
                          _serviceController.clear();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF99A25),
                      shape: const CircleBorder(), 
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Services List
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _services.map((s) => Chip(
                  label: Text(s),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => _services.remove(s)),
                  backgroundColor: const Color(0xFFFFF3E0),
                  labelStyle: const TextStyle(color: Color(0xFFF99A25)),
                )).toList(),
              ),
              const SizedBox(height: 24),

              // 2. Select Operator
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Seleccionar Operador",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                isExpanded: true, // Fix for overflow
                value: _selectedOperatorId,
                items: viewModel.operators.map((op) {
                  return DropdownMenuItem(
                    value: op.id,
                    child: Text(
                      op.name,
                      overflow: TextOverflow.ellipsis, // Fix for overflow
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedOperatorId = val),
              ),
              const SizedBox(height: 24),

              // 3. Date Picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null 
                          ? "Seleccionar Fecha de Entrada" 
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: TextStyle(
                          color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                          fontSize: 16
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFFF99A25)),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_services.isEmpty || _selectedDate == null || _selectedOperatorId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Por favor complete todos los campos")),
                      );
                      return;
                    }

                    final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                    final success = await viewModel.createAppointment(
                      unitId: widget.unit.id,
                      operatorId: _selectedOperatorId!,
                      date: dateStr,
                      activities: _services.join(','),
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? "Cita creada exitosamente" : "Error al crear cita"),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF99A25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: viewModel.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("GUARDAR CITA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

