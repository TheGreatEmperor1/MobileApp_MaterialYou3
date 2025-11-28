// Updated main.dart: import dashboard and pass goToDashboard callback to HomeScreen
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'preview_screen.dart';
import 'dashboard_screen.dart'; // NEW

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool useDynamic = true;
  Color seed = const Color(0xFF6750A4); // default seed
  bool loaded = false;

  Color? primaryOverride;
  bool isDarkMode = false;
  bool autoApplyOnTap = false;
  List<String> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  int _toARGB32(Color c) {
    final a = (c.a * 255.0).round() & 0xff;
    final r = (c.r * 255.0).round() & 0xff;
    final g = (c.g * 255.0).round() & 0xff;
    final b = (c.b * 255.0).round() & 0xff;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt('seedColor');
    final bool? dynamicPref = prefs.getBool('useDynamic');
    final int? primaryValue = prefs.getInt('primaryOverride');
    final bool? darkPref = prefs.getBool('isDarkMode');
    final bool? autoPref = prefs.getBool('autoApplyOnTap');
    final List<String>? presets = prefs.getStringList('presets');
    setState(() {
      if (colorValue != null) seed = Color(colorValue);
      if (dynamicPref != null) useDynamic = dynamicPref;
      if (primaryValue != null) primaryOverride = Color(primaryValue);
      if (darkPref != null) isDarkMode = darkPref;
      if (autoPref != null) autoApplyOnTap = autoPref;
      if (presets != null) _presets = presets;
      loaded = true;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', _toARGB32(seed));
    await prefs.setBool('useDynamic', useDynamic);
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setBool('autoApplyOnTap', autoApplyOnTap);
    if (primaryOverride != null) {
      await prefs.setInt('primaryOverride', _toARGB32(primaryOverride!));
    } else {
      await prefs.remove('primaryOverride');
    }
    await prefs.setStringList('presets', _presets);
  }

  void toggleUseDynamic() {
    setState(() {
      useDynamic = !useDynamic;
      if (useDynamic) primaryOverride = null;
    });
    _savePreferences();
  }

  void randomizeSeed() {
    final rnd = Random();
    setState(() {
      seed = Color.fromARGB(0xFF, rnd.nextInt(256), rnd.nextInt(256), rnd.nextInt(256));
      useDynamic = false;
      primaryOverride = null;
    });
    _savePreferences();
  }

  void setSeed(Color c) {
    setState(() {
      seed = c;
      useDynamic = false;
      primaryOverride = null;
    });
    _savePreferences();
  }

  void applyAsPrimary(Color c) {
    setState(() {
      primaryOverride = c;
      useDynamic = false;
    });
    _savePreferences();
  }

  void clearPrimaryOverride() {
    setState(() {
      primaryOverride = null;
    });
    _savePreferences();
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    _savePreferences();
  }

  void toggleAutoApply() {
    setState(() {
      autoApplyOnTap = !autoApplyOnTap;
    });
    _savePreferences();
  }

  String _hexFor(Color c) => _toARGB32(c).toRadixString(16).padLeft(8, '0').toUpperCase();

  void addPreset(Color c) {
    final hex = _hexFor(c);
    if (!_presets.contains(hex)) {
      setState(() {
        _presets.add(hex);
      });
      _savePreferences();
    }
  }

  void removePreset(String hex) {
    setState(() {
      _presets.remove(hex);
    });
    _savePreferences();
  }

  List<Color> get presets => _presets.map((h) => Color(int.parse(h, radix: 16))).toList();

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final baseLight = (useDynamic && lightDynamic != null) ? lightDynamic : ColorScheme.fromSeed(seedColor: seed);
        final baseDark = (useDynamic && darkDynamic != null) ? darkDynamic : ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

        final light = primaryOverride != null ? baseLight.copyWith(primary: primaryOverride) : baseLight;
        final dark = primaryOverride != null ? baseDark.copyWith(primary: primaryOverride) : baseDark;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Material You Demo',
          theme: ThemeData(colorScheme: light, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: dark, useMaterial3: true),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomeScreen(
            onToggleDynamic: toggleUseDynamic,
            onRandomSeed: randomizeSeed,
            onSetSeed: setSeed,
            onApplyAsPrimary: applyAsPrimary,
            isUsingDynamic: useDynamic,
            currentSeed: seed,
            goToPreview: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PreviewScreen())),
            goToDashboard: () {
              // debug wrapper around Navigator push so we can see logs & catch errors
              debugPrint('>>> goToDashboard called');
              try {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
                debugPrint('>>> Navigator.push executed');
              } catch (e, st) {
                debugPrint('>>> Navigator.push error: $e');
                debugPrint('$st');
              }
            },
            onClearPrimaryOverride: clearPrimaryOverride,
            isDarkMode: isDarkMode,
            onToggleDarkMode: toggleDarkMode,
            presets: presets,
            onSavePreset: addPreset,
            onRemovePreset: (color) => removePreset(_toARGB32(color).toRadixString(16).padLeft(8, '0').toUpperCase()),
            autoApplyOnTap: autoApplyOnTap,
            onToggleAutoApply: toggleAutoApply,
          ),
        );
      },
    );
  }
}