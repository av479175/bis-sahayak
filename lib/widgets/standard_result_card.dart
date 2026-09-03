import 'package:flutter/material.dart';
import 'status_badge.dart';

/// Card used for both Home > Recent Activity and Explore > search results.
/// [relevanceScore] and [aiInsight] are optional so Home can reuse this
/// without needing search-specific fields.
class StandardResultCard extends StatelessWidget {
  final String standardId;
  final String title;
  final String code; // e.g. "IS 16240 (Part 1) : 2012"
  final StandardStatus status;
  final double? relevanceScore; // 0.0–1.0, shown only in Explore results
  final String? aiInsight; // short AI-generated blurb, shown only in Explore
  final VoidCallback onTap;

  const StandardResultCard({
    super.key,
    required this.standardId,
    required this.title,
    required this.code,
    required this.status,
    required this.onTap,
    this.relevanceScore,
    this.aiInsight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  StatusBadge(status: status, compact: true),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              if (aiInsight != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          aiInsight!,
                          style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (relevanceScore != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.speed, size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${(relevanceScore! * 100).toStringAsFixed(0)}% match',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
