import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';

String? extractYouTubeVideoId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return null;

  final host = uri.host.replaceFirst('www.', '');

  // Handle: https://www.youtube.com/watch?v=VIDEO_ID
  if (host.contains('youtube.com') && uri.path == '/watch') {
    return uri.queryParameters['v'];
  }

  // Handle: https://youtu.be/VIDEO_ID
  if (host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }

  // Handle: https://www.youtube.com/embed/VIDEO_ID
  if (host.contains('youtube.com') &&
      uri.pathSegments.isNotEmpty &&
      uri.pathSegments.first == 'embed') {
    return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
  }

  // Handle: https://www.youtube.com/shorts/VIDEO_ID
  if (host.contains('youtube.com') &&
      uri.pathSegments.isNotEmpty &&
      uri.pathSegments.first == 'shorts') {
    return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
  }

  return null;
}

class YouTubePlayerWidget extends StatefulWidget {
  final String videoId;

  const YouTubePlayerWidget({Key? key, required this.videoId})
      : super(key: key);

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  InAppWebViewController? webViewController;
  bool isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(
              'https://www.youtube.com/embed/${widget.videoId}?playsinline=1&enablejsapi=1&origin=https://flutter.dev'),
        ),
        initialSettings: InAppWebViewSettings(
          // iOS specific settings
          iframeAllowFullscreen: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          allowsAirPlayForMediaPlayback: Platform.isIOS,
          allowsPictureInPictureMediaPlayback: Platform.isIOS,

          // General settings
          javaScriptEnabled: true,
          domStorageEnabled: true,
          useOnDownloadStart: true,
          useOnLoadResource: true,
          useShouldOverrideUrlLoading: true,

          // iOS specific additional settings
          suppressesIncrementalRendering: Platform.isIOS ? false : null,
          sharedCookiesEnabled: Platform.isIOS ? true : null,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;

          // Add JavaScript to handle fullscreen
          controller.addJavaScriptHandler(
            handlerName: 'fullscreenHandler',
            callback: (args) {
              setState(() {
                isFullscreen = !isFullscreen;
              });

              if (isFullscreen) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              } else {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                    overlays: SystemUiOverlay.values);
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
            },
          );
        },
        onLoadStart: (controller, url) async {
          // iOS specific: Set user agent to avoid mobile restrictions
          if (Platform.isIOS) {
            await controller.setSettings(
                settings: InAppWebViewSettings(
              userAgent:
                  'Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
            ));
          }
        },
        onLoadStop: (controller, url) async {
          // Inject JavaScript to detect fullscreen changes and handle iOS specifics
          await controller.evaluateJavascript(source: '''
            // Fullscreen detection
            document.addEventListener('fullscreenchange', function() {
              window.flutter_inappwebview.callHandler('fullscreenHandler');
            });
            
            document.addEventListener('webkitfullscreenchange', function() {
              window.flutter_inappwebview.callHandler('fullscreenHandler');
            });
            
            // iOS specific: Force inline playback
            var videos = document.querySelectorAll('video');
            videos.forEach(function(video) {
              video.setAttribute('playsinline', '');
              video.setAttribute('webkit-playsinline', '');
            });
            
            // iOS specific: Remove any iOS-specific restrictions
            if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
              document.head.appendChild(meta);
            }
          ''');
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          // Handle SSL certificate for YouTube and Google domains
          var host = challenge.protectionSpace.host;
          if (host.contains('youtube.com') ||
              host.contains('googlevideo.com') ||
              host.contains('googleusercontent.com') ||
              host.contains('ytimg.com')) {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          }
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.CANCEL);
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url!;

          // Allow YouTube domains
          if (uri.host.contains('youtube.com') ||
              uri.host.contains('youtu.be') ||
              uri.host.contains('googlevideo.com')) {
            return NavigationActionPolicy.ALLOW;
          }

          return NavigationActionPolicy.CANCEL;
        },
        onConsoleMessage: (controller, consoleMessage) {
          // Debug console messages (remove in production)
          print('Console: ${consoleMessage.message}');
        },
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}
