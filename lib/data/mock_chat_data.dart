/// Keyword-matched canned responses simulating the RAG backend. Citations
/// use the `bis://<standardId>` link convention that CitationLinkBuilder
/// intercepts. Replace with a real API call in Step 6.
class MockChatData {
  MockChatData._();

  static const String welcomeMessage =
      "Namaste! I'm BIS Sahayak — ask me about product certification, "
      "hallmarking, or any Indian Standard, and I'll cite the exact clause.";

  static Future<String> generateResponse(String query) async {
    await Future.delayed(const Duration(milliseconds: 1100)); // simulate latency
    final q = query.toLowerCase();

    if (q.contains('huid') || q.contains('gold') || q.contains('hallmark')) {
      return '''Every piece of gold jewellery sold in India must carry a valid **HUID (Hallmark Unique Identification)** number.

Key requirements as per [IS 16240 Part 1: 2012](bis://IS-16240-1-2012):

- Purity must be marked in karats (14K, 18K, 22K)
- The HUID is a 6-digit alphanumeric code assigned per piece
- Jewellers must be BIS-registered to hallmark and sell

You can verify a HUID on the BIS Care app, or ask me to check one for you.''';
    }

    if (q.contains('led') || q.contains('light') || q.contains('bulb')) {
      return '''LED lighting products fall under **mandatory BIS certification** in India.

Relevant standards:
- [IS 1477 Part 1: 2019](bis://IS-1477-1-2019) — general and safety requirements
- [IS 15885 Part 2/Sec 1: 2011](bis://IS-15885-2-1-2011) — self-ballasted LED lamp safety (draft amendment stage)

Manufacturers must obtain a valid ISI mark license before selling domestically.''';
    }

    if (q.contains('certif') || q.contains('license') || q.contains('msme')) {
      return '''For MSMEs, the BIS certification journey typically involves:

1. Identifying the applicable Indian Standard for your product
2. Factory audit and sample testing at a BIS-recognized lab
3. Grant of license and right to use the **ISI mark**

General certification norms are covered in [IS 302 Part 1: 2008](bis://IS-302-1-2008).

Want me to start a step-by-step Compliance Journey for your product category?''';
    }

    return '''Based on your query, the most relevant standard appears to be [IS 16240 Part 1: 2012](bis://IS-16240-1-2012). Try mentioning a product category (electronics, jewellery, appliances) so I can point you to the exact clause.''';
  }
}
