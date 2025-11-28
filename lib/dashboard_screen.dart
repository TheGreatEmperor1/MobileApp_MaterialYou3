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
    final textStyleLarge = TextStyle(color: cs.onSurface, fontSize: 48, fontWeight: FontWeight.w700);
    final textStyleSmall = TextStyle(color: cs.onSurface.withAlpha((0.7 * 255).round()), fontSize: 16);

    // Gunakan asset SVG yang sudah kamu letakkan di assets/icons/
    final apps = <Map<String, String>>[
      {'name': 'YouTube', 'asset': 'assets/icons/youtube.svg'},
      {'name': 'Maps', 'asset': 'assets/icons/googlemaps.svg'},
      {'name': 'Gmail', 'asset': 'assets/icons/gmail.svg'},
      {'name': 'Drive', 'asset': 'assets/icons/googledrive.svg'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Material You'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card untuk jam + tanggal
                Card(
                  elevation: 2,
                  color: cs.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_timeString, style: textStyleLarge),
                        const SizedBox(height: 8),
                        Text(_dateString, style: textStyleSmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Google search bar
                Material(
                  elevation: 1,
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(28),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cs.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Apps section header
                Text(
                  'Quick Apps',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),

                // Apps grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: apps.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, i) {
                    final app = apps[i];
                    final asset = app['asset']!;
                    return InkWell(
                      onTap: () {
                        _openAppSearch(app['name']!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening ${app['name']}...'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Builder(builder: (_) {
                              // Jika file SVG ada dan terdaftar di pubspec, tampilkan dengan tint
                              try {
                                return Center(
                                  child: SvgPicture.asset(
                                    asset,
                                    width: 32,
                                    height: 32,
                                    // gunakan 'color' (tersedia di banyak versi flutter_svg)
                                    color: cs.onSecondaryContainer,
                                  ),
                                );
                              } catch (e) {
                                // fallback ke Icon jika asset gagal dimuat
                                return Icon(Icons.apps, color: cs.onSecondaryContainer, size: 32);
                              }
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app['name']!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                    '🎨 Dashboard menggunakan warna Material You yang Anda pilih',
                    style: TextStyle(
                      color: cs.onSurface.withAlpha((0.6 * 255).round()),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}