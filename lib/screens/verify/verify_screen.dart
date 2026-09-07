import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/verification_models.dart';
import '../../network/api_exception.dart';
import '../../providers/verification_provider.dart';
import '../../theme/app_theme.dart';

enum VerificationType { huid, license }

class VerifyScreen extends ConsumerStatefulWidget {
  final String? initialType;

  const VerifyScreen({super.key, this.initialType});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  late VerificationType _type;
  final _huidController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = (widget.initialType == 'license') ? VerificationType.license : VerificationType.huid;
  }

  @override
  void dispose() {
    _huidController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BIS Verification Center'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Selector
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<VerificationType>(
                  segments: const [
                    ButtonSegment(
                      value: VerificationType.huid,
                      label: Text('Gold HUID'),
                      icon: Icon(Icons.verified_outlined),
                    ),
                    ButtonSegment(
                      value: VerificationType.license,
                      label: Text('BIS License'),
                      icon: Icon(Icons.badge_outlined),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) {
                    setState(() {
                      _type = set.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (_type == VerificationType.huid)
                _HuidVerificationSection(controller: _huidController)
              else
                _LicenseVerificationSection(controller: _licenseController),
            ],
          ),
        ),
      ),
    );
  }
}

class _HuidVerificationSection extends ConsumerWidget {
  final TextEditingController controller;

  const _HuidVerificationSection({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(huidVerificationNotifierProvider);
    final notifier = ref.read(huidVerificationNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify Gold Jewellery HUID',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the 6-digit alphanumeric Hallmark Unique ID stamped on gold jewellery.',
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.3),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'HUID Code',
            hintText: 'e.g. A8F2X9',
            prefixIcon: const Icon(Icons.verified_outlined, color: AppTheme.primaryBlue),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.clear();
                      notifier.reset();
                    },
                  )
                : null,
          ),
          onChanged: (_) => notifier.reset(),
          onSubmitted: (val) => notifier.verify(val),
        ),
        const SizedBox(height: 10),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Sample code: ', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
            ActionChip(
              label: const Text('A8F2X9', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: () {
                controller.text = 'A8F2X9';
                notifier.verify('A8F2X9');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.isLoading ? null : () => notifier.verify(controller.text),
            icon: state.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.search),
            label: Text(state.isLoading ? 'Verifying...' : 'Verify HUID'),
          ),
        ),
        const SizedBox(height: 24),
        state.when(
          data: (result) {
            if (result == null) return const SizedBox.shrink();
            if (!result.isValid) {
              return _ErrorResultCard(
                title: 'HUID Not Found',
                message: result.message.isNotEmpty ? result.message : 'The HUID "${result.huid ?? controller.text}" could not be verified on the official BIS hallmarking database.',
              );
            }
            return _HuidResultCard(result: result);
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Checking official BIS Hallmarking database...'),
              ],
            ),
          ),
          error: (err, st) => _ErrorResultCard(
            title: 'Verification Failed',
            message: err is ApiException ? err.message : err.toString(),
          ),
        ),
      ],
    );
  }
}

class _LicenseVerificationSection extends ConsumerWidget {
  final TextEditingController controller;

  const _LicenseVerificationSection({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(licenseVerificationNotifierProvider);
    final notifier = ref.read(licenseVerificationNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify BIS License / ISI Mark',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the Manufacturer License Number (CM/L) to verify product certification.',
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.3),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'License Number (CM/L)',
            hintText: 'e.g. CM/L-1234567',
            prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryBlue),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.clear();
                      notifier.reset();
                    },
                  )
                : null,
          ),
          onChanged: (_) => notifier.reset(),
          onSubmitted: (val) => notifier.verify(val),
        ),
        const SizedBox(height: 10),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Sample license: ', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
            ActionChip(
              label: const Text('CM/L-1234567', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: () {
                controller.text = 'CM/L-1234567';
                notifier.verify('CM/L-1234567');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.isLoading ? null : () => notifier.verify(controller.text),
            icon: state.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.search),
            label: Text(state.isLoading ? 'Verifying...' : 'Verify License'),
          ),
        ),
        const SizedBox(height: 24),
        state.when(
          data: (result) {
            if (result == null) return const SizedBox.shrink();
            if (!result.isValid) {
              return _ErrorResultCard(
                title: 'License Not Active / Registered',
                message: result.message.isNotEmpty ? result.message : 'The license number "${result.licenseNumber ?? controller.text}" is not active or registered in the BIS portal.',
              );
            }
            return _LicenseResultCard(result: result);
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Validating License against BIS Registry...'),
              ],
            ),
          ),
          error: (err, st) => _ErrorResultCard(
            title: 'Verification Failed',
            message: err is ApiException ? err.message : err.toString(),
          ),
        ),
      ],
    );
  }
}

class _HuidResultCard extends StatelessWidget {
  final HuidResult result;

  const _HuidResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppTheme.emeraldGreen, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'HUID: ${result.huid}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.status,
                    style: const TextStyle(
                      color: Color(0xFF10893E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _DetailRow(label: 'Jeweller Name', value: result.jewellerName),
            _DetailRow(label: 'Registration No.', value: result.registrationNo),
            _DetailRow(label: 'AHC Centre', value: result.ahcCenter),
            _DetailRow(label: 'Purity / Fineness', value: result.purity),
            _DetailRow(label: 'Article Type', value: result.articleType),
            _DetailRow(label: 'Gross Weight', value: result.grossWeight),
            _DetailRow(label: 'Hallmarking Date', value: result.hallmarkingDate),
          ],
        ),
      ),
    );
  }
}

class _LicenseResultCard extends StatelessWidget {
  final LicenseResult result;

  const _LicenseResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppTheme.emeraldGreen, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'License: ${result.licenseNumber}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.status,
                    style: const TextStyle(
                      color: Color(0xFF10893E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _DetailRow(label: 'Manufacturer', value: result.manufacturerName),
            _DetailRow(label: 'Product Name', value: result.productName),
            _DetailRow(label: 'Brand Name', value: result.brand),
            _DetailRow(label: 'IS Standard', value: result.isStandard),
            _DetailRow(label: 'Factory Address', value: result.factoryAddress),
            _DetailRow(label: 'Valid Till', value: result.validTill),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final displayValue = (value != null && value!.isNotEmpty) ? value! : 'N/A';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorResultCard extends StatelessWidget {
  final String title;
  final String message;

  const _ErrorResultCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFEF2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFFCA5A5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D), height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
