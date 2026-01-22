import 'dart:developer';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MswipeService {
  late WebViewController _controller;

  WebViewController initializeWebView({
    required String paymentUrl,
    required String donationId,
  }) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            
            log('Navigation request: ${request.url}, scheme: ${uri.scheme}', name: 'MswipeService');
            
            // Check if it's a UPI or other app deep link
            if (uri.scheme == 'upi' || 
                uri.scheme == 'gpay' || 
                uri.scheme == 'phonepe' || 
                uri.scheme == 'paytm' ||
                uri.scheme == 'paytmmp' ||
                uri.scheme == 'tez' ||
                uri.scheme == 'cred' ||
                uri.scheme == 'credpay') {
              log('Launching external app: ${request.url}', name: 'MswipeService');
              _launchUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            log('Mswipe page started: $url', name: 'MswipeService');
          },
          onPageFinished: (String url) {
            log('Mswipe page finished: $url', name: 'MswipeService');
            
            // iOS-specific: Inject JavaScript to intercept link clicks
            if (Platform.isIOS) {
              Future.delayed(Duration(milliseconds: 500), () {
                _injectLinkInterceptor();
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            log('Mswipe WebView error: ${error.description}, errorCode: ${error.errorCode}, errorType: ${error.errorType}',
                name: 'MswipeService');
          },
        ),
      );
    
    // Enable JavaScript console logging
    if (Platform.isIOS) {
      _controller.setOnConsoleMessage((JavaScriptConsoleMessage message) {
        log('WebView Console [${message.level.name}]: ${message.message}', name: 'MswipeService');
      });
    }
    
    _controller.loadRequest(Uri.parse(paymentUrl));

    return _controller;
  }
  
  void _injectLinkInterceptor() {
    _controller.runJavaScript('''
      (function() {
        try {
          console.log('UPI interceptor injected');
          
          // Intercept ALL clicks on the page
          document.addEventListener('click', function(e) {
            try {
              console.log('Click detected on: ' + (e.target ? e.target.tagName : 'unknown'));
              
              var target = e.target;
              
              // Check if clicked element or any parent has href or data-url
              var maxDepth = 10;
              var depth = 0;
              while (target && depth < maxDepth) {
                try {
                  var href = target.href || target.getAttribute('data-url') || target.getAttribute('data-href');
                  
                  if (href) {
                    console.log('Found href: ' + href);
                    
                    // Check if it's a UPI or payment app link
                    if (href.indexOf('upi://') >= 0 || 
                        href.indexOf('gpay://') >= 0 || 
                        href.indexOf('phonepe://') >= 0 || 
                        href.indexOf('paytm://') >= 0 ||
                        href.indexOf('paytmmp://') >= 0 ||
                        href.indexOf('tez://') >= 0 ||
                        href.indexOf('cred://') >= 0 ||
                        href.indexOf('credpay://') >= 0) {
                      console.log('UPI link detected, navigating to: ' + href);
                      e.preventDefault();
                      e.stopPropagation();
                      window.location.href = href;
                      return false;
                    }
                  }
                } catch (err) {
                  console.log('Error checking element: ' + err.message);
                }
                
                target = target.parentElement;
                depth++;
              }
            } catch (err) {
              console.log('Error in click handler: ' + err.message);
            }
          }, true);
          
          // Intercept window.open
          var originalOpen = window.open;
          window.open = function(url) {
            try {
              console.log('window.open called with: ' + url);
              if (url && (url.indexOf('upi://') >= 0 || 
                  url.indexOf('gpay://') >= 0 || 
                  url.indexOf('phonepe://') >= 0 || 
                  url.indexOf('paytm://') >= 0)) {
                window.location.href = url;
                return null;
              }
              return originalOpen.apply(this, arguments);
            } catch (err) {
              console.log('Error in window.open: ' + err.message);
              return originalOpen.apply(this, arguments);
            }
          };
          
          console.log('UPI interceptor setup complete');
        } catch (err) {
          console.log('Error setting up UPI interceptor: ' + err.message);
        }
      })();
    ''').catchError((error) {
      log('Error injecting JavaScript: $error', name: 'MswipeService');
    });
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      log('Attempting to launch: $url', name: 'MswipeService');
      
      final canLaunch = await canLaunchUrl(uri);
      log('Can launch URL: $canLaunch', name: 'MswipeService');
      
      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        log('Launch result: $launched', name: 'MswipeService');
      } else {
        log('Cannot launch URL: $url', name: 'MswipeService');
        
        // iOS fallback: Try with platformDefault mode
        if (Platform.isIOS) {
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
            log('Launched with platformDefault mode', name: 'MswipeService');
          } catch (e) {
            log('Fallback launch failed: $e', name: 'MswipeService');
          }
        }
      }
    } catch (e) {
      log('Error launching URL: $e', name: 'MswipeService');
    }
  }

  void dispose() {
    log('Mswipe service disposed', name: 'MswipeService');
  }
}
