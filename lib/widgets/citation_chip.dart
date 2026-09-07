import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../theme/app_theme.dart';

/// Tappable inline tag rendered inside chat responses and standard detail
/// pages, e.g. [IS 16240 Part 1: 2012]. Tapping navigates to the standard.
class CitationChip extends StatelessWidget {
  final String label; // e.g. "IS 16240 Part 1: 2012"
  final String standardId; // e.g. "IS-16240-1-2012" — used for routing
  final VoidCallback? onTap;

  const CitationChip({
    super.key,
    required this.label,
    required this.standardId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 11, color: AppTheme.primaryBlue),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a CitationChip as a WidgetSpan so it can sit inline inside a
/// RichText/Text.rich block alongside normal text spans.
WidgetSpan citationChipSpan({
  required String label,
  required String standardId,
  required VoidCallback onTap,
}) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: CitationChip(label: label, standardId: standardId, onTap: onTap),
    ),
  );
}

/// Intercepts markdown `<a>` elements. If the href uses our `bis://` scheme
/// (the convention the RAG backend uses for citations), it renders a tappable
/// CitationChip instead of a normal hyperlink. Any other link falls through
/// to flutter_markdown's default rendering.
class CitationLinkBuilder extends MarkdownElementBuilder {
  final void Function(String standardId) onCitationTap;

  CitationLinkBuilder({required this.onCitationTap});

  static const _scheme = 'bis://';

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final href = element.attributes['href'];
    if (href == null || !href.startsWith(_scheme)) {
      return null; // not a citation link — let flutter_markdown render it normally
    }

    final standardId = href.substring(_scheme.length);
    final label = element.textContent;

    return CitationChip(
      label: label,
      standardId: standardId,
      onTap: () => onCitationTap(standardId),
    );
  }
}
