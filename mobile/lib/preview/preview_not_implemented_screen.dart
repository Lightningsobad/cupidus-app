import 'package:flutter/material.dart';

/// STORY-018 P8 placeholder for a design canvas id that has no shipped
/// screen yet, so `implemented-<id>-*.png` still exists at capture time
/// instead of silently missing from the delivered set.
class PreviewNotImplementedScreen extends StatelessWidget {
  const PreviewNotImplementedScreen({super.key, required this.canvasId});

  final String canvasId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(canvasId, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('NOT_IMPLEMENTED'),
            ],
          ),
        ),
      ),
    );
  }
}
