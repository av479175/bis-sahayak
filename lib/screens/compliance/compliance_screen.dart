import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compliance_models.dart';
import '../../providers/compliance_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_view.dart';

class ComplianceScreen extends ConsumerWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(complianceProductsProvider);
    final selectedProductId = ref.watch(selectedComplianceProductIdProvider);
    final journeyAsync = ref.watch(complianceJourneyFamilyProvider(selectedProductId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compliance Journey'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Product for CRS / ISI Compliance',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),

              // Product Selector Grid / Row
              productsAsync.when(
                loading: () => const SizedBox(height: 60, child: AsyncLoadingView()),
                error: (err, st) => const Text('Could not load products'),
                data: (products) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: products.map((p) {
                      final isSelected = p.id == selectedProductId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p.name),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(selectedComplianceProductIdProvider.notifier).state = p.id;
                          },
                          selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Selected Journey Timeline
              journeyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: AsyncLoadingView(label: 'Loading compliance timeline...'),
                ),
                error: (err, st) => AsyncErrorView(
                  message: 'Could not load journey details.',
                  onRetry: () => ref.invalidate(complianceJourneyFamilyProvider(selectedProductId)),
                ),
                data: (journey) => _JourneyTimelineCard(journey: journey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyTimelineCard extends StatelessWidget {
  final ComplianceProductJourney journey;

  const _JourneyTimelineCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final pct = (journey.overallProgress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Progress Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            journey.productName,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Text(
                            journey.category,
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$pct% Complete',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: journey.overallProgress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Compliance Timeline & Progress Tracker',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),

        // Timeline Steps
        ...journey.steps.map((step) => _TimelineStepItem(step: step)),
      ],
    );
  }
}

class _TimelineStepItem extends StatelessWidget {
  final ComplianceTimelineStep step;

  const _TimelineStepItem({required this.step});

  @override
  Widget build(BuildContext context) {
    final (statusIcon, statusColor, statusLabel, statusBg) = switch (step.status) {
      StepStatus.completed => (
          Icons.check_circle,
          const Color(0xFF10893E),
          'Completed',
          const Color(0xFFE7F5E9),
        ),
      StepStatus.inProgress => (
          Icons.sync,
          const Color(0xFFD97706),
          'In Progress',
          const Color(0xFFFFF7ED),
        ),
      StepStatus.pending => (
          Icons.hourglass_empty,
          Colors.grey.shade500,
          'Pending',
          Colors.grey.shade100,
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${step.stepNumber}: ${step.title}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    if (step.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          if (step.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              step.description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}
