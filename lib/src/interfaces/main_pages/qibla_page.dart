import 'dart:async';
import 'dart:io';
import 'dart:math' show cos, pi, sin;

import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

double _angleDifference(double a, double b) {
  var diff = (a - b) % 360;
  if (diff < 0) diff += 360;
  if (diff > 180) diff = 360 - diff;
  return diff;
}

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  final _locationStatusController =
      StreamController<LocationStatus>.broadcast();

  Stream<LocationStatus> get _locationStatusStream =>
      _locationStatusController.stream;

  late final Future<bool?> _sensorSupportFuture = Platform.isAndroid
      ? FlutterQiblah.androidDeviceSensorSupport()
      : Future<bool?>.value(true);

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStatusController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    var locationStatus = await FlutterQiblah.checkLocationStatus();

    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      locationStatus = await FlutterQiblah.checkLocationStatus();
    }

    if (!_locationStatusController.isClosed) {
      _locationStatusController.sink.add(locationStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('qiblaFinder'.tr(), style: kSubHeadingM),
      ),
      body: FutureBuilder<bool?>(
        future: _sensorSupportFuture,
        builder: (context, sensorSnapshot) {
          if (sensorSnapshot.connectionState == ConnectionState.waiting) {
            return const _QiblaLoading();
          }

          return StreamBuilder<LocationStatus>(
            stream: _locationStatusStream,
            builder: (context, locationSnapshot) {
              if (locationSnapshot.connectionState == ConnectionState.waiting) {
                return const _QiblaLoading();
              }

              final status = locationSnapshot.data;
              if (status == null) {
                return _QiblaError(
                  message: 'qiblaLocationUnknown'.tr(),
                  onRetry: _checkLocationStatus,
                );
              }

              if (!status.enabled) {
                return _QiblaError(
                  message: 'qiblaLocationDisabled'.tr(),
                  onRetry: _checkLocationStatus,
                  showSettings: true,
                );
              }

              switch (status.status) {
                case LocationPermission.always:
                case LocationPermission.whileInUse:
                  final hasSensor = sensorSnapshot.data ?? true;
                  if (hasSensor) {
                    return const _QiblaCompassView();
                  }
                  return _QiblaBearingView(
                    onRetry: _checkLocationStatus,
                  );
                case LocationPermission.denied:
                  return _QiblaError(
                    message: 'qiblaPermissionDenied'.tr(),
                    onRetry: _checkLocationStatus,
                  );
                case LocationPermission.deniedForever:
                  return _QiblaError(
                    message: 'qiblaPermissionDeniedForever'.tr(),
                    onRetry: _checkLocationStatus,
                    showSettings: true,
                  );
                default:
                  return _QiblaError(
                    message: 'qiblaLocationUnknown'.tr(),
                    onRetry: _checkLocationStatus,
                  );
              }
            },
          );
        },
      ),
    );
  }
}

class _QiblaLoading extends StatelessWidget {
  const _QiblaLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: kPrimaryColor),
    );
  }
}

class _QiblaError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool showSettings;

  const _QiblaError({
    required this.message,
    required this.onRetry,
    this.showSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 72,
              color: kPrimaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhite,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: Text('qiblaRetry'.tr()),
            ),
            if (showSettings) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: openAppSettings,
                child: Text('qiblaOpenSettings'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QiblaStatusBanner extends StatelessWidget {
  final bool isFacingQibla;

  const _QiblaStatusBanner({required this.isFacingQibla});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFacingQibla ? kPrimaryColor.withOpacity(0.12) : kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFacingQibla
              ? kPrimaryColor.withOpacity(0.35)
              : const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              isFacingQibla ? Icons.check_circle : Icons.explore,
              color: isFacingQibla ? kPrimaryColor : kSecondaryTextColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isFacingQibla ? 'qiblaFacingQibla'.tr() : 'qiblaInstruction'.tr(),
              style: kSmallerTitleSB.copyWith(
                color: isFacingQibla ? kPrimaryColor : kSecondaryTextColor,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaCompassView extends StatelessWidget {
  const _QiblaCompassView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _QiblaLoading();
        }

        if (!snapshot.hasData) {
          return _QiblaError(
            message: 'qiblaCompassError'.tr(),
            onRetry: () => Navigator.of(context).pop(),
          );
        }

        final qiblah = snapshot.data!;
        final isFacingQibla =
            _angleDifference(qiblah.direction, qiblah.qiblah) < 8;

        final compassSize =
            (MediaQuery.sizeOf(context).width - 48).clamp(220.0, 300.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QiblaStatusBanner(isFacingQibla: isFacingQibla),
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: compassSize,
                  height: compassSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: (qiblah.direction * (pi / 180) * -1),
                            child: const _CompassDial(),
                          ),
                          Transform.rotate(
                            angle: (qiblah.qiblah * (pi / 180) * -1),
                            child: const _QiblaNeedle(),
                          ),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: kWhite,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: kPrimaryColor, width: 3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${'qiblaAngle'.tr()}: ${qiblah.offset.toStringAsFixed(1)}°',
                style: kBodyTitleM,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'qiblaMeccaNote'.tr(),
                textAlign: TextAlign.center,
                style: kSmallerTitleR.copyWith(
                  color: kSecondaryTextColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kWhite,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._cardinalMarkers(),
          CustomPaint(
            size: const Size(280, 280),
            painter: _CompassTicksPainter(),
          ),
        ],
      ),
    );
  }

  List<Widget> _cardinalMarkers() {
    const labels = ['N', 'E', 'S', 'W'];
    const angles = [0.0, 90.0, 180.0, 270.0];

    return List.generate(labels.length, (index) {
      final radians = angles[index] * pi / 180;
      const radius = 118.0;
      final dx = radius * sin(radians);
      final dy = radius * -cos(radians);

      return Transform.translate(
        offset: Offset(dx, dy),
        child: Text(
          labels[index],
          style: kSmallerTitleSB.copyWith(
            fontSize: index == 0 ? 18 : 14,
            color: index == 0 ? kPrimaryColor : kSecondaryTextColor,
          ),
        ),
      );
    });
  }
}

