import 'package:flutter/material.dart';

class SplashScreenUi extends StatelessWidget {
  const SplashScreenUi({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.newspaper, size: 80, color: scheme.onPrimary),
            const SizedBox(height: 16),
            Text(
              'News Intelligence',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}