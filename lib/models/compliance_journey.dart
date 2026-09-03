enum ChecklistStatus { done, inProgress, pending }

class ChecklistItem {
  final String title;
  final String description;
  final ChecklistStatus status;

  const ChecklistItem({
    required this.title,
    required this.description,
    required this.status,
  });
}

class JourneyStep {
  final String title;
  final String subtitle;
  final List<ChecklistItem> items;

  const JourneyStep({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  double get progress {
    if (items.isEmpty) return 0;
    final done = items.where((i) => i.status == ChecklistStatus.done).length;
    return done / items.length;
  }
}

class ComplianceJourney {
  final String categoryId;
  final String categoryName;
  final List<JourneyStep> steps;

  const ComplianceJourney({
    required this.categoryId,
    required this.categoryName,
    required this.steps,
  });

  double get overallProgress {
    if (steps.isEmpty) return 0;
    final total = steps.fold<double>(0, (sum, s) => sum + s.progress);
    return total / steps.length;
  }
}
