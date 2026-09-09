import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/bis_centre.dart';
import '../../providers/locator_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_view.dart';

class LocatorScreen extends ConsumerStatefulWidget {
  const LocatorScreen({super.key});

  @override
  ConsumerState<LocatorScreen> createState() => _LocatorScreenState();
}

class _LocatorScreenState extends ConsumerState<LocatorScreen> {
  final _searchController = TextEditingController(text: 'Delhi');
  final _mapController = MapController();
  bool _showMap = true;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final text = _searchController.text.trim();
    if (text.isNotEmpty) {
      ref.read(locatorNotifierProvider.notifier).search(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locatorAsync = ref.watch(locatorNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BIS Centre Locator'),
        actions: [
          IconButton(
            tooltip: _showMap ? 'Show List View' : 'Show Map View',
            icon: Icon(_showMap ? Icons.view_list_outlined : Icons.map_outlined),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Location Search Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _onSearch(),
                      decoration: InputDecoration(
                        hintText: 'Enter city or location (e.g. Delhi)...',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _onSearch,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Find'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content Area
            Expanded(
              child: locatorAsync.when(
                loading: () => const AsyncLoadingView(label: 'Locating nearby BIS Centres...'),
                error: (err, st) => AsyncErrorView(
                  message: 'Could not fetch location data. Please try again.',
                  onRetry: _onSearch,
                ),
                data: (locatorState) {
                  final geocode = locatorState.geocodeResult;
                  final centres = locatorState.centres;
                  final centerLatLng = LatLng(geocode?.lat ?? 28.6139, geocode?.lon ?? 77.2090);

                  if (centres.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No BIS Centres found near "${locatorState.query}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (_showMap)
                        SizedBox(
                          height: 220,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: centerLatLng,
                              initialZoom: 11.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.bis_sahayak',
                              ),
                              MarkerLayer(
                                markers: centres.map((c) {
                                  final isSelected = c.id == locatorState.selectedCentreId;
                                  return Marker(
                                    point: LatLng(c.lat, c.lon),
                                    width: 40,
                                    height: 40,
                                    child: GestureDetector(
                                      onTap: () {
                                        ref.read(locatorNotifierProvider.notifier).selectCentre(c.id);
                                      },
                                      child: Icon(
                                        Icons.location_pin,
                                        size: isSelected ? 38 : 28,
                                        color: isSelected ? AppTheme.emeraldGreen : AppTheme.primaryBlue,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: centres.length,
                          itemBuilder: (context, i) {
                            final c = centres[i];
                            final isSelected = c.id == locatorState.selectedCentreId;
                            return _CentreCard(
                              centre: c,
                              isSelected: isSelected,
                              onTap: () {
                                ref.read(locatorNotifierProvider.notifier).selectCentre(c.id);
                                if (_showMap) {
                                  _mapController.move(LatLng(c.lat, c.lon), 13.0);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CentreCard extends StatelessWidget {
  final BisCentre centre;
  final bool isSelected;
  final VoidCallback onTap;

  const _CentreCard({
    required this.centre,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      centre.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      centre.type,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${centre.address}, ${centre.city}, ${centre.state} - ${centre.pincode}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
              ),
              if (centre.services.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: centre.services.map((s) => _ServiceTag(label: s)).toList(),
                ),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (centre.phone.isNotEmpty)
                    InkWell(
                      onTap: () => launchUrl(Uri.parse('tel:${centre.phone}')),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: AppTheme.emeraldGreen),
                          const SizedBox(width: 4),
                          Text(
                            centre.phone,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.emeraldGreen),
                          ),
                        ],
                      ),
                    ),
                  if (centre.email.isNotEmpty)
                    InkWell(
                      onTap: () => launchUrl(Uri.parse('mailto:${centre.email}')),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 4),
                          Text(
                            centre.email,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                          ),
                        ],
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
}

class _ServiceTag extends StatelessWidget {
  final String label;

  const _ServiceTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      ),
    );
  }
}
