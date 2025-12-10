import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/models/campaign_model.dart';
import 'package:Annujoom/src/data/models/donation_model.dart';

part 'campaigns_provider.g.dart';

class CampaignsApi {
  static const String _endpoint = '/campaign';
  static const String _donationEndpoint = '/donation';

  final ApiProvider _apiProvider;

  CampaignsApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> getAllCampaigns({
    int pageNo = 1,
    int limit = 10,
  }) async {
    final queryParams = {'page_no': pageNo, 'limit': limit, 'status': 'active'};

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_endpoint?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCampaignsByCategory({
    required String category,
    int pageNo = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      'category': category,
      'status': 'active'
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_endpoint?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getParticipatedCampaigns({
    int pageNo = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_donationEndpoint/participated-campaigns?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPendingApprovalCampaigns({
    int pageNo = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      'approval_status': 'pending',
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_endpoint?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> approveCampaign(
    String campaignId,
  ) async {
    return await _apiProvider.patch(
      '$_endpoint/$campaignId/approve',
      {},
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> rejectCampaign(
    String campaignId,
    String reason,
  ) async {
    return await _apiProvider.patch(
      '$_endpoint/$campaignId/reject',
      {'reason': reason},
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createCampaign(
    Map<String, dynamic> campaignData,
  ) async {
    return await _apiProvider.post(
      _endpoint,
      campaignData,
      requireAuth: true,
    );
  }
}

@riverpod
CampaignsApi campaignsApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return CampaignsApi(apiProvider: apiProvider);
}

class CampaignPaginationState {
  final int currentPage;
  final int limit;
  final int totalCount;
  final List<CampaignModel> campaigns;
  final bool hasMore;

  CampaignPaginationState({
    required this.currentPage,
    required this.limit,
    required this.totalCount,
    required this.campaigns,
  }) : hasMore = (currentPage * limit) < totalCount;

  CampaignPaginationState copyWith({
    int? currentPage,
    int? limit,
    int? totalCount,
    List<CampaignModel>? campaigns,
  }) {
    return CampaignPaginationState(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      campaigns: campaigns ?? this.campaigns,
    );
  }
}

@riverpod
class GeneralCampaignsNotifier extends _$GeneralCampaignsNotifier {
  @override
  Future<CampaignPaginationState> build() async {
    final campaignsApi = ref.watch(campaignsApiProvider);
    final response = await campaignsApi.getAllCampaigns(
      pageNo: 1,
      limit: 10,
    );

    if (response.success && response.data != null) {
      final campaignsList = (response.data!['data'] as List<dynamic>?)
              ?.map((item) =>
                  CampaignModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final totalCountValue = response.data!['total_count'];
      final totalCount = totalCountValue is int
          ? totalCountValue
          : int.tryParse(totalCountValue.toString()) ?? 0;

      return CampaignPaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: totalCount,
        campaigns: campaignsList,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch campaigns');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await campaignsApi.getAllCampaigns(
        pageNo: nextPage,
        limit: currentState.limit,
      );

      if (response.success && response.data != null) {
        final campaignsList = (response.data!['data'] as List<dynamic>?)
                ?.map((item) =>
                    CampaignModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final totalCountValue = response.data!['total_count'];
        final totalCount = totalCountValue is int
            ? totalCountValue
            : int.tryParse(totalCountValue.toString()) ?? 0;

        return currentState.copyWith(
          currentPage: nextPage,
          totalCount: totalCount,
          campaigns: [...currentState.campaigns, ...campaignsList],
        );
      } else {
        throw Exception(response.message ?? 'Failed to load more campaigns');
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

class DonationPaginationState {
  final int currentPage;
  final int limit;
  final int totalCount;
  final List<DonationModel> donations;
  final bool hasMore;

  DonationPaginationState({
    required this.currentPage,
    required this.limit,
    required this.totalCount,
    required this.donations,
  }) : hasMore = (currentPage * limit) < totalCount;

  DonationPaginationState copyWith({
    int? currentPage,
    int? limit,
    int? totalCount,
    List<DonationModel>? donations,
  }) {
    return DonationPaginationState(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      donations: donations ?? this.donations,
    );
  }
}

@riverpod
class ParticipatedCampaignsNotifier extends _$ParticipatedCampaignsNotifier {
  @override
  Future<DonationPaginationState> build() async {
    final campaignsApi = ref.watch(campaignsApiProvider);
    final response = await campaignsApi.getParticipatedCampaigns(
      pageNo: 1,
      limit: 10,
    );

    if (response.success && response.data != null) {
      final donationsList = (response.data!['data'] as List<dynamic>?)
              ?.map((item) =>
                  DonationModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final totalCountValue = response.data!['total_count'];
      final totalCount = totalCountValue is int
          ? totalCountValue
          : int.tryParse(totalCountValue.toString()) ?? 0;

      return DonationPaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: totalCount,
        donations: donationsList,
      );
    } else {
      throw Exception(
          response.message ?? 'Failed to fetch participated campaigns');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await campaignsApi.getParticipatedCampaigns(
        pageNo: nextPage,
        limit: currentState.limit,
      );

      if (response.success && response.data != null) {
        final donationsList = (response.data!['data'] as List<dynamic>?)
                ?.map((item) =>
                    DonationModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final totalCountValue = response.data!['total_count'];
        final totalCount = totalCountValue is int
            ? totalCountValue
            : int.tryParse(totalCountValue.toString()) ?? 0;

        return currentState.copyWith(
          currentPage: nextPage,
          totalCount: totalCount,
          donations: [...currentState.donations, ...donationsList],
        );
      } else {
        throw Exception(response.message ?? 'Failed to load more donations');
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

@riverpod
Future<CampaignModel?> createNewCampaign(
  Ref ref,
  Map<String, dynamic> campaignData,
) async {
  try {
    final campaignsApi = ref.watch(campaignsApiProvider);
    final response = await campaignsApi.createCampaign(campaignData);

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      if (data != null) {
        return CampaignModel.fromJson(data);
      }
    }
    return null;
  } catch (e) {
    throw Exception('Error creating campaign: $e');
  }
}

@riverpod
class PendingApprovalCampaignsNotifier
    extends _$PendingApprovalCampaignsNotifier {
  @override
  Future<CampaignPaginationState> build() async {
    final campaignsApi = ref.watch(campaignsApiProvider);
    final response = await campaignsApi.getPendingApprovalCampaigns(
      pageNo: 1,
      limit: 10,
    );

    if (response.success && response.data != null) {
      final campaignsList = (response.data!['data'] as List<dynamic>?)
              ?.map((item) =>
                  CampaignModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final totalCountValue = response.data!['total_count'];
      final totalCount = totalCountValue is int
          ? totalCountValue
          : int.tryParse(totalCountValue.toString()) ?? 0;

      return CampaignPaginationState(
        currentPage: 1,
        limit: 10,
        totalCount: totalCount,
        campaigns: campaignsList,
      );
    } else {
      throw Exception(
          response.message ?? 'Failed to fetch pending approval campaigns');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await campaignsApi.getPendingApprovalCampaigns(
        pageNo: nextPage,
        limit: currentState.limit,
      );

      if (response.success && response.data != null) {
        final campaignsList = (response.data!['data'] as List<dynamic>?)
                ?.map((item) =>
                    CampaignModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final totalCountValue = response.data!['total_count'];
        final totalCount = totalCountValue is int
            ? totalCountValue
            : int.tryParse(totalCountValue.toString()) ?? 0;

        return currentState.copyWith(
          currentPage: nextPage,
          totalCount: totalCount,
          campaigns: [...currentState.campaigns, ...campaignsList],
        );
      } else {
        throw Exception(
            response.message ?? 'Failed to load more pending campaigns');
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<bool> approveCampaign(String campaignId) async {
    try {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final response = await campaignsApi.approveCampaign(campaignId);
      if (response.success) {
        await refresh();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectCampaign(String campaignId, String reason) async {
    try {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final response = await campaignsApi.rejectCampaign(campaignId, reason);
      if (response.success) {
        await refresh();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

@riverpod
Future<CampaignPaginationState> categoryCampaigns(
  Ref ref,
  String category,
) async {
  final campaignsApi = ref.watch(campaignsApiProvider);
  final response = await campaignsApi.getCampaignsByCategory(
    category: category,
    pageNo: 1,
    limit: 10,
  );

  if (response.success && response.data != null) {
    final campaignsList = (response.data!['data'] as List<dynamic>?)
            ?.map(
                (item) => CampaignModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    final totalCountValue = response.data!['total_count'];
    final totalCount = totalCountValue is int
        ? totalCountValue
        : int.tryParse(totalCountValue.toString()) ?? 0;

    return CampaignPaginationState(
      currentPage: 1,
      limit: 10,
      totalCount: totalCount,
      campaigns: campaignsList,
    );
  } else {
    throw Exception(response.message ?? 'Failed to fetch campaigns');
  }
}
