import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';

part 'donation_provider.g.dart';

class DonationApi {
  final ApiProvider _apiProvider;

  DonationApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;
  Future<ApiResponse<Map<String, dynamic>>> createDonation({
    required String campaignId,
    required double amount,
    String currency = 'INR',
  }) async {
    final response = await _apiProvider.post(
      '/donation',
      {
        'campaign': campaignId,
        'amount': amount,
        'currency': currency,
      },
      requireAuth: true,
    );

    if (response.success) {
      log('Donation created successfully', name: 'DonationApi');
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String donationId,
  }) async {
    final response = await _apiProvider.post(
      '/donation/verify-payment',
      {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'donation_id': donationId,
      },
      requireAuth: true,
    );

    if (response.success) {
      log('Payment verified successfully', name: 'DonationApi');
    }

    return response;
  }
}

@riverpod
DonationApi donationApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return DonationApi(apiProvider: apiProvider);
}

@riverpod
class DonationNotifier extends _$DonationNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    return {};
  }

  Future<String?> createDonation({
    required String campaignId,
    required double amount,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final donationApi = ref.watch(donationApiProvider);
      final response = await donationApi.createDonation(
        campaignId: campaignId,
        amount: amount,
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          log('Order ID: ${data['payment_id']}', name: 'DonationNotifier');
          return data;
        }
        throw Exception('No order data in response');
      } else {
        throw Exception(response.message ?? 'Failed to create donation');
      }
    });

    if (state.hasValue) {
      return state.value?['payment_id'] as String?;
    }
    return null;
  }

  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String donationId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final donationApi = ref.watch(donationApiProvider);
      final response = await donationApi.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        donationId: donationId,
      );

      if (response.success) {
        log('Payment verified', name: 'DonationNotifier');
        return {'verified': true};
      } else {
        throw Exception(response.message ?? 'Failed to verify payment');
      }
    });

    return state.hasValue && (state.value?['verified'] as bool? ?? false);
  }
}
