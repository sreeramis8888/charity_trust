import 'dart:io';

class AppVersionResponse {
  final int version;
  final bool force;
  final String applink;
  final String updateMessage;
  final bool? isPaymentEnabled;
  final bool? isMswipeEnabled;
  final bool? isRazorpayEnabled;
  final bool? isEasebuzzEnabled;

  AppVersionResponse({
    required this.version,
    required this.force,
    required this.applink,
    required this.updateMessage,
    this.isPaymentEnabled,
    this.isMswipeEnabled,
    this.isRazorpayEnabled,
    this.isEasebuzzEnabled,
  });

  factory AppVersionResponse.fromJson(Map<String, dynamic> json) {
    final customer = json['data']['application']['customer'];
    final platform = customer[Platform.isIOS ? 'ios' : 'android'];
    return AppVersionResponse(
      version: platform['version'],
      force: platform['force'],
      applink: platform['applink'],
      updateMessage: platform['updateMessage'],
      isPaymentEnabled: platform['paymentEnabled'],
      isMswipeEnabled: platform['mswipe_enabled'],
      isRazorpayEnabled: platform['razorpay_enabled'],
      isEasebuzzEnabled: platform['easebuzz_enabled'],
    );
  }
}
