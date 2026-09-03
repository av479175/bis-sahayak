import '../widgets/status_badge.dart';

enum StandardFilter { all, mandatory, voluntary, draft }

class Standard {
  final String id;
  final String code;
  final String title;
  final StandardStatus status;
  final bool isMandatory;
  final double? relevanceScore;
  final String? aiInsight;

  const Standard({
    required this.id,
    required this.code,
    required this.title,
    required this.status,
    this.isMandatory = false,
    this.relevanceScore,
    this.aiInsight,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String date;
  final String category;

  const NewsItem({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
  });
}
