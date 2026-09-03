import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/standard_detail.dart';
import '../../providers/standards_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/expandable_section_card.dart';
import '../../widgets/status_badge.dart';

class StandardDetailsScreen extends ConsumerStatefulWidget {
  final String standardId;
  const StandardDetailsScreen({super.key, required this.standardId});

  @override
  ConsumerState<StandardDetailsScreen> createState() => _StandardDetailsScreenState();
}

class _StandardDetailsScreenState extends ConsumerState<StandardDetailsScreen> {
  bool _simplifiedView = true;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(standardDetailProvider(widget.standardId));

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.maybeWhen(
          data: (d) => Text(d.code, style: const TextStyle(fontSize: 15)),
          orElse: () => const Text('Standard Details', style: TextStyle(fontSize: 15)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), tooltip: 'Save', onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined), tooltip: 'Share', onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const AsyncLoadingView(label: 'Fetching standard details...'),
          error: (err, st) => AsyncErrorView(
            onRetry: () => ref.invalidate(standardDetailProvider(widget.standardId)),
          ),
          data: (detail) => _DetailContent(
            detail: detail,
            simplifiedView: _simplifiedView,
            onToggle: (v) => setState(() => _simplifiedView = v),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final StandardDetail detail;
  final bool simplifiedView;
  final ValueChanged<bool> onToggle;

  const _DetailContent({required this.detail, required this.simplifiedView, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(detail.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3)),
        const SizedBox(height: 8),
        StatusBadge(status: detail.status),
        const SizedBox(height: 16),
        _QuickFactsRow(detail: detail),
        const SizedBox(height: 20),
        _ViewToggle(simplified: simplifiedView, onChanged: onToggle),
        const SizedBox(height: 12),
        ExpandableSectionCard(
          title: 'Scope',
          icon: Icons.description_outlined,
          initiallyExpanded: true,
          content: _SectionText(simplifiedView ? detail.scopeSimplified : detail.scopeOriginal),
        ),
        ExpandableSectionCard(
          title: 'Testing Procedures',
          icon: Icons.science_outlined,
          content: _SectionText(simplifiedView ? detail.testingSimplified : detail.testingOriginal),
        ),
        ExpandableSectionCard(
          title: 'Certification Criteria',
          icon: Icons.workspace_premium_outlined,
          content: _SectionText(simplifiedView ? detail.certificationSimplified : detail.certificationOriginal),
        ),
      ],
    );
  }
}

class _QuickFactsRow extends StatelessWidget {
  final StandardDetail detail;
  const _QuickFactsRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _Fact(icon: Icons.menu_book_outlined, label: 'Pages', value: '${detail.pages}'),
          _VDivider(),
          _Fact(icon: Icons.currency_rupee, label: 'Price', value: detail.price),
          _VDivider(),
          _Fact(icon: Icons.info_outline, label: 'Status', value: detail.status.name),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Fact({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.grey.shade200);
  }
}

class _ViewToggle extends StatelessWidget {
  final bool simplified;
  final ValueChanged<bool> onChanged;
  const _ViewToggle({required this.simplified, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              simplified ? 'AI Simplified View' : 'Original Standard Text',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: simplified,
            onChanged: onChanged,
            activeColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13.5, height: 1.5, color: Colors.black87));
  }
}
