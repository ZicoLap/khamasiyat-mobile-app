import 'package:flutter/material.dart';
import 'package:khamasiyat_mobile_app/app/localization/l10n_extensions.dart';

/// Shown while secure session restoration runs (avoids login flash).
class SessionSplashScreen extends StatelessWidget {
  const SessionSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.sessionRestoring),
          ],
        ),
      ),
    );
  }
}
