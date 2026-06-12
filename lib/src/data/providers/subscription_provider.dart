import 'dart:developer';

import 'package:Annujoom/src/data/models/campaign_model.dart';
import 'package:Annujoom/src/data/models/subscription_model.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/providers/campaigns_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_provider.g.dart';

const staticCampaignCategories = [
  'General Funding',
  'Zakat',
  'Orphan',
  'Widow',
  'Ghusl Mayyit',
  'Patient Relief',
  'Food Kit',
];

const subscriptionPlanTypes = [
  'WEEKLY_20',
  'WEEKLY_50',
  'WEEKLY_100',
  'MONTHLY_100',
  'MONTHLY_200',
  'MONTHLY_500',
];

class SubscriptionPlan {
  final String planType;
  final String period;
  final int amount;

  const SubscriptionPlan({
    required this.planType,
    required this.period,
    required this.amount,
  });

  bool get isWeekly => period == 'weekly';
  bool get isMonthly => period == 'monthly';

  factory SubscriptionPlan.fromPlanType(String planType) {
    final parts = planType.split('_');
    return SubscriptionPlan(
      planType: planType,
      period: parts.first.toLowerCase(),
      amount: int.parse(parts.last),
    );
  }
}

class CreateSubscriptionResponse {
  final String subscriptionId;
  final String razorpayKey;

  CreateSubscriptionResponse({
    required this.subscriptionId,
    required this.razorpayKey,
  });

  factory CreateSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionResponse(
      subscriptionId: json['subscription_id'] as String,
      razorpayKey: json['razorpay_key'] as String,
    );
  }
}

class SubscriptionApi {
  static const String _endpoint = '/subscription';

  final ApiProvider _apiProvider;

  SubscriptionApi({required ApiProvider apiProvider})
      : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> createSubscription({
    required String campaignId,
    required String planType,
  }) async {
    final payload = {
      'campaign_id': campaignId,
      'plan_type': planType,
    };
    log(
      'POST $_endpoint/create-subscription payload: $payload',
      name: 'SubscriptionApi',
    );
    return _apiProvider.post(
      '$_endpoint/create-subscription',
      payload,
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMySubscriptions() async {
    return _apiProvider.get(
      '$_endpoint/user/subscriptions',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getSubscriptionById(
    String id,
  ) async {
    return _apiProvider.get(
      '$_endpoint/user-subscription/$id',
      requireAuth: true,
    );
  }
}

@riverpod
SubscriptionApi subscriptionApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return SubscriptionApi(apiProvider: apiProvider);
}

@riverpod
List<SubscriptionPlan> subscriptionPlans(Ref ref) {
  return subscriptionPlanTypes
      .map(SubscriptionPlan.fromPlanType)
      .toList(growable: false);
}

@riverpod
Future<List<SubscriptionModel>> mySubscriptions(Ref ref) async {
  final subscriptionApi = ref.watch(subscriptionApiProvider);
  final response = await subscriptionApi.getMySubscriptions();

  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load subscriptions');
  }

  final list = response.data!['data'] as List<dynamic>?;
  if (list == null) return [];

  return list
      .map(
        (item) => SubscriptionModel.fromJson(item as Map<String, dynamic>),
      )
      .toList();
}

@riverpod
Future<SubscriptionModel> subscriptionDetail(
  Ref ref,
  String subscriptionId,
) async {
  final subscriptionApi = ref.watch(subscriptionApiProvider);
  final response = await subscriptionApi.getSubscriptionById(subscriptionId);

  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load subscription details');
  }

  final data = response.data!['data'] as Map<String, dynamic>?;
  if (data == null) {
    throw Exception('Invalid subscription details response');
  }

  return SubscriptionModel.fromJson(data);
}

@riverpod
Future<List<CampaignModel>> staticCampaignsForSubscription(Ref ref) async {
  final campaignsApi = ref.watch(campaignsApiProvider);
  final response = await campaignsApi.getAllCampaigns(
    pageNo: 1,
    limit: 100,
    myCampaigns: false,
  );

  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load campaigns');
  }

  final campaignsList = (response.data!['data'] as List<dynamic>?)
          ?.map(
            (item) => CampaignModel.fromJson(item as Map<String, dynamic>),
          )
          .toList() ??
      [];

  return campaignsList
      .where(
        (campaign) =>
            staticCampaignCategories.contains(campaign.category) &&
            campaign.status == 'active',
      )
      .toList();
}
