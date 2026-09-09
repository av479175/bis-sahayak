import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/standards_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_view.dart';
import '../../widgets/standard_result_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentActivityAsync = ref.watch(recentActivityProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final username = (user != null && user.username.trim().isNotEmpty)
        ? user.username.trim()
        : 'User';

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
            Text(
              'Hi, $username',
              style: const TextStyle(
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

            // Search Suggestion Chips
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
                          label: 'Verify Gold HUID',
                          onTap: () => context.push('/verify?type=huid'),
                        ),
                        const SizedBox(width: 6),
                        _SearchSuggestionChip(
                          label: 'Check BIS License',
                          onTap: () => context.push('/verify?type=license'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Homepage Verification Section
            const _HomeQuickVerifyCard(),
            const SizedBox(height: 20),

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

class _HomeQuickVerifyCard extends ConsumerStatefulWidget {
  const _HomeQuickVerifyCard();

  @override
  ConsumerState<_HomeQuickVerifyCard> createState() => _HomeQuickVerifyCardState();
}

class _HomeQuickVerifyCardState extends ConsumerState<_HomeQuickVerifyCard> {
  final _controller = TextEditingController();
  bool _isHuid = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    if (_isHuid) {
      context.push('/verify?type=huid');
    } else {
      context.push('/verify?type=license');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_isHuid ? Icons.verified_outlined : Icons.badge_outlined, color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isHuid ? 'Quick HUID Verification' : 'Quick BIS License Check',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(() => _isHuid = !_isHuid),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _isHuid ? 'Switch to License' : 'Switch to HUID',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: _isHuid ? 'Enter 6-digit HUID (e.g. A8F2X9)' : 'Enter License No. (e.g. CM/L-1234567)',
                      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _verify,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Verify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
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
          Image.asset('assets/images/app_logo.png', height: 32),
          const SizedBox(width: 10),
          const Text(
            'BIS Sahayak',
            style: TextStyle(
              fontSize: 17,
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
            color: Colors.black.withValues(alpha: 0.02),
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
      childAspectRatio: 2.5,
      children: [
        _QuickServiceTile(
          icon: Icons.verified_outlined,
          title: 'Verify HUID',
          iconBg: const Color(0xFF1E293B),
          iconColor: Colors.white,
          onTap: () => context.push('/verify?type=huid'),
        ),
        _QuickServiceTile(
          icon: Icons.badge_outlined,
          title: 'Verify License',
          iconBg: const Color(0xFF0D9488),
          iconColor: Colors.white,
          onTap: () => context.push('/verify?type=license'),
        ),
        _QuickServiceTile(
          icon: Icons.track_changes_outlined,
          title: 'Compliance',
          iconBg: const Color(0xFF1E293B),
          iconColor: Colors.white,
          onTap: () => context.go('/compliance'),
        ),
        _QuickServiceTile(
          icon: Icons.location_on_outlined,
          title: 'Centre Locator',
          iconBg: const Color(0xFF06B6D4),
          iconColor: Colors.white,
          onTap: () => context.go('/locator'),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
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
      children: const [
        _NewsCardItem(
          badgeLabel: 'New Amendment',
          badgeColor: Color(0xFF10893E),
          badgeBg: Color(0xFFE7F5E9),
          title: 'Amendment 2 to IS 302 (Part 1) : 2008',
          subtitle: 'Safety of Household Electrical Appliances',
          dateText: 'Effective: 15 Oct 2023',
        ),
        SizedBox(height: 10),
        _NewsCardItem(
          badgeLabel: 'Announcement',
          badgeColor: AppTheme.primaryBlue,
          badgeBg: Color(0xFFE7F0F9),
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
