import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.accessDenied)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            Text(
              l.accessDeniedMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
