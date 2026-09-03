import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/standard.dart';
import '../models/standard_detail.dart';
import '../models/compliance_journey.dart';
import 'repository_providers.dart';

/// Home > Recent Activity
final recentActivityProvider = FutureProvider<List<Standard>>((ref) {
  return ref.watch(standardsRepositoryProvider).fetchRecentActivity();
});

/// Combined query+filter key so `FutureProvider.family` caches correctly —
/// Riverpod re-fetches only when either field actually changes.
class SearchParams {
  final String query;
  final StandardFilter filter;
  const SearchParams({required this.query, required this.filter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchParams && other.query == query && other.filter == filter);

  @override
  int get hashCode => Object.hash(query, filter);
}

/// Explore screen search
final searchResultsProvider =
    FutureProvider.family<List<Standard>, SearchParams>((ref, params) {
  return ref.watch(standardsRepositoryProvider).searchStandards(
        query: params.query,
        filter: params.filter,
      );
});

/// Standard Details screen
final standardDetailProvider =
    FutureProvider.family<StandardDetail, String>((ref, standardId) {
  return ref.watch(standardsRepositoryProvider).fetchStandardDetail(standardId);
});

/// Compliance Journey screen
final complianceJourneyProvider =
    FutureProvider.family<ComplianceJourney, String>((ref, categoryId) {
  return ref.watch(standardsRepositoryProvider).fetchComplianceJourney(categoryId);
});
