import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleDynamic;
  final VoidCallback onRandomSeed;
  final ValueChanged<Color> onSetSeed;
  final ValueChanged<Color> onApplyAsPrimary;
  final VoidCallback onClearPrimaryOverride;
  final bool isUsingDynamic;
  final Color currentSeed;
  final VoidCallback? goToPreview;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  // presets
  final List<Color> presets;
  final ValueChanged<Color> onSavePreset;
  final ValueChanged<Color> onRemovePreset;

  // auto apply
  final bool autoApplyOnTap;
  final VoidCallback onToggleAutoApply;

  const HomeScreen({
    super.key,
    required this.onToggleDynamic,
    required this.onRandomSeed,
    required this.onSetSeed,
    required this.onApplyAsPrimary,
    required this.onClearPrimaryOverride,
    required this.isUsingDynamic,
    required this.currentSeed,
    this.goToPreview,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.presets,
    required this.onSavePreset,
    required this.onRemovePreset,
    required this.autoApplyOnTap,
    required this.onToggleAutoApply,
  });

  // helper: Color -> ARGB hex string using .a/.r/.g/.b
  int _toARGB32(Color c) {
    final a = (c.a * 255.0).round() & 0xff;
    final r = (c.r * 255.0).round() & 0xff;
    final g = (c.g * 255.0).round() & 0xff;
    final b = (c.b * 255.0).round() & 0xff;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  String _hex(Color c) => '#${_toARGB32(c).toRadixString(16).padLeft(8, '0').toUpperCase()}';

  // return true if colors are visually similar (simple luminance check)
  bool _isSimilar(Color a, Color b, [double threshold = 0.06]) {
    return (a.computeLuminance() - b.computeLuminance()).abs() < threshold;
  }

  // open color picker dialog and apply chosen color via onSetSeed
  void _openColorPicker(BuildContext context) {
    Color temp = currentSeed;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: temp,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
            pickerAreaHeightPercent: 0.7,
            // avoid showLabel (deprecated)
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // always apply chosen color as seed AND force primary to that color
              onSetSeed(temp);
              onApplyAsPrimary(temp);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Picked color ${_hex(temp)} (applied)'), duration: const Duration(seconds: 2)),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _swatch(BuildContext context, String name, Color color, Color onColor, Color scaffoldBg) {
    final showBorder = _isSimilar(color, scaffoldBg, 0.06);
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // always set seed
              onSetSeed(color);
              // if autoApply is on, also force primary to this color
              if (autoApplyOnTap) onApplyAsPrimary(color);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name set as seed\n${_hex(color)}'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Use as Primary',
                    onPressed: () {
                      onApplyAsPrimary(color);
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: showBorder ? Border.all(color: onColor.withAlpha((0.18 * 255).round())) : null,
              ),
              child: Center(
                child: Text(
                  name,
                  style: TextStyle(color: onColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        Text(_hex(color), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.8 * 255).round()))),
      ],
    );
  }

  Widget _presetTile(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        // apply preset as seed
        onSetSeed(color);
        // IMPORTANT: always force primary to this preset (patch requested)
        onApplyAsPrimary(color);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preset applied ${_hex(color)}'), duration: const Duration(seconds: 1)));
      },
      onLongPress: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete preset?'),
            content: Text('Remove preset ${_hex(color)}?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
            ],
          ),
        );

        if (!context.mounted) return;
        if (confirm == true) {
          onRemovePreset(color);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preset removed ${_hex(color)}'), duration: const Duration(seconds: 1)));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.12 * 255).round())),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    // use cs.surface as a safe fallback across Flutter versions
    final surfaceSwatch = cs.surface;
    final backgroundSwatch = cs.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material You Demo'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear primary override',
            icon: const Icon(Icons.clear),
            onPressed: onClearPrimaryOverride,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Preview components',
        onPressed: () {
          if (goToPreview != null) {
            goToPreview!();
          } else {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Preview'),
                content: const Text('Preview not available.'),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
              ),
            );
          }
        },
        backgroundColor: cs.secondary,
        child: Icon(Icons.visibility, color: cs.onSecondary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              const Text('Color Scheme Swatches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _swatch(context, 'primary', cs.primary, cs.onPrimary, scaffoldBg),
                  _swatch(context, 'secondary', cs.secondary, cs.onSecondary, scaffoldBg),
                  _swatch(context, 'surface', surfaceSwatch, cs.onSurface, scaffoldBg),
                  _swatch(context, 'background', backgroundSwatch, cs.onSurface, scaffoldBg),
                  _swatch(context, 'error', cs.error, cs.onError, scaffoldBg),
                  _swatch(context, 'primaryContainer', cs.primaryContainer, cs.onPrimaryContainer, scaffoldBg),
                ],
              ),
              const SizedBox(height: 12),

              // presets row
              if (presets.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: presets.map((c) => _presetTile(context, c)).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onToggleDynamic,
                      icon: Icon(isUsingDynamic ? Icons.settings : Icons.palette),
                      label: Text(isUsingDynamic ? 'Use System Dynamic' : 'Use Seed Color'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: onRandomSeed,
                    child: const Icon(Icons.shuffle),
                  ),
                  const SizedBox(width: 8),
                  // color picker button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () => _openColorPicker(context),
                    child: const Icon(Icons.colorize),
                  ),
                  const SizedBox(width: 8),
                  // save current seed as preset
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () {
                      onSavePreset(currentSeed);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preset saved ${_hex(currentSeed)}'), duration: const Duration(seconds: 1)));
                    },
                    child: const Icon(Icons.save),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Theme toggle (Light / Dark) — replace deprecated activeColor with thumbColor
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.light_mode),
                  Switch(
                    value: isDarkMode,
                    onChanged: (_) => onToggleDarkMode(),
                    thumbColor: MaterialStateProperty.all(cs.primary),
                  ),
                  const Icon(Icons.dark_mode),
                  const SizedBox(width: 8),
                  Text(isDarkMode ? 'Dark mode' : 'Light mode', style: TextStyle(color: cs.onSurface)),
                  const SizedBox(width: 16),
                  // Auto-apply toggle
                  const SizedBox(width: 8),
                  const Text('Auto-apply', style: TextStyle(fontSize: 12)),
                  Switch(
                    value: autoApplyOnTap,
                    onChanged: (_) => onToggleAutoApply(),
                    thumbColor: MaterialStateProperty.all(cs.primary),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Tap a swatch to set it as seed color.\nUse "Use as Primary" in the SnackBar to force that color as primary.\nLong-press a preset to remove it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}          m