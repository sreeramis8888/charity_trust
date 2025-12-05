import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/services/razorpay_service.dart';

part 'razorpay_provider.g.dart';

// Keep a singleton instance to prevent disposal during payment flow
RazorpayService? _razorpayServiceInstance;

@riverpod
RazorpayService razorpayService(Ref ref) {
  // Reuse existing instance if available
  if (_razorpayServiceInstance != null) {
    log('Reusing existing Razorpay service instance', name: 'razorpayProvider');
    return _razorpayServiceInstance!;
  }

  log('Creating new Razorpay service instance', name: 'razorpayProvider');
  final service = RazorpayService();
  _razorpayServiceInstance = service;
  
  ref.onDispose(() {
    log('Razorpay provider disposed', name: 'razorpayProvider');
    // Don't dispose immediately, keep it alive for payment callbacks
    // service.dispose();
  });
  
  return service;
}
