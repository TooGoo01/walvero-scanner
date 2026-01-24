import 'package:flutter/material.dart';

class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İcazə yoxdur')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Bu səhifəyə çıxış üçün səlahiyyətiniz yoxdur.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
