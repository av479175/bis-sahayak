import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_data.dart';
import '../../providers/standards_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_view.dart';
import '../../widgets/standard_result_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentActivityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _HomeTopAppBar(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Greeting Header
            const Text(
              'Namaste!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'How can I assist you with Indian Standards today?',
              style: TextStyle(
                fontSize: 13.5,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Main Search Bar with submit arrow
            _HomeSearchBar(
              onSubmitted: (query) {
                context.go('/explore');
              },
            ),
            const SizedBox(height: 10),

            // Search Suggestion Chips ("Try: Process for ISI Mark", etc.)
            Row(
              children: [
                Text(
                  'Try:',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SearchSuggestionChip(
                          label: 'Process for ISI Mark',
                          onTap: () => context.go('/explore'),
                        ),
                        const SizedBox(width: 6),
                        _SearchSuggestionChip(
                          label: 'Find standard for Cement',
                          onTap: () => context.go('/explore'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Services Section
            const Text(
              'Quick Services',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            const _QuickServicesGrid(),
            const SizedBox(height: 24),

            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                TextButton(
                  onPressed: () => context.go('/saved'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            recentActivityAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: AsyncLoadingView(),
              ),
              error: (err, st) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: AsyncErrorView(onRetry: () => ref.invalidate(recentActivityProvider)),
              ),
              data: (items) => Column(
                children: items
                    .map((s) => StandardResultCard(
                          standardId: s.id,
                          title: s.title,
                          code: s.code,
                          status: s.status,
                          onTap: () => context.push('/standard-details/${s.id}'),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // News & Amendments Section
            const Text(
              'News & Amendments',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            const _FigmaNewsSection(),
          ],
        ),
      ),
    );
  }
}

class _HomeTopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified, size: 16, color: Colors.white),
          ),
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

class _HomeSearchBar extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  const _HomeSearchBar({required this.onSubmitted});

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ask about ISI Mark, HUID, or search standards...',
                hintStyle: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _submit,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchSuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
}

class _QuickServicesGrid extends StatelessWidget {
  const _QuickServicesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _QuickServiceTile(
          icon: Icons.search,
          title: 'Verify HUID',
          iconBg: const Color(0xFF1E293B),
          iconColor: Colors.white,
          onTap: () => context.go('/assistant'),
        ),
        _QuickServiceTile(
          icon: Icons.check_circle_outline,
          title: 'Check IS Mark',
          iconBg: const Color(0xFF0D9488),
          iconColor: Colors.white,
          onTap: () => context.go('/explore'),
        ),
        _QuickServiceTile(
          icon: Icons.grid_view_outlined,
          title: 'Product Finder',
          iconBg: const Color(0xFF1E293B),
          iconColor: Colors.white,
          onTap: () => context.push('/compliance-journey/led-lighting'),
        ),
        _QuickServiceTile(
          icon: Icons.workspace_premium_outlined,
          title: 'Cert Help',
          iconBg: const Color(0xFF06B6D4),
          iconColor: Colors.white,
          onTap: () => context.go('/assistant'),
        ),
      ],
    );
  }
}

class _QuickServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickServiceTile({
    required this.icon,
    required this.title,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FigmaNewsSection extends StatelessWidget {
  const _FigmaNewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NewsCardItem(
          badgeLabel: 'New Amendment',
          badgeColor: const Color(0xFF10893E),
          badgeBg: const Color(0xFFE7F5E9),
          title: 'Amendment 2 to IS 302 (Part 1) : 2008',
          subtitle: 'Safety of Household Electrical Appliances',
          dateText: 'Effective: 15 Oct 2023',
        ),
        const SizedBox(height: 10),
        _NewsCardItem(
          badgeLabel: 'Announcement',
          badgeColor: AppTheme.primaryBlue,
          badgeBg: const Color(0xFFE7F0F9),
          title: 'Extension of Implementation Date for QCO on Footwear made from Leather',
          subtitle: 'Ministry of Commerce & Industry Notification',
          dateText: 'Effective: 01 Nov 2023',
        ),
      ],
    );
  }
}

class _NewsCardItem extends StatelessWidget {
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
  final String title;
  final String subtitle;
  final String dateText;

  const _NewsCardItem({
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    required this.title,
    required this.subtitle,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 10, color: badgeColor),
                  const SizedBox(width: 4),
                  Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
