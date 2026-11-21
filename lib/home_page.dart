import 'package:flutter/material.dart';
import 'theme.dart';
import 'wifi_external_page.dart';
import 'about_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VokraTheme.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand bar
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 32, height: 32, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: VokraTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('V',
                              style: TextStyle(
                                fontFamily: VokraTheme.fontDisplay,
                                color: VokraTheme.onPrimary,
                                fontSize: 18,
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('VOKRA', style: VokraTheme.displaySm),
                ],
              ),
              const SizedBox(height: 40),

              // Hero
              Text('NETWORK\nCOMPANION', style: VokraTheme.displayXl),
              const SizedBox(height: 16),
              Text(
                'Toolkit ringkas untuk memahami jaringan yang sedang kamu pakai '
                '- SSID, gateway, dan panel diagnostik lokal.',
                style: VokraTheme.bodyMd,
              ),
              // Baris V1.0.0 & HANZ DEV sudah dihapus dari sini
              const SizedBox(height: 28),

              // Feature cards
              _FeatureCard(
                badge: 'EXTERNAL',
                title: 'LOCAL NETWORK',
                body: 'Baca SSID, IP, dan gateway. Panel diagnostik flood dengan '
                    'target IP yang bisa diubah - gateway, LAN, atau publik.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WifiExternalPage()),
                ),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                badge: 'INFO',
                title: 'ABOUT & CREDITS',
                body: 'Developer, kontak, dan link dukungan.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
              const SizedBox(height: 28),

              // Callout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: VokraTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(VokraTheme.rLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TEST ON YOUR OWN NETWORK',
                      style: VokraTheme.displayMd.copyWith(color: VokraTheme.onDark),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Semua aksi di Vokra menargetkan jaringan yang sedang kamu pakai.',
                      style: VokraTheme.bodySm.copyWith(color: VokraTheme.onDarkSoft),
                    ),
                  ],
                ),
              ),
              // Footer HANZ DEV OFFICIAL sudah dihapus dari sini
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String badge;
  final String title;
  final String body;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.badge,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VokraTheme.surfaceCard,
      borderRadius: BorderRadius.circular(VokraTheme.rLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(VokraTheme.rLg),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VokraTheme.rLg),
            border: Border.all(color: VokraTheme.hairlineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: VokraTheme.primary,
                  borderRadius: BorderRadius.circular(VokraTheme.rPill),
                ),
                child: Text(badge,
                    style: VokraTheme.captionUpper
                        .copyWith(color: VokraTheme.onPrimary, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 16),
              Text(title, style: VokraTheme.displaySm),
              const SizedBox(height: 8),
              Text(body, style: VokraTheme.bodySm),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text('BUKA',
                      style: VokraTheme.titleSm
                          .copyWith(color: VokraTheme.primary, letterSpacing: 1.5)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward,
                      size: 14, color: VokraTheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
