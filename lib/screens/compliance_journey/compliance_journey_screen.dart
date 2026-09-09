import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compliance_journey.dart';
import '../../providers/standards_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_view.dart';

class ComplianceJourneyScreen extends ConsumerWidget {
  final String categoryId;
  const ComplianceJourneyScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(complianceJourneyProvider(categoryId));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _JourneyAppBar(),
      ),
      body: SafeArea(
        child: journeyAsync.when(
          loading: () => const AsyncLoadingView(label: 'Building your compliance roadmap...'),
          error: (err, st) => AsyncErrorView(
            onRetry: () => ref.invalidate(complianceJourneyProvider(categoryId)),
          ),
          data: (journey) => _JourneyFigmaBody(journey: journey),
        ),
      ),
    );
  }
}

class _JourneyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Image.asset('assets/images/app_logo.png', height: 28),
          const SizedBox(width: 8),
          const Text(
            'BIS Sahayak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'English',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              SizedBox(width: 2),
              Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _JourneyFigmaBody extends StatelessWidget {
  final ComplianceJourney journey;
  const _JourneyFigmaBody({required this.journey});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'QUERY RESOLUTION',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 4),
                Icon(Icons.circle, size: 4, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                const Text(
                  'Verified Path',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10893E)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Text(
                    'AI Analysis Confidence ',
                    style: TextStyle(fontSize: 9, color: Color(0xFF10893E)),
                  ),
                  Text(
                    '92%',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10893E)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Journey Title & Subtitle
        const Text(
          'Compliance Journey: Smart Watches',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.25),
        ),
        const SizedBox(height: 6),
        const Text(
          'A detailed, step-by-step regulatory breakdown for manufacturing or importing Smart Watches into India under the Compulsory Registration Scheme (CRS).',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Regulatory Roadmap Header
        const Row(
          children: [
            Icon(Icons.track_changes_outlined, size: 18, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text(
              'Regulatory Roadmap',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Roadmap Steps List
        _RoadmapStepCard(
          stepNumber: 1,
          title: 'Product Classification',
          subtitle: 'Identified as "Smart Watch" under Electronic & Information Technology Goods.',
          badge: 'Category: Wearable Electronics',
          isCompleted: true,
        ),
        const SizedBox(height: 10),
        _RoadmapStepCard(
          stepNumber: 2,
          title: 'Applicable Standard: IS 13252 (Part 1)',
          subtitle: 'Information Technology Equipment - Safety Requirements.',
          showDiagram: true,
          isCompleted: true,
        ),
        const SizedBox(height: 10),
        _RoadmapStepCard(
          stepNumber: 3,
          title: 'Scheme I (CRS) Registration',
          subtitle: 'Compulsory Registration Scheme requires self-declaration of conformity based on testing.',
          isCompleted: false,
        ),
        const SizedBox(height: 10),
        _RoadmapStepCard(
          stepNumber: 4,
          title: 'BIS Recognized Testing',
          subtitle: 'Sample testing must be conducted at a BIS recognized laboratory in India.',
          isCompleted: false,
        ),
        const SizedBox(height: 10),
        _RoadmapStepCard(
          stepNumber: 5,
          title: 'Grant of License (R-Number)',
          subtitle: 'Issuance of unique registration number to be marked on product packaging.',
          isCompleted: false,
        ),
        const SizedBox(height: 24),

        // Key Requirements Section
        const Row(
          children: [
            Icon(Icons.checklist, size: 18, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text(
              'Key Requirements',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            children: const [
              _BulletPoint(text: 'Lithium-ion battery must comply separately with IS 16046.'),
              SizedBox(height: 8),
              _BulletPoint(text: 'Labeling must include standard mark and R-number physically or via e-labeling.'),
              SizedBox(height: 8),
              _BulletPoint(text: 'Foreign manufacturers require an Authorized Indian Representative (AIR).'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Reference Standards
        const Row(
          children: [
            Icon(Icons.menu_book_outlined, size: 18, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text(
              'Reference Standards',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ReferenceStandardTile(
          code: 'IS 13252 (Part 1) : 2010',
          title: 'Information Technology Equipment - Safety',
          actionLabel: 'View Clause 4.1',
        ),
        const SizedBox(height: 8),
        _ReferenceStandardTile(
          code: 'IS 16046 (Part 2) : 2018',
          title: 'Secondary Cells and Batteries (Lithium Systems)',
          actionLabel: 'View Cross-Reference',
        ),
        const SizedBox(height: 28),

        // Download & Connect Buttons
        OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
            side: const BorderSide(color: AppTheme.primaryBlue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.download_outlined, size: 18, color: AppTheme.primaryBlue),
          label: const Text(
            'Download Compliance Checklist',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: const Text(
            'Connect with Expert',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),

        // Footer disclaimer
        Text(
          'AI generated guidance. Official verification required via the official BIS portal prior to application submission.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            height: 1.35,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _RoadmapStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String? badge;
  final bool showDiagram;
  final bool isCompleted;

  const _RoadmapStepCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    this.badge,
    this.showDiagram = false,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: isCompleted ? const Color(0xFF10893E) : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (badge != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
            ),
          ],
          if (showDiagram) ...[
            const SizedBox(height: 12),
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.watch, size: 40, color: AppTheme.primaryBlue),
                      const SizedBox(width: 16),
                      Icon(Icons.cable, size: 24, color: Colors.grey.shade400),
                      const SizedBox(width: 16),
                      const Icon(Icons.speed, size: 36, color: Color(0xFF10893E)),
                    ],
                  ),
                  Positioned(
                    bottom: 6,
                    child: Text(
                      'BIS Safety & Testing Circuit Schema',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppTheme.textPrimary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _ReferenceStandardTile extends StatelessWidget {
  final String code;
  final String title;
  final String actionLabel;

  const _ReferenceStandardTile({
    required this.code,
    required this.title,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            code,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
