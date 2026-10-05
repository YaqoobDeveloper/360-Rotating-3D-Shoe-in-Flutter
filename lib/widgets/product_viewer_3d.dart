import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/product.dart';
import '../theme/sneaker_theme.dart';
import 'fallback_rotator.dart';
import 'orbit_painter.dart';

/// Lets the parent (e.g. the thumbnail row) turn the product to a preset
/// angle. Works for both the 3D viewer and the 2D fallback.
class ProductViewerController extends ChangeNotifier {
  ProductAngle _angle = ProductAngle.side;

  ProductAngle get angle => _angle;

  /// Always notifies, so tapping the current thumbnail again re-centres the
  /// view after the user has dragged it away.
  void showAngle(ProductAngle angle) {
    _angle = angle;
    notifyListeners();
  }
}

enum _ViewerStatus { loading, ready, failed }

/// Interactive 3D product viewer with an orbit line, a drag hint, a loading
/// shimmer and an automatic 2D fallback when the model cannot be loaded.
///
/// The default model is "Materials Variants Shoe" from the Khronos
/// glTF-Sample-Assets repository, © 2021 Shopify, licensed CC BY 4.0
/// (https://creativecommons.org/licenses/by/4.0/). See [kSneakerModelUrl].
class ProductViewer3D extends StatefulWidget {
  const ProductViewer3D({
    super.key,
    required this.modelUrl,
    required this.fallbackImage,
    this.controller,
    this.loadTimeout = const Duration(seconds: 20),
    this.forceFallback = false,
  });

  /// URL (or asset path) of a .glb/.gltf model.
  final String modelUrl;

  /// Asset path of the image the 2D fallback rotates.
  final String fallbackImage;

  final ProductViewerController? controller;

  /// Switch to the fallback if no load progress is reported for this long.
  final Duration loadTimeout;

  /// Skip the 3D viewer entirely (useful for tests and low-end devices).
  final bool forceFallback;

  @override
  State<ProductViewer3D> createState() => _ProductViewer3DState();
}

class _ProductViewer3DState extends State<ProductViewer3D> {
  static const _channelName = 'ViewerBridge';

  /// Slight roll so the sneaker looks like it floats, toe dipping down.
  static const _modelOrientation = '-16deg 0deg 0deg';

  late _ViewerStatus _status;
  bool _showHint = true;
  double _progress = 0;
  double _dragDistance = 0;
  Timer? _watchdog;
  WebViewController? _webViewController;

  ProductAngle get _angle => widget.controller?.angle ?? ProductAngle.side;

