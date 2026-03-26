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
    String gateway = 'razorpay',
    // String? email,
    String? phone,
  }) async {
    final payload = {
      'campaign': campaignId,
      'amount': amount,
      'currency': currency,
      'gateway': gateway,
    };

    // Add email and phone for Mswipe gateway
    if (gateway == 'mswipe') {
      // if (email != null) payload['email'] = email;
      if (phone != null) payload['phone'] = phone;
    }

    // Debug log: request body being sent to createDonation API
    log(
      'POST /donation payload: $payload',
      name: 'DonationApi',
    );

    final response = await _apiProvider.post(
      '/donation',
      payload,
      requireAuth: true,
    );

    if (response.success) {
      log('Donation created successfully with gateway: $gateway',
          name: 'DonationApi');
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String donationId,
    required String status,
  }) async {
    final response = await _apiProvider.post(
      '/donation/verify-payment',
      {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'donation_id': donationId,
        'status': status,
      },
      requireAuth: true,
    );

    if (response.success) {
      log('Payment verified successfully', name: 'DonationApi');
    }

    return response;
  }

  //Easebuzz
  Future<ApiResponse<Map<String, dynamic>>> fetchEasebuzzPaymentDetails({
    required String transactionId,
  }) async {
    final response = await _apiProvider.get(
      '/donation/easebuzz-payment-details/$transactionId',
      requireAuth: true,
    );

    if (response.success) {
      log('Easebuzz payment details fetched successfully',
          name: 'DonationApi');
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyEasebuzzPayment({
    required String transactionId,
    required String hash,
    required double amount,
    required String productInfo,
    required String firstName,
    required String email, // Changed to required as per backend validation
    required String status,
    required String key, // [NEW] Required by backend validation
  }) async {
    final response = await _apiProvider.post(
      '/donation/easebuzz-verify',
      {
        'txnid': transactionId,
        'hash': hash,
        'amount': amount,
        'productinfo': productInfo,
        'firstname': firstName,
        'email': email,
        'status': status,
        'key': key, // [NEW] Added to payload
      },
      requireAuth: true,
    );

    if (response.success) {
      log('Easebuzz payment verified successfully', name: 'DonationApi');
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
    required String status,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final donationApi = ref.watch(donationApiProvider);
      final response = await donationApi.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        donationId: donationId,
        status: status,
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

  // [NEW] Added wrapper for Easebuzz verification
  Future<bool> verifyEasebuzzPayment({
    required String transactionId,
    required String hash,
    required double amount,
    required String productInfo,
    required String firstName,
    required String email,
    required String status,
    required String key,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final donationApi = ref.watch(donationApiProvider);
      final response = await donationApi.verifyEasebuzzPayment(
        transactionId: transactionId,
        hash: hash,
        amount: amount,
        productInfo: productInfo,
        firstName: firstName,
        email: email,
        status: status,
        key: key,
      );

      if (response.success) {
        log('Easebuzz Payment verified', name: 'DonationNotifier');
        return {'verified': true};
      } else {
        throw Exception(
            response.message ?? 'Failed to verify Easebuzz payment');
      }
    });

    return state.hasValue && (state.value?['verified'] as bool? ?? false);
  }

  Future<Map<String, dynamic>?> fetchEasebuzzPaymentDetails({
    required String transactionId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final donationApi = ref.watch(donationApiProvider);
      final response = await donationApi.fetchEasebuzzPaymentDetails(
        transactionId: transactionId,
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          log('Easebuzz payment details fetched', name: 'DonationNotifier');
          return data;
        }
        throw Exception('No donation data in response');
      } else {
        throw Exception(
            response.message ?? 'Failed to fetch Easebuzz payment details');
      }
    });

    if (state.hasValue) {
      return state.value;
    }
    return null;
  }
}
