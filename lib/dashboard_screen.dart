import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // update setiap detik; ubah ke Duration(minutes: 1) jika ingin hemat baterai
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String get _timeString => DateFormat.Hm().format(_now); // ex: 14:23
  String get _dateString => DateFormat.yMMMMEEEEd().format(_now); // ex: Senin, 1 Januari 2025

  Future<void> _searchGoogle(String query) async {
    if (query.trim().isEmpty) return;
    final url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(query)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka browser')));
    }
  }

  Future<void> _openAppSearch(String appName) async {
    await _searchGoogle(appName);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyleLarge = TextStyle(color: cs.onBackground, fontSize: 32, fontWeight: FontWeight.w600);
    final textStyleSmall = TextStyle(color: cs.onBackground.withAlpha((0.7 * 255).round()));

    // Gunakan asset SVG yang sudah kamu letakkan di assets/icons/
    final apps = <Map<String, String>>[
      {'name': 'YouTube', 'asset': 'assets/icons/youtube.svg'},
      {'name': 'Maps', 'asset': 'assets/icons/googlemaps.svg'},
      {'name': 'Gmail', 'asset': 'assets/icons/gmail.svg'},
      {'name': 'Drive', 'asset': 'assets/icons/googledrive.svg'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // jam + tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_timeString, style: textStyleLarge),
                    const SizedBox(height: 4),
                    Text(_dateString, style: textStyleSmall),
                  ]),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quick action')));
                    },
                    icon: Icon(Icons.info_outline, color: cs.onBackground),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Google search bar
              Material(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (q) {
                    _searchGoogle(q);
                    _searchController.clear();
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search Google',
                    prefixIcon: Icon(Icons.search, color: cs.onSurface),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.close, color: cs.onSurface),
                            onPressed: () => setState(() => _searchController.clear()),
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Apps grid
              Text('Apps', style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  itemCount: apps.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, i) {
                    final app = apps[i];
                    final asset = app['asset']!;
                    return GestureDetector(
                      onTap: () => _openAppSearch(app['name']!),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: cs.primary,
                            child: Builder(builder: (_) {
                              // Jika file SVG ada dan terdaftar di pubspec, tampilkan dengan tint
                              try {
                                return SvgPicture.asset(
                                  asset,
                                  width: 28,
                                  height: 28,
                                  // gunakan 'color' (tersedia di banyak versi flutter_svg)
                                  color: cs.onPrimary,
                                );
                              } catch (e) {
                                // fallback ke Icon jika asset gagal dimuat
                                return Icon(Icons.apps, color: cs.onPrimary, size: 28);
                              }
                            }),
                          ),
                          const SizedBox(height: 6),
                          Flexible(
                            child: Text(
                              app['name']!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: cs.onBackground, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap an app icon to search it on Google. Theme follows Material You colors.',
                  style: TextStyle(color: cs.onBackground.withAlpha((0.6 * 255).round()), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}