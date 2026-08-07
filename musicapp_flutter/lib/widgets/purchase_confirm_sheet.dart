import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/track.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';

/// Confirmation sheet shown before redirecting to the official Apple
/// iTunes page — mirrors the web app's purchase modal. The app never
/// processes a real payment or verifies anything with Apple; checking the
/// box just saves a local "I bought this" record for the Purchased badge.
Future<void> showPurchaseConfirmSheet(BuildContext context, Track track) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PurchaseConfirmSheet(track: track),
  );
}

class _PurchaseConfirmSheet extends StatefulWidget {
  final Track track;
  const _PurchaseConfirmSheet({required this.track});

  @override
  State<_PurchaseConfirmSheet> createState() => _PurchaseConfirmSheetState();
}

class _PurchaseConfirmSheetState extends State<_PurchaseConfirmSheet> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_rounded, color: colors.accent, size: 26),
            ),
            const SizedBox(height: 16),
            Text(strings.t('app.purchase.title'), style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: '${strings.t('app.purchase.subtitle')} ',
                style: TextStyle(color: colors.text1),
                children: [
                  TextSpan(
                    text: widget.track.trackName ?? '',
                    style: TextStyle(color: colors.text0, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => _checked = !_checked),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: _checked,
                      onChanged: (v) => setState(() => _checked = v ?? false),
                    ),
                    Expanded(
                      child: Text(strings.t('app.purchase.checkboxLabel'), style: TextStyle(color: colors.text1)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.accentContrast,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                onPressed: () async {
                  if (_checked) {
                    await context.read<LibraryProvider>().confirmPurchase(widget.track);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                  final url = widget.track.trackViewUrl;
                  if (url != null) {
                    final uri = Uri.tryParse(url);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Text(strings.t('app.purchase.continueToItunes'), style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.t('app.purchase.cancel'), style: TextStyle(color: colors.text1)),
            ),
          ],
        ),
      ),
    );
  }
}
