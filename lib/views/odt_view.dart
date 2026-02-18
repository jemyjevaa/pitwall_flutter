import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/odt_view_model.dart';
import '../models/odt_model.dart';

class OdtView extends StatelessWidget {
  const OdtView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Consulta de ODT',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF99A25),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ChangeNotifierProvider(
        create: (_) => OdtViewModel(),
        child: Consumer<OdtViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Top Dashboard & Search Section
                Container(
                   decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(16.0),
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
                           // If a folio is selected, show it.
                           if (viewModel.selectedFolio != null && controller.text.isEmpty) {
                              controller.text = viewModel.selectedFolio!;
                           }
                           
                           return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                hintText: "Buscar Folio (ej. GL00186536)...",
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                suffixIcon: viewModel.isLoading ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator()) : null,
                              ),
                           );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dashboard Metrics (Odt Summary)
                      Row(
                        children: [
                          _buildMetricCard("TOTAL SERVICIOS", viewModel.summary.total.toString(), Colors.blue),
                          const SizedBox(width: 8),
                          _buildMetricCard("SIN TERMINAR", viewModel.summary.unfinished.toString(), Colors.orange),
                          const SizedBox(width: 8),
                          _buildMetricCard("TERMINADOS", viewModel.summary.finished.toString(), Colors.green),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Family Filters
                      Row(
                        children: [
                          _buildFilterChip("TODOS", viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip("GASOLINA", viewModel),
                          const SizedBox(width: 8),
                          _buildFilterChip("SERVICIOS", viewModel),
                        ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, OdtViewModel viewModel) {
    final isSelected = viewModel.selectedFamily == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.filterByFamily(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF99A25) : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final OdtService service;
  const ServiceCard({super.key, required this.service});

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
        children: [
          // Top Section: Photo + Activity
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(service.mechanicPhoto), 
                  backgroundColor: Colors.grey[300],
                  onBackgroundImageError: (_, __) {},
                  child: service.mechanicPhoto.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.activity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(service.maintenanceCode, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: brandColor),
                  ),
                  child: Text(
                    service.folio,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: brandColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          // Middle Section: Details List (Stacked)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                _buildInfoRow("FAMILIA", service.family),
                const SizedBox(height: 8),
                _buildInfoRow("TIEMPO", service.time),
                const SizedBox(height: 8),
                _buildInfoRow("MECÁNICO", service.mainMechanicName),
              ],
            ),
          ),
           Divider(height: 1, color: Colors.grey[200]),
           // Bottom: Parts & Status
           Padding(
             padding: const EdgeInsets.all(12),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 if (service.parts.isNotEmpty) ...[
                   const Text("REFACCIONES:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                   const SizedBox(height: 6),
                   Wrap(
                     spacing: 6,
                     runSpacing: 6,
                     children: service.parts.map((p) => Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: Colors.grey[100],
                         borderRadius: BorderRadius.circular(6),
                         border: Border.all(color: Colors.grey[300]!)
                       ),
                       child: Text(p, style: const TextStyle(fontSize: 11)),
                     )).toList(),
                   ),
                   const SizedBox(height: 12),
                 ],
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text("ESTADO:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: service.isFinished ? Colors.green : Colors.orange,
                         borderRadius: BorderRadius.circular(20),
                       ),
                       child: Text(
                         service.statusLabel.toUpperCase(),
                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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
          child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
      ],
    );
  }
}
