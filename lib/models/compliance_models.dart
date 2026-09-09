enum StepStatus { completed, inProgress, pending }

class ComplianceProduct {
  final String id;
  final String name;
  final String category;
  final String description;
  final String standardCode;

  const ComplianceProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.standardCode,
  });

  factory ComplianceProduct.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    return ComplianceProduct(
      id: (map['id'] ?? map['_id'] ?? map['product_id'] ?? '').toString(),
      name: (map['name'] ?? map['product_name'] ?? 'Electronic Product').toString(),
      category: (map['category'] ?? 'CRS Scheme').toString(),
      description: (map['description'] ?? '').toString(),
      standardCode: (map['standardCode'] ?? map['standard_code'] ?? 'IS Standard').toString(),
    );
  }
}

class ComplianceTimelineStep {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String description;
  final StepStatus status;
  final String? standardCode;

  const ComplianceTimelineStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.status,
    this.standardCode,
  });

  factory ComplianceTimelineStep.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    final statusStr = (map['status'] ?? '').toString().toLowerCase();

    StepStatus parsedStatus = StepStatus.pending;
    if (statusStr.contains('complete') || statusStr == 'done') {
      parsedStatus = StepStatus.completed;
    } else if (statusStr.contains('progress') || statusStr == 'active') {
      parsedStatus = StepStatus.inProgress;
    }

    return ComplianceTimelineStep(
      stepNumber: (map['stepNumber'] ?? map['step_number'] ?? map['step'] ?? 1) as int,
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      description: (map['description'] ?? map['details'] ?? '').toString(),
      status: parsedStatus,
      standardCode: map['standardCode'] ?? map['standard_code'],
    );
  }
}

class ComplianceProductJourney {
  final String productId;
  final String productName;
  final String category;
  final double overallProgress;
  final List<ComplianceTimelineStep> steps;

  const ComplianceProductJourney({
    required this.productId,
    required this.productName,
    required this.category,
    required this.overallProgress,
    required this.steps,
  });

  factory ComplianceProductJourney.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    final rawSteps = map['steps'];
    final List<ComplianceTimelineStep> stepsList = rawSteps is List
        ? rawSteps.map((e) => ComplianceTimelineStep.fromJson(Map<String, dynamic>.from(e as Map))).toList()
        : [];

    final progressVal = map['overallProgress'] ?? map['progress'];
    double calculatedProgress = 0.0;
    if (progressVal is num) {
      calculatedProgress = progressVal.toDouble();
      if (calculatedProgress > 1.0) calculatedProgress /= 100.0;
    } else if (stepsList.isNotEmpty) {
      final doneCount = stepsList.where((s) => s.status == StepStatus.completed).length;
      calculatedProgress = doneCount / stepsList.length;
    }

    return ComplianceProductJourney(
      productId: (map['productId'] ?? map['product_id'] ?? '').toString(),
      productName: (map['productName'] ?? map['product_name'] ?? 'Product').toString(),
      category: (map['category'] ?? 'Compulsory Registration Scheme').toString(),
      overallProgress: calculatedProgress,
      steps: stepsList,
    );
  }
}
