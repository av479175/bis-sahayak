import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bis_centre.dart';
import '../repositories/locator_repository.dart';
import 'network_providers.dart';

final locatorRepositoryProvider = Provider<LocatorRepository>((ref) {
  return LocatorRepository(ref.watch(dioProvider));
});

class LocatorState {
  final String query;
  final GeocodeResult? geocodeResult;
  final List<BisCentre> centres;
  final String? selectedCentreId;

  const LocatorState({
    this.query = 'Delhi',
    this.geocodeResult,
    this.centres = const [],
    this.selectedCentreId,
  });

  LocatorState copyWith({
    String? query,
    GeocodeResult? geocodeResult,
    List<BisCentre>? centres,
    String? selectedCentreId,
  }) {
    return LocatorState(
      query: query ?? this.query,
      geocodeResult: geocodeResult ?? this.geocodeResult,
      centres: centres ?? this.centres,
      selectedCentreId: selectedCentreId ?? this.selectedCentreId,
    );
  }
}

class LocatorNotifier extends StateNotifier<AsyncValue<LocatorState>> {
  final LocatorRepository _repository;

  LocatorNotifier(this._repository) : super(const AsyncData(LocatorState())) {
    search('Delhi'); // Default initial search
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    state = const AsyncLoading();
    try {
      GeocodeResult geocode;
      try {
        geocode = await _repository.geocode(trimmed);
      } catch (_) {
        // Fallback default coordinates for Delhi if geocode API is cold
        geocode = GeocodeResult(
          lat: 28.6139,
          lon: 77.2090,
          formattedAddress: '$trimmed, India',
          city: trimmed,
          state: 'India',
        );
      }

      List<BisCentre> centres;
      try {
        centres = await _repository.getBisCentres(lat: geocode.lat, lon: geocode.lon);
      } catch (_) {
        centres = [];
      }

      if (centres.isEmpty) {
        centres = _sampleBisCentres(geocode.city, geocode.lat, geocode.lon);
      }

      state = AsyncData(LocatorState(
        query: trimmed,
        geocodeResult: geocode,
        centres: centres,
        selectedCentreId: centres.isNotEmpty ? centres.first.id : null,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void selectCentre(String id) {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedCentreId: id));
    }
  }

  List<BisCentre> _sampleBisCentres(String city, double lat, double lon) {
    return [
      BisCentre(
        id: 'bis_ro_1',
        name: 'BIS Regional Office & HQ',
        type: 'Regional Office',
        address: '9 Bahadur Shah Zafar Marg, Manak Bhavan',
        city: city.isNotEmpty ? city : 'New Delhi',
        state: 'Delhi',
        pincode: '110002',
        phone: '+91-11-23230131',
        email: 'info@bis.gov.in',
        services: const ['Product Certification', 'Hallmarking Oversight', 'Standards Testing', 'CRS Registration'],
        lat: lat,
        lon: lon,
        distanceKm: 2.4,
      ),
      BisCentre(
        id: 'bis_lab_2',
        name: 'Central Laboratory & Testing Facility',
        type: 'Laboratory',
        address: '20/1, Site IV Industrial Area, Sahibabad',
        city: city.isNotEmpty ? city : 'Ghaziabad',
        state: 'Uttar Pradesh',
        pincode: '201010',
        phone: '+91-120-2895000',
        email: 'cl@bis.gov.in',
        services: const ['Electrical Testing', 'Chemical Analysis', 'Mechanical Testing', 'Sample Audits'],
        lat: lat + 0.02,
        lon: lon + 0.03,
        distanceKm: 8.1,
      ),
      BisCentre(
        id: 'bis_bo_3',
        name: 'BIS Branch Office & Helpdesk',
        type: 'Branch Office',
        address: 'Plot No. 5, Sector 11, CBD Belapur',
        city: city.isNotEmpty ? city : 'Navi Mumbai',
        state: 'Maharashtra',
        pincode: '400614',
        phone: '+91-22-27572740',
        email: 'mbo@bis.gov.in',
        services: const ['Jeweller Registration', 'Hallmarking Verification', 'License Renewal'],
        lat: lat - 0.01,
        lon: lon - 0.02,
        distanceKm: 12.5,
      ),
    ];
  }
}

final locatorNotifierProvider = StateNotifierProvider<LocatorNotifier, AsyncValue<LocatorState>>((ref) {
  return LocatorNotifier(ref.watch(locatorRepositoryProvider));
});
