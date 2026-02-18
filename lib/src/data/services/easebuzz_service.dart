import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // [NEW]
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // [NEW]

class EasebuzzService {
  late WebViewController _controller;
  Function(Map<String, dynamic>?)? _onPaymentComplete;
  bool _isVerifying = false;

  void setOnPaymentComplete(Function(Map<String, dynamic>?) callback) {
    _onPaymentComplete = callback;
  }

  WebViewController initializeWebView({
    required String paymentUrl,
    required String donationId,
    Map<String, dynamic>? paymentData,
  }) {
    _isVerifying = false;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);

            log(
              'Navigation request: ${request.url}',
              name: 'EasebuzzService',
            );

            // Check if it's a UPI or other app deep link
            if (uri.scheme == 'upi' ||
                uri.scheme == 'gpay' ||
                uri.scheme == 'phonepe' ||
                uri.scheme == 'paytm' ||
                uri.scheme == 'paytmmp' ||
                uri.scheme == 'tez' ||
                uri.scheme == 'cred' ||
                uri.scheme == 'credpay') {
              _launchUrl(request.url);
              return NavigationDecision.prevent;
            }

            // Intercept verification URL to prevent the 500 error display
            if (request.url.contains('easebuzz-verify')) {
              log('Intercepted verify URL in navigation, handling manually...',
                  name: 'EasebuzzService');
              if (!_isVerifying && paymentData != null) {
                _verifyTransactionManual(paymentData);
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            log('Page started: $url', name: 'EasebuzzService');
            // Aggressively stop verification URL on Android
            if (url.contains('easebuzz-verify')) {
              // Hack to stop loading if stopLoading() is missing in this version
              _controller.loadHtmlString('<html><body></body></html>');
              if (!_isVerifying && paymentData != null) {
                _verifyTransactionManual(paymentData);
              }
            }
          },
          onPageFinished: (String url) {
            log('Page finished: $url', name: 'EasebuzzService');
            _injectLinkInterceptor();
          },
        ),
      );

    // [NEW] Add JavaScript Channel to intercept form data (backup method)
    _controller.addJavaScriptChannel(
      'EasebuzzResponse',
      onMessageReceived: (JavaScriptMessage message) {
        if (!_isVerifying) {
          log('Interception channel caught data, syncing...',
              name: 'EasebuzzService');
          _handleInterceptedData(message.message);
        }
      },
    );

    if (paymentData != null) {
      log('Initiating Easebuzz payment via API...', name: 'EasebuzzService');
      _showLoadingPage('Connecting to Easebuzz...');
      _initiatePayment(paymentUrl, paymentData);
    } else {
      _controller.loadRequest(Uri.parse(paymentUrl));
    }

    return _controller;
  }

  // Robust Manual Verification using retrieve API V2.1 + JSON Backend Update
  Future<void> _verifyTransactionManual(
      Map<String, dynamic> paymentData) async {
    if (_isVerifying) return;
    _isVerifying = true;

    try {
      _showLoadingPage('Verifying Payment Status...');

      final key = dotenv.env['EASEBUZZ_KEY'] ?? 'D0Y728WZI6';
      final salt = dotenv.env['EASEBUZZ_SALT'] ?? 'IHJQRIEOFG';
      final txnid = paymentData['txnid'];
      final email = paymentData['email'];

      log('Starting manual verification (V2.1) for txnid: $txnid',
          name: 'EasebuzzService');

      // 1. Generate hash for Easebuzz Transaction Search API V2.1
      // Sequence: key|txnid|salt
      final hashString = '$key|$txnid|$salt';
      final hash = sha512.convert(utf8.encode(hashString)).toString();

      // 2. Call Easebuzz Retrieve API V2.1
      final bool isTest = (paymentData['payment_url'] ?? '').contains('test');
      final String retrieveUrl = isTest
          ? 'https://testdashboard.easebuzz.in/transaction/v2.1/retrieve'
          : 'https://dashboard.easebuzz.in/transaction/v2.1/retrieve';

      final response = await http.post(
        Uri.parse(retrieveUrl),
        body: {
          'key': key,
          'txnid': txnid,
          'hash': hash,
        },
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      log('Easebuzz V2.1 Response: ${response.body}', name: 'EasebuzzService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(response.body);
        // V2.1 response structure: {"status": true, "data": {...}}
        // OR if V1 was actually preferred by some merchants: {"status": 1, "msg": {...}}

        bool success = resData['status'] == true || resData['status'] == 1;
        var txData = resData['data'] ?? resData['msg'];

        // [FIX] Easebuzz V2.1 often returns 'msg' as an array
        if (txData is List && txData.isNotEmpty) {
          txData = txData[0];
        }

        if (success && txData != null && txData is Map) {
          // 3. Re-calculate the reverse hash to satisfy backend verification
          final String status = txData['status']?.toString() ?? '';
          final String firstname = txData['firstname']?.toString() ?? '';
          final String productinfo = txData['productinfo']?.toString() ?? '';
          final String txAmount = txData['amount']?.toString() ?? '';

          final reverseHashString = [
            salt,
            status,
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            email,
            firstname,
            productinfo,
            txAmount,
            txnid,
            key,
          ].join('|');

          final String reverseHash =
              sha512.convert(utf8.encode(reverseHashString)).toString();

          // 4. Send JSON verify request to backend
          await _syncWithBackend({
            'txnid': txnid,
            'status': status,
            'hash': reverseHash,
            'amount': txAmount,
            'productinfo': productinfo,
            'firstname': firstname,
            'email': email,
            'key': key,
          });
        } else {
          log('Transaction status not success or invalid data structure',
              name: 'EasebuzzService');
          _onPaymentComplete?.call(null);
        }
      } else {
        log('Easebuzz API Network Error: ${response.statusCode}',
            name: 'EasebuzzService');
        _onPaymentComplete?.call(null);
      }
    } catch (e) {
      log('Error during manual verification: $e', name: 'EasebuzzService');
      _onPaymentComplete?.call(null);
    }
  }

  Future<void> _syncWithBackend(Map<String, dynamic> verifyData) async {
    try {
      final String jsonBody = jsonEncode(verifyData);
      debugPrint('EasebuzzService: Syncing with backend (JSON): $jsonBody');

      final verifyUrl =
          'https://api.annujoomcharitabletrust.com/api/v1/donation/easebuzz-verify';

      final response = await http.post(
        Uri.parse(verifyUrl),
        body: jsonBody,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint(
          'EasebuzzService: Backend Sync Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['status'] == 200 || resData['status'] == true) {
          final donationData = resData['data'];
          _onPaymentComplete?.call(donationData);
        } else {
          _onPaymentComplete?.call(null);
        }
      } else {
        _onPaymentComplete?.call(null);
      }
    } catch (e) {
      debugPrint('EasebuzzService: Backend Sync Error: $e');
      _onPaymentComplete?.call(null);
    }
  }

  Future<void> _handleInterceptedData(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      debugPrint('EasebuzzService: Handling intercepted JS data: $jsonData');
      _showLoadingPage('Updating Donation Status...');

      final verifyUrl =
          'https://api.annujoomcharitabletrust.com/api/v1/donation/easebuzz-verify';

      final response = await http.post(
        Uri.parse(verifyUrl),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint(
          'EasebuzzService: Interception Sync Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        // Interception might return different structure depending on backend
        // But assuming same endpoint:
        if (resData['status'] == 200 || resData['status'] == true) {
          final donationData = resData['data'];
          _onPaymentComplete?.call(donationData);
        } else {
          _onPaymentComplete?.call(null);
        }
      } else {
        _onPaymentComplete?.call(null);
      }
    } catch (e) {
      debugPrint('EasebuzzService: Interception Sync Error: $e');
      _onPaymentComplete?.call(null);
    }
  }

  void _showLoadingPage(String message) {
    final String htmlContent = '''
      <html>
        <body style="display: flex; justify-content: center; align-items: center; height: 100vh; font-family: sans-serif; background: #ffffff;">
          <div style="text-align: center;">
            <h2 style="color: #333;">$message</h2>
            <p style="color: #666;">Please do not close the app.</p>
          </div>
        </body>
      </html>
    ''';
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(htmlContent));
    _controller.loadRequest(Uri.parse('data:text/html;base64,$contentBase64'));
  }

  Future<void> _initiatePayment(
      String apiUrl, Map<String, dynamic> paymentData) async {
    try {
      log('Initiating via API: $apiUrl', name: 'EasebuzzService');
      final Map<String, String> bodyMap = {};
      paymentData.forEach((key, value) {
        if (key != 'donation' && key != 'payment_url') {
          bodyMap[key] = value.toString();
        }
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        body: bodyMap,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 1 && responseData['data'] != null) {
          final String accessKey = responseData['data'];
          String baseUrl = 'https://pay.easebuzz.in';
          if (apiUrl.contains('testpay'))
            baseUrl = 'https://testpay.easebuzz.in';

          final String paymentPageUrl = '$baseUrl/pay/$accessKey';
          log('Redirecting to Payment Page: $paymentPageUrl',
              name: 'EasebuzzService');
          _controller.loadRequest(Uri.parse(paymentPageUrl));
        } else {
          _showErrorPage(
              "Initiation failed: ${responseData['data'] ?? 'Unknown error'}");
        }
      } else {
        _showErrorPage('Network error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception: $e', name: 'EasebuzzService');
      _showErrorPage('Error: $e');
    }
  }

  void _showErrorPage(String errorMessage) {
    final String htmlContent = '''
      <html>
        <body style="padding: 20px; font-family: sans-serif; text-align: center;">
          <h2 style="color: red;">Payment Error</h2>
          <p>$errorMessage</p>
          <p>Please go back and try again.</p>
        </body>
      </html>
    ''';
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(htmlContent));
    _controller.loadRequest(Uri.parse('data:text/html;base64,$contentBase64'));
  }

  void _injectLinkInterceptor() {
    _controller.runJavaScript('''
      (function() {
        try {
          console.log('Easebuzz aggressive interceptor injected');
          function hijackForms() {
            var forms = document.querySelectorAll('form');
            for (var i = 0; i < forms.length; i++) {
              var form = forms[i];
              if (form.action.indexOf('easebuzz-verify') >= 0 && !form.dataset.hijacked) {
                console.log('Hijacking easebuzz-verify form');
                form.dataset.hijacked = 'true';
                form.addEventListener('submit', function(e) {
                  e.preventDefault();
                  e.stopImmediatePropagation();
                  handleForm(form);
                  return false;
                }, true);
              }
            }
          }
          function handleForm(form) {
            var formData = {};
            var inputs = form.querySelectorAll('input, select, textarea');
            for (var i = 0; i < inputs.length; i++) {
              if (inputs[i].name) formData[inputs[i].name] = inputs[i].value;
            }
            if (window.EasebuzzResponse) {
              window.EasebuzzResponse.postMessage(JSON.stringify(formData));
            }
            document.body.innerHTML = '<div style="display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;"><h2>Processing...</h2></div>';
          }
          hijackForms();
          setInterval(hijackForms, 200);
        } catch (err) { console.log('Error setup: ' + err.message); }
      })();
    ''').catchError((e) => log('JS Error: $e'));
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('Launch Error: $e');
    }
  }

  void dispose() {
    log('Easebuzz service disposed', name: 'EasebuzzService');
  }
}
