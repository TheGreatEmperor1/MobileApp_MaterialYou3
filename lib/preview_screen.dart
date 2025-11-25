import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  String _hex(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surfaceFill = cs.surfaceContainerHighest;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Components'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
              child: const Text('Primary Button'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Tonal Button'),
            ),
            const SizedBox(height: 12),
            Card(
              color: cs.surface,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: cs.primary, child: Icon(Icons.person, color: cs.onPrimary)),
                title: const Text('Card / ListTile'),
                subtitle: Text('Surface color: ${_hex(cs.surface)}'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Input example',
                filled: true,
                fillColor: surfaceFill,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.color_lens, color: cs.primary),
              title: Text('Primary HEX: ${_hex(cs.primary)}'),
            ),
          ],
        ),
      ),
    );
  }
}