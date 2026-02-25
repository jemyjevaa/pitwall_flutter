import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/odt_view_model.dart';
import '../models/odt_model.dart';

class OdtView extends StatelessWidget {
  const OdtView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Consulta de ODT',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18, letterSpacing: 0.5),
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
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: ChangeNotifierProvider(
        create: (_) => OdtViewModel(),
        child: Consumer<OdtViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Top Dashboard & Search Section
                Container(
                   decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1A237E).withOpacity(0.05), 
                        blurRadius: 15, 
                        offset: const Offset(0, 8)
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Search / Select ODT
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return viewModel.allFolios.where((String option) {
                            return option.contains(textEditingValue.text.toUpperCase());
                          });
                        },
                        onSelected: (String selection) {
                           viewModel.onFolioSelected(selection);
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                           if (viewModel.selectedFolio != null && controller.text.isEmpty) {
                              controller.text = viewModel.selectedFolio!;
                           }
                           
                           return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                hintText: "Buscar Folio (ej. GL00186536)...",
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1A237E)),
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                suffixIcon: viewModel.isLoading ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator(strokeWidth: 2)) : null,
                              ),
                           );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Dashboard Metrics (Odt Summary)
                      Row(
                        children: [
                          _buildMetricCard("TOTAL", viewModel.summary.total.toString(), const Color(0xFF1A237E)),
                          const SizedBox(width: 12),
                          _buildMetricCard("PENDIENTES", viewModel.summary.unfinished.toString(), Colors.orange[800]!),
                          const SizedBox(width: 12),
                          _buildMetricCard("LISTOS", viewModel.summary.finished.toString(), Colors.green[700]!),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Family Filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip("TODOS", viewModel),
                            const SizedBox(width: 10),
                            _buildFilterChip("GASOLINA", viewModel),
                            const SizedBox(width: 10),
                            _buildFilterChip("SERVICIOS", viewModel),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content List
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.services.isEmpty
                          ? Center(
                              child: Text(
                                viewModel.errorMessage ?? "Seleccione una ODT para ver detalles",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.services.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return ServiceCard(service: viewModel.services[index]);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label, 
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5), 
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 6),
            Text(
              value, 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, OdtViewModel viewModel) {
    final isSelected = viewModel.selectedFamily == label;
    return GestureDetector(
      onTap: () => viewModel.filterByFamily(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A237E) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final OdtService service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A237E);
    // GL00188452 | GL00183018
    print("service => $service");

    String parseTime = service.time.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section: Photo + Activity
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(service.mechanicPhoto), 
                    backgroundColor: Colors.grey[100],
                    onBackgroundImageError: (_, __) {},
                    child: service.mechanicPhoto.isEmpty 
                        ? const Icon(Icons.person_rounded, color: Colors.grey) 
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.mainMechanicName,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1A237E))
                      ),
                      const SizedBox(height: 4),
                      // Row(
                      //   children: [
                      //     Icon(Icons.tag_rounded, size: 12, color: Colors.grey[400]),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       service.maintenanceCode,
                      //       style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    service.folio,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2196F3), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          // Middle Section: Details List (Stacked)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              children: [
                _buildInfoRow("PROGRAMADO:", service.activity),
                const SizedBox(height: 10),
                _buildInfoRow("FAMILIA:", service.family),
                const SizedBox(height: 10),
                _buildInfoRow("DURACIÓN:", parseTime ),
                const SizedBox(height: 10),
                _buildInfoRow("FECHA:", service.leadTime),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          // Bottom: Parts & Status
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.parts.isNotEmpty) ...[
                  Text(
                    "REFACCIONES", 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[500], letterSpacing: 1.0)
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: service.parts.map((p) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!)
                      ),
                      child: Text(p, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ESTADO ACTUAL", 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 0.5)
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: service.isFinished ? Colors.green[600] : Colors.orange[800],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (service.isFinished ? Colors.green : Colors.orange).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        service.statusLabel.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90, 
          child: Text(
            label, 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[500], letterSpacing: 0.5)
          ),
        ),
        Expanded(
          child: Text(
            value, 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)
          ),
        ),
      ],
    );
  }
}