  /// model_viewer_plus supports Android, iOS and the web.
  bool get _platformSupports3D =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onAngleChanged);
    if (widget.forceFallback || !_platformSupports3D) {
      _status = _ViewerStatus.failed;
    } else if (kIsWeb) {
      // The web build has no JS bridge back to Flutter; show it directly.
      _status = _ViewerStatus.ready;
    } else {
      _status = _ViewerStatus.loading;
      _armWatchdog();
    }
  }

  @override
  void didUpdateWidget(ProductViewer3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onAngleChanged);
      widget.controller?.addListener(_onAngleChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onAngleChanged);
    _watchdog?.cancel();
    super.dispose();
  }

  void _armWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(widget.loadTimeout, () => _fail('load timed out'));
  }

  void _fail(String reason) {
    if (!mounted || _status == _ViewerStatus.failed) return;
    debugPrint('ProductViewer3D: falling back to 2D ($reason)');
    _watchdog?.cancel();
    setState(() {
      _status = _ViewerStatus.failed;
      _webViewController = null;
    });
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    if (!mounted) return;
    final msg = message.message;
    if (msg == 'load') {
      _watchdog?.cancel();
      setState(() => _status = _ViewerStatus.ready);
      // Apply a thumbnail the user may have tapped while loading.
      if (_angle != ProductAngle.side) _applyAngle3D(_angle);
    } else if (msg == 'error') {
      _fail('model error');
    } else if (msg.startsWith('progress:')) {
      final value = double.tryParse(msg.substring(9)) ?? 0;
      if (_status == _ViewerStatus.loading) {
        _armWatchdog();
        setState(() => _progress = value.clamp(0, 1));
      }
    }
  }

  void _onAngleChanged() {
    if (_status == _ViewerStatus.ready) {
      _applyAngle3D(_angle);
    } else if (_status == _ViewerStatus.failed) {
      setState(() {}); // FallbackRotator animates to the new target.
    }
  }

  void _applyAngle3D(ProductAngle angle) {
    _webViewController?.runJavaScript(
      'window.setViewerAngle && window.setViewerAngle(${angle.theta}, ${angle.phi});',
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_showHint) return;
    _dragDistance += event.delta.dx.abs();
    if (_dragDistance > 12) _hideHint();
  }

  void _hideHint() {
    if (_showHint) setState(() => _showHint = false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final orbit = OrbitGeometry.of(size);
        final failed = _status == _ViewerStatus.failed;

        return Listener(
          onPointerDown: (_) => _dragDistance = 0,
          onPointerMove: _onPointerMove,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              CustomPaint(painter: OrbitPainter(drawShadow: failed)),
              if (failed)
                Positioned(
                  left: size.width * 0.1,
                  right: size.width * 0.1,
                  top: size.height * 0.06,
                  bottom: size.height - orbit.rect.center.dy + 4,
                  child: FallbackRotator(
                    image: widget.fallbackImage,
                    targetYaw: _angle.fallbackYaw,
                    targetPitch: _angle.fallbackPitch,
                    onDragStart: _hideHint,
                  ),
                )
              else
                _buildModelViewer(),
              if (!failed)
                IgnorePointer(
                  ignoring: _status == _ViewerStatus.ready,
                  child: AnimatedOpacity(
                    opacity: _status == _ViewerStatus.loading ? 1 : 0,
                    duration: const Duration(milliseconds: 450),
                    child: _LoadingShimmer(
                      image: widget.fallbackImage,
                      progress: _progress,
                      bottomInset: size.height - orbit.rect.center.dy,
                    ),
                  ),
                ),
              Positioned(
                left: orbit.bottomCenter.dx - 23,
                top: orbit.bottomCenter.dy - 13,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _showHint ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: const _DragHintPill(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModelViewer() {
    const phi = ProductAngle.defaultPhi;
    return ModelViewer(
      id: 'product-viewer',
      src: widget.modelUrl,
      alt: 'A 3D model of a sneaker',
      backgroundColor: Colors.transparent,
      loading: Loading.eager,
      cameraControls: true,
      disableZoom: true,
      disablePan: true,
      disableTap: true,
      // Lock vertical tilt: phi min == max, theta free.
      cameraOrbit: '0deg ${phi}deg 105%',
      minCameraOrbit: 'auto ${phi}deg auto',
      maxCameraOrbit: 'auto ${phi}deg auto',
      interpolationDecay: 120,
      autoRotate: true,
      autoRotateDelay: 1500,
      rotationPerSecond: '18deg',
      interactionPrompt: InteractionPrompt.none,
      shadowIntensity: 1,
      shadowSoftness: 1,
      exposure: 1.05,
      orientation: _modelOrientation,
      debugLogging: false,
      relatedCss: _relatedCss,
      relatedJs: _relatedJs,
      javascriptChannels: {
        JavascriptChannel(_channelName, onMessageReceived: _onBridgeMessage),
      },
      onWebViewCreated: (controller) => _webViewController = controller,
    );
  }

  static const _relatedCss = '''
html, body { background: transparent !important; overflow: hidden; }
model-viewer { --poster-color: transparent; --progress-bar-height: 0px; }
model-viewer::part(default-progress-bar) { display: none; }
''';

  static const _relatedJs =
      '''
(function () {
  var mv = document.querySelector('model-viewer');
  function send(m) {
    try { $_channelName.postMessage(m); } catch (_) {}
  }
  if (!mv) { send('error'); return; }

  var lastSent = -1;
  mv.addEventListener('progress', function (e) {
    var p = Math.round(e.detail.totalProgress * 100) / 100;
    if (p !== lastSent) { lastSent = p; send('progress:' + p); }
  });
  mv.addEventListener('load', function () { send('load'); });
  mv.addEventListener('error', function () { send('error'); });

  var resumeTimer = null;
  window.setViewerAngle = function (thetaDeg, phiDeg) {
    mv.autoRotate = false;
    mv.minCameraOrbit = 'auto ' + phiDeg + 'deg auto';
    mv.maxCameraOrbit = 'auto ' + phiDeg + 'deg auto';
    // Rotate the short way round from wherever auto-rotate left us.
    var twoPi = Math.PI * 2;
    var current = mv.getCameraOrbit().theta;
    var target = thetaDeg * Math.PI / 180;
    target += twoPi * Math.round((current - target) / twoPi);
    mv.cameraOrbit = target + 'rad ' + phiDeg + 'deg 105%';
    clearTimeout(resumeTimer);
    resumeTimer = setTimeout(function () { mv.autoRotate = true; }, 6000);
  };

  if (mv.loaded) send('load');
})();
''';
}

/// Black "◀ ▶" pill sitting on the orbit line.
class _DragHintPill extends StatelessWidget {
  const _DragHintPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_left_rounded, color: Colors.white, size: 18),
          Icon(Icons.arrow_right_rounded, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

/// Shoe silhouette with a moving highlight, shown while the model loads.
class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer({
    required this.image,
    required this.progress,
    required this.bottomInset,
  });

  final String image;
  final double progress;
  final double bottomInset;

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (widget.progress * 100).round();
    return ColoredBox(
      // Same grey as the hero so the WebView's own spinner stays hidden.
      color: kHeroGrey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return Stack(
            children: [
              CustomPaint(size: size, painter: const OrbitPainter()),
              Positioned(
                left: size.width * 0.14,
                right: size.width * 0.14,
                top: size.height * 0.12,
                bottom: widget.bottomInset + 10,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value * 3 - 1; // -1 .. 2
                    return ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (rect) => LinearGradient(
                        begin: Alignment(t - 1, -0.3),
                        end: Alignment(t, 0.3),
                        colors: const [
                          Color(0xFFDCDCDC),
                          Color(0xFFF7F7F7),
                          Color(0xFFDCDCDC),
                        ],
                        stops: const [0.1, 0.5, 0.9],
                      ).createShader(rect),
                      child: child,
                    );
                  },
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Image.asset(widget.image, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Text(
                  percent > 0
                      ? 'Loading 3D view… $percent%'
                      : 'Loading 3D view…',
                  textAlign: TextAlign.center,
                  style: jakarta(fontSize: 11, color: const Color(0xFF9E9E9E)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
