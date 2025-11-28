import 'package:flutter/material.dart';

class PreviewComponentsScreen extends StatelessWidget {
  const PreviewComponentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Preview Components (Material 3)")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- BUTTONS ----------------
          Text("Buttons", style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(onPressed: () {}, child: const Text("FilledButton")),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text("Filled Tonal"),
              ),
              OutlinedButton(onPressed: () {}, child: const Text("Outlined")),
              TextButton(onPressed: () {}, child: const Text("TextButton")),
              ElevatedButton(
                onPressed: () {},
                child: const Text("ElevatedButton"),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ---------------- CARDS ----------------
          Text("Card", style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text("Material 3 Card"),
              subtitle: const Text("Contoh card M3"),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),

          const SizedBox(height: 30),

          // ---------------- CHIPS ----------------
          Text("Chips", style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              FilterChip(
                label: const Text("Filter"),
                selected: true,
                onSelected: (v) {},
              ),
              InputChip(label: const Text("Input"), onPressed: () {}),
              ChoiceChip(
                label: const Text("Choice"),
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ---------------- SWITCH ----------------
          Text("Switch", style: theme.textTheme.titleLarge),
          Switch(value: true, onChanged: (_) {}),

          const SizedBox(height: 30),

          // ---------------- FAB ----------------
          Text("FloatingActionButton", style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Center(
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),

          const SizedBox(height: 30),

          // ---------------- LIST TILE ----------------
          Text("ListTile", style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text("Material 3 ListTile"),
            subtitle: const Text("Subtitle ListTile"),
            trailing: const Icon(Icons.chevron_right),
          ),

          const SizedBox(height: 30),

          // ---------------- DIALOG ----------------
          Text("Dialog", style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Material 3 Dialog"),
                  content: const Text("Ini contoh dialog M3."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Show Dialog"),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
