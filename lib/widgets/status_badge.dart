import 'package:flutter/material.dart';

enum StandardStatus { active, draft, withdrawn, amended }

/// Small colored pill used to show a standard's lifecycle status.
/// e.g. Green "Active", Amber "Draft", Red "Withdrawn".
class StatusBadge extends StatelessWidget {
  final StandardStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  _BadgeStyle get _style {
    switch (status) {
      case StandardStatus.active:
        return _BadgeStyle('Active', const Color(0xFF2E7D32), const Color(0xFFE7F5E9));
      case StandardStatus.draft:
        return _BadgeStyle('Draft', const Color(0xFFF9A825), const Color(0xFFFFF6E0));
      case StandardStatus.withdrawn:
        return _BadgeStyle('Withdrawn', const Color(0xFFC62828), const Color(0xFFFCE9E9));
      case StandardStatus.amended:
        return _BadgeStyle('Amended', const Color(0xFF0B4F8A), const Color(0xFFE7F0F9));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  final String label;
  final Color color;
  final Color background;
  _BadgeStyle(this.label, this.color, this.background);
}
