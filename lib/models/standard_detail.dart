import '../widgets/status_badge.dart';

class StandardDetail {
  final String id;
  final String code;
  final String title;
  final StandardStatus status;
  final int pages;
  final String price;
  final String scopeOriginal;
  final String scopeSimplified;
  final String testingOriginal;
  final String testingSimplified;
  final String certificationOriginal;
  final String certificationSimplified;

  const StandardDetail({
    required this.id,
    required this.code,
    required this.title,
    required this.status,
    required this.pages,
    required this.price,
    required this.scopeOriginal,
    required this.scopeSimplified,
    required this.testingOriginal,
    required this.testingSimplified,
    required this.certificationOriginal,
    required this.certificationSimplified,
  });
}
