import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/business_models.dart';
import '../../services/app_data_service.dart';

class SplashAdGate extends StatefulWidget {
  const SplashAdGate({super.key, required this.child});

  final Widget child;

  @override
  State<SplashAdGate> createState() => _SplashAdGateState();
}

class _SplashAdGateState extends State<SplashAdGate> {
  final _appDataService = AppDataService();
  bool _hasRequestedAd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndShowAd());
  }

  Future<void> _loadAndShowAd() async {
    if (_hasRequestedAd || !mounted) {
      return;
    }
    _hasRequestedAd = true;
    final result = await _appDataService.getSplashAd();
    if (!mounted || !result.isSuccess || result.data == null) {
      return;
    }
    final ad = result.data!;
    if (!ad.isValid) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _SplashAdDialog(ad: ad),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SplashAdDialog extends StatefulWidget {
  const _SplashAdDialog({required this.ad});

  final SplashAdVO ad;

  @override
  State<_SplashAdDialog> createState() => _SplashAdDialogState();
}

class _SplashAdDialogState extends State<_SplashAdDialog> {
  static const _shakeThreshold = 24.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastJumpTime;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).listen(_handleAccelerometerEvent);
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();
    if (_lastJumpTime != null &&
        now.difference(_lastJumpTime!) < const Duration(seconds: 2)) {
      return;
    }
    final acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    if (acceleration < _shakeThreshold) {
      return;
    }
    _lastJumpTime = now;
    _openTarget(withHaptic: true);
  }

  Future<void> _openTarget({bool withHaptic = false}) async {
    final targetUrl = widget.ad.targetUrl.trim().replaceAll('`', '');
    final targetUri = Uri.tryParse(targetUrl);
    if (targetUri == null || !targetUri.hasScheme) {
      return;
    }
    if (withHaptic || !kIsWeb) {
      await HapticFeedback.mediumImpact();
    }
    final launched = await _launchTarget(targetUri);
    if (!mounted) {
      return;
    }
    if (launched) {
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂时无法打开广告链接')));
    }
  }

  Future<bool> _launchTarget(Uri targetUri) async {
    if (kIsWeb) {
      return launchUrl(
        targetUri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
    }
    const modes = [LaunchMode.externalApplication, LaunchMode.platformDefault];
    for (final mode in modes) {
      try {
        if (await launchUrl(targetUri, mode: mode)) {
          return true;
        }
      } on PlatformException {
        // Some platforms reject a launch mode even when another mode works.
      }
    }
    return false;
  }

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Uri.encodeFull(imageUrl);
    }
    final origin = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:7022'
        : 'http://localhost:7022';
    final resolvedUrl = imageUrl.startsWith('/')
        ? '$origin$imageUrl'
        : '$origin/$imageUrl';
    return Uri.encodeFull(resolvedUrl);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _openTarget,
                  child: Image.network(
                    _resolveImageUrl(widget.ad.imageUrl),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 220,
                      color: colorScheme.primaryContainer,
                      alignment: Alignment.center,
                      child: const Text('广告图片加载失败'),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton.filledTonal(
                    key: const ValueKey('splash_ad_close_button'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                children: [
                  Text(
                    widget.ad.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kIsWeb ? '点击广告查看详情' : '点击广告或摇一摇手机查看详情',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    key: const ValueKey('splash_ad_open_button'),
                    onPressed: _openTarget,
                    child: const Text('立即查看'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
