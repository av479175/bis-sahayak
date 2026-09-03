import '../models/standard.dart';
import '../models/standard_detail.dart';
import '../models/compliance_journey.dart';
import '../widgets/status_badge.dart';

class MockData {
  MockData._();

  static const List<Standard> recentActivity = [
    Standard(
      id: 'IS-16240-1-2012',
      code: 'IS 16240 (Part 1) : 2012',
      title: 'Hallmarking of Gold Jewellery / Artefacts — General Requirements',
      status: StandardStatus.active,
      isMandatory: true,
    ),
    Standard(
      id: 'IS-1477-1-2019',
      code: 'IS 1477 (Part 1) : 2019',
      title: 'LED Lighting Products — General Safety Requirements',
      status: StandardStatus.active,
      isMandatory: true,
    ),
    Standard(
      id: 'IS-302-1-2008',
      code: 'IS 302 (Part 1) : 2008',
      title: 'Safety of Household and Similar Electrical Appliances',
      status: StandardStatus.active,
      isMandatory: false,
    ),
  ];

  static const List<Standard> searchResults = [
    Standard(
      id: 'IS-16240-1-2012',
      code: 'IS 16240 (Part 1) : 2012',
      title: 'Hallmarking of Gold Jewellery / Artefacts — General Requirements',
      status: StandardStatus.active,
      isMandatory: true,
      relevanceScore: 0.96,
      aiInsight: 'Mandatory HUID hallmarking rules for gold purity testing & jeweller registration.',
    ),
    Standard(
      id: 'IS-1477-1-2019',
      code: 'IS 1477 (Part 1) : 2019',
      title: 'LED Lighting Products — General Safety Requirements',
      status: StandardStatus.active,
      isMandatory: true,
      relevanceScore: 0.89,
      aiInsight: 'Covers insulation, temperature rise, and mechanical strength for LED luminaires.',
    ),
    Standard(
      id: 'IS-15885-2-1-2011',
      code: 'IS 15885 (Part 2/Sec 1) : 2011',
      title: 'Lamp Controlgear Part 2 Particular Requirements Section 1',
      status: StandardStatus.draft,
      isMandatory: false,
      relevanceScore: 0.74,
      aiInsight: 'Currently under draft amendment stage for self-ballasted LED lamp drivers.',
    ),
    Standard(
      id: 'IS-302-1-2008',
      code: 'IS 302 (Part 1) : 2008',
      title: 'Safety of Household and Similar Electrical Appliances',
      status: StandardStatus.active,
      isMandatory: false,
      relevanceScore: 0.68,
      aiInsight: 'General safety norms for domestic electric appliances, insulation, and earthing.',
    ),
  ];

  static const List<NewsItem> newsItems = [
    NewsItem(
      id: 'news-1',
      title: 'BIS mandates ISI marking for 12 new electronic items from Q3',
      date: 'Aug 28, 2026',
      category: 'Gazette Notification',
    ),
    NewsItem(
      id: 'news-2',
      title: 'Simplified testing scheme launched for MSME toy manufacturers',
      date: 'Aug 20, 2026',
      category: 'Scheme Update',
    ),
    NewsItem(
      id: 'news-3',
      title: 'Draft standard published for Electric Vehicle charging connectors',
      date: 'Aug 14, 2026',
      category: 'Draft Standard',
    ),
  ];
}

extension MockDataDetails on MockData {
  static StandardDetail detailFor(String standardId) {
    return StandardDetail(
      id: standardId,
      code: 'IS 16240 (Part 1) : 2012',
      title: 'Hallmarking of Gold Jewellery / Artefacts — General Requirements',
      status: StandardStatus.active,
      pages: 18,
      price: '₹450',
      scopeOriginal:
          'This standard prescribes the general requirements for hallmarking of gold '
          'jewellery and artefacts, including fineness, marking symbols, and the '
          'responsibilities of Assaying and Hallmarking Centres (AHCs) registered '
          'under the BIS Hallmarking Scheme.',
      scopeSimplified:
          'This standard sets the rules for stamping gold jewellery with purity '
          'marks. It defines who can test gold purity (AHCs) and what marks must '
          'appear on each piece before it can be sold.',
      testingOriginal:
          'Fineness shall be determined by fire assay method as the referee method. '
          'X-ray fluorescence (XRF) may be used for preliminary screening only, '
          'with confirmatory testing by fire assay in case of dispute. Sampling '
          'shall conform to the procedure specified in Annex B.',
      testingSimplified:
          'Gold purity is checked mainly by "fire assay" (a precise lab test). '
          'X-ray machines can give a quick reading, but if there\'s a dispute, the '
          'fire assay result is final.',
      certificationOriginal:
          'Jewellers intending to sell hallmarked jewellery shall be registered with '
          'BIS under the Hallmarking Scheme. Each AHC shall itself hold valid BIS '
          'recognition and shall issue hallmarking certificates only for jewellery '
          'conforming to the fineness grades specified in Table 1.',
      certificationSimplified:
          'Jewellers must register with BIS to sell hallmarked gold. Only BIS-'
          'recognized testing centres can issue the hallmark certificate, and only '
          'for gold that meets the official purity grades.',
    );
  }

  static ComplianceJourney journeyFor(String categoryId) {
    return ComplianceJourney(
      categoryId: categoryId,
      categoryName: 'LED Lighting Products',
      steps: [
        JourneyStep(
          title: 'Identify Applicable Standard',
          subtitle: 'Confirm which IS standard governs your product',
          items: [
            ChecklistItem(
              title: 'Determine product category',
              description: 'Confirm your product falls under LED lighting, not general electricals.',
              status: ChecklistStatus.done,
            ),
            ChecklistItem(
              title: 'Match to IS 1477 (Part 1) : 2019',
              description: 'Confirmed as the primary applicable standard via Assistant query.',
              status: ChecklistStatus.done,
            ),
          ],
        ),
        JourneyStep(
          title: 'Factory & Sample Testing',
          subtitle: 'Get your product tested at a BIS-recognized lab',
          items: [
            ChecklistItem(
              title: 'Locate a recognized test lab',
              description: 'Choose from BIS-recognized labs in your state.',
              status: ChecklistStatus.done,
            ),
            ChecklistItem(
              title: 'Submit product samples',
              description: 'Typically 3–5 units required depending on product variant.',
              status: ChecklistStatus.inProgress,
            ),
            ChecklistItem(
              title: 'Receive test report',
              description: 'Lab issues a conformity report against IS 1477 clauses.',
              status: ChecklistStatus.pending,
            ),
          ],
        ),
        JourneyStep(
          title: 'License Application',
          subtitle: 'Apply for the right to use the ISI mark',
          items: [
            ChecklistItem(
              title: 'File application with BIS',
              description: 'Submit via the BIS online portal with test report attached.',
              status: ChecklistStatus.pending,
            ),
            ChecklistItem(
              title: 'Factory audit',
              description: 'BIS officer visits to verify production and QC processes.',
              status: ChecklistStatus.pending,
            ),
            ChecklistItem(
              title: 'License grant',
              description: 'Receive your ISI mark license upon successful audit.',
              status: ChecklistStatus.pending,
            ),
          ],
        ),
      ],
    );
  }
}
