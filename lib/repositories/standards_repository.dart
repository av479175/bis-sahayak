import '../data/mock_data.dart';
import '../models/standard.dart';
import '../models/standard_detail.dart';
import '../models/compliance_journey.dart';
import '../widgets/status_badge.dart';

/// Simulates the standards REST API. Every method here is where a real
/// `dio.get(...)` call eventually goes — the Riverpod providers that call
/// this class stay untouched when that happens.
class StandardsRepository {
  const StandardsRepository();

  Future<List<Standard>> fetchRecentActivity() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return MockData.recentActivity;
  }

  Future<List<Standard>> searchStandards({
    required String query,
    required StandardFilter filter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var results = MockData.searchResults;

    if (query.isNotEmpty) {
      results = results
          .where((s) =>
              s.title.toLowerCase().contains(query.toLowerCase()) ||
              s.code.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    switch (filter) {
      case StandardFilter.mandatory:
        return results.where((s) => s.isMandatory).toList();
      case StandardFilter.voluntary:
        return results.where((s) => !s.isMandatory && s.status != StandardStatus.draft).toList();
      case StandardFilter.draft:
        return results.where((s) => s.status == StandardStatus.draft).toList();
      case StandardFilter.all:
        return results;
    }
  }

  Future<StandardDetail> fetchStandardDetail(String standardId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockDataDetails.detailFor(standardId);
  }

  Future<ComplianceJourney> fetchComplianceJourney(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockDataDetails.journeyFor(categoryId);
  }
}
