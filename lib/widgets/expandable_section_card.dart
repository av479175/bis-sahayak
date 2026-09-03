import 'package:flutter/material.dart';

/// Wraps an ExpansionTile in card chrome. Used for Scope / Testing
/// Procedures / Certification Criteria in Standard Details, and for
/// checklist steps in the Compliance Journey.
class ExpandableSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content; // arbitrary body — text, list, checklist, etc.
  final bool initiallyExpanded;
  final Widget? trailing; // e.g. a completion checkmark for checklist items

  const ExpandableSectionCard({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.article_outlined,
    this.initiallyExpanded = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Removes the default divider ExpansionTile draws
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),
          trailing: trailing ?? const Icon(Icons.expand_more),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [content],
        ),
      ),
    );
  }
}