class _CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 72; i++) {
      final angle = i * 5 * pi / 180;
      final isMajor = i % 6 == 0;
      final outerRadius = size.width / 2 - 8;
      final innerRadius = outerRadius - (isMajor ? 14 : 8);

      final start = Offset(
        center.dx + innerRadius * sin(angle),
        center.dy - innerRadius * cos(angle),
      );
      final end = Offset(
        center.dx + outerRadius * sin(angle),
        center.dy - outerRadius * cos(angle),
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaNeedle extends StatelessWidget {
  const _QiblaNeedle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: _QiblaNeedlePainter(),
      ),
    );
  }
}

class _QiblaNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final needlePath = Path()
      ..moveTo(center.dx, center.dy - 108)
      ..lineTo(center.dx - 14, center.dy + 24)
      ..lineTo(center.dx, center.dy + 12)
      ..lineTo(center.dx + 14, center.dy + 24)
      ..close();

    final needlePaint = Paint()
      ..color = kPrimaryColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = kPrimaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawPath(needlePath.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawPath(needlePath, needlePaint);

    final tailPath = Path()
      ..moveTo(center.dx, center.dy + 12)
      ..lineTo(center.dx - 10, center.dy + 70)
      ..lineTo(center.dx + 10, center.dy + 70)
      ..close();

    canvas.drawPath(
      tailPath,
      Paint()..color = kSecondaryTextColor.withOpacity(0.35),
    );

    canvas.drawCircle(
      Offset(center.dx, center.dy - 100),
      6,
      Paint()..color = kWhite,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaBearingView extends StatefulWidget {
  final VoidCallback onRetry;

  const _QiblaBearingView({required this.onRetry});

  @override
  State<_QiblaBearingView> createState() => _QiblaBearingViewState();
}

class _QiblaBearingViewState extends State<_QiblaBearingView> {
  static const _mecca = (latitude: 21.422487, longitude: 39.826206);

  double? _bearing;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBearing();
  }

  Future<void> _loadBearing() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final bearing = Geolocator.bearingBetween(
        position.latitude,
        position.longitude,
        _mecca.latitude,
        _mecca.longitude,
      );

      if (mounted) {
        setState(() {
          _bearing = (bearing + 360) % 360;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'qiblaCompassError'.tr();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _QiblaError(
        message: _error!,
        onRetry: () {
          widget.onRetry();
          _loadBearing();
        },
      );
    }

    if (_bearing == null) {
      return const _QiblaLoading();
    }

    final compassSize =
        (MediaQuery.sizeOf(context).width - 48).clamp(220.0, 300.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Text(
              'qiblaNoSensor'.tr(),
              textAlign: TextAlign.center,
              style: kSmallerTitleR.copyWith(
                color: kSecondaryTextColor,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: compassSize,
              height: compassSize,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const _CompassDial(),
                      Transform.rotate(
                        angle: _bearing! * pi / 180,
                        child: const _QiblaNeedle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${'qiblaAngle'.tr()}: ${_bearing!.toStringAsFixed(1)}°',
            style: kBodyTitleM,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'qiblaMeccaNote'.tr(),
            textAlign: TextAlign.center,
            style: kSmallerTitleR.copyWith(
              color: kSecondaryTextColor,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
