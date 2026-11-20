import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _dev = 'Hanz Dev Official';
  static const String _email = 'hanzzcodee@gmail.com';
  static const String _saweria = 'https://saweria.co/hanzreally';
  static const String _version = '1.0.0';

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: VokraTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VokraTheme.rMd),
        ),
        content: Text('$label disalin: $value',
            style: VokraTheme.bodySm.copyWith(color: VokraTheme.onDark)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VokraTheme.canvas,
      appBar: AppBar(
        title: Text('ABOUT', style: VokraTheme.displaySm),
        backgroundColor: VokraTheme.canvas,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: VokraTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(VokraTheme.rLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VOKRA',
                        style: VokraTheme.displayLg
                            .copyWith(color: VokraTheme.onDark)),
                    const SizedBox(height: 8),
                    Text('Network analysis toolkit',
                        style: VokraTheme.bodySm
                            .copyWith(color: VokraTheme.onDarkSoft)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: VokraTheme.primary,
                        borderRadius: BorderRadius.circular(VokraTheme.rPill),
                      ),
                      child: Text('VERSION $_version',
                          style: VokraTheme.captionUpper
                              .copyWith(color: VokraTheme.onPrimary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _InfoTile(
                label: 'DEVELOPER',
                value: _dev,
                icon: Icons.person_outline,
                onTap: () => _copy(context, 'Developer', _dev),
              ),
              const SizedBox(height: 12),

              _InfoTile(
                label: 'KONTAK',
                value: _email,
                icon: Icons.mail_outline,
                onTap: () => _copy(context, 'Email', _email),
              ),
              const SizedBox(height: 12),

              _InfoTile(
                label: 'DUKUNG',
                value: _saweria,
                icon: Icons.favorite_border,
                accentValue: true,
                onTap: () => _copy(context, 'Saweria', _saweria),
              ),
              const SizedBox(height: 28),

              // Support callout
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: VokraTheme.primary,
                  borderRadius: BorderRadius.circular(VokraTheme.rLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DUKUNG PENGEMBANGAN',
                        style: VokraTheme.displaySm
                            .copyWith(color: VokraTheme.onPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      'Kalau Vokra berguna, traktir kopi lewat Saweria. '
                      'Setiap dukungan masuk ke biaya server dan tools.',
                      style: VokraTheme.bodySm
                          .copyWith(color: VokraTheme.onPrimary),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _copy(context, 'Saweria', _saweria),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VokraTheme.onPrimary,
                        side: const BorderSide(
                            color: VokraTheme.onPrimary, width: 1.2),
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(VokraTheme.rMd)),
                      ),
                      child: const Text('SALIN LINK SAWERIA'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: Text('(c) 2026 $_dev - v$_version',
                    style: VokraTheme.caption
                        .copyWith(color: VokraTheme.mutedSoft)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool accentValue;
  final VoidCallback onTap;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.accentValue = false,
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VokraTheme.rLg),
            border: Border.all(color: VokraTheme.hairlineSoft),
          ),
          child: Row(
            children: [
              Icon(icon, color: VokraTheme.primary, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: VokraTheme.captionUpper),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: VokraTheme.titleSm.copyWith(
                        color: accentValue
                            ? VokraTheme.primary
                            : VokraTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.copy, size: 14, color: VokraTheme.mutedSoft),
            ],
          ),
        ),
      ),
    );
  }
}
