import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/standard.dart';
import '../../providers/standards_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/standard_result_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  StandardFilter _activeFilter = StandardFilter.all;
  String _committedQuery = '';
  Timer? _debounce;

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _committedQuery = value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = SearchParams(query: _committedQuery, filter: _activeFilter);
    final resultsAsync = ref.watch(searchResultsProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Standards')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  hintText: 'Search by title, code, or product...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _activeFilter == StandardFilter.all,
                    onTap: () => setState(() => _activeFilter = StandardFilter.all),
                  ),
                  _FilterChip(
                    label: 'Mandatory',
                    selected: _activeFilter == StandardFilter.mandatory,
                    onTap: () => setState(() => _activeFilter = StandardFilter.mandatory),
                  ),
                  _FilterChip(
                    label: 'Voluntary',
                    selected: _activeFilter == StandardFilter.voluntary,
                    onTap: () => setState(() => _activeFilter = StandardFilter.voluntary),
                  ),
                  _FilterChip(
                    label: 'Draft',
                    selected: _activeFilter == StandardFilter.draft,
                    onTap: () => setState(() => _activeFilter = StandardFilter.draft),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: resultsAsync.when(
                loading: () => const AsyncLoadingView(label: 'Searching standards...'),
                error: (err, st) => AsyncErrorView(
                  onRetry: () => ref.invalidate(searchResultsProvider(params)),
                ),
                data: (results) => results.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final s = results[i];
                          return StandardResultCard(
                            standardId: s.id,
                            title: s.title,
                            code: s.code,
                            status: s.status,
                            relevanceScore: s.relevanceScore,
                            aiInsight: s.aiInsight,
                            onTap: () => context.push('/standard-details/${s.id}'),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        labelStyle: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.black87,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No matching standards found',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
