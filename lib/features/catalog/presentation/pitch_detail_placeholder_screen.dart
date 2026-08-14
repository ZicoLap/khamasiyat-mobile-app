import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';
import 'package:khamasiyat_mobile_app/app/theme/app_spacing.dart';

/// F3B handoff placeholder — availability not implemented in F3A.
class PitchDetailPlaceholderScreen extends StatelessWidget {
  const PitchDetailPlaceholderScreen({super.key, required this.pitchId});

  final String pitchId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pitchDetailPlaceholderTitle)),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.pitchDetailPlaceholderBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.pitchDetailIdLabel(pitchId),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
