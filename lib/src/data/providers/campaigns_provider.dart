import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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
    bool myCampaigns = false,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      if (!myCampaigns)  'status': 'active',
      if (myCampaigns) 'my_campaigns': true,
    };

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
    bool myCampaigns = false,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      if (myCampaigns) 'my_campaigns': true,
      if (search != null && search.isNotEmpty) 'search': search,
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_donationEndpoint/participated-campaigns?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMemberDonations({
    int pageNo = 1,
    int limit = 10,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_donationEndpoint/member-donations?$queryString',
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
      '$_endpoint/approve/$campaignId',
      {'action': 'approved'},
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> rejectCampaign(
    String campaignId,
    String reason,
  ) async {
    return await _apiProvider.patch(
      '$_endpoint/approve/$campaignId',
      {
        'action': 'rejected',
        'reason': reason,
      },
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

@riverpod
class MyCampaignsFilter extends _$MyCampaignsFilter {
  @override
  bool build() {
    return false; // false = Joined, true = Created
  }

  void setFilter(bool myCampaigns) {
    state = myCampaigns;
  }
}

@riverpod
class TransactionsFilter extends _$TransactionsFilter {
  @override
  bool build() {
    return false; // false = User transactions, true = Member transactions
  }

  void setFilter(bool isMemberTransactions) {
    state = isMemberTransactions;
  }
}

@riverpod
class TransactionSearch extends _$TransactionSearch {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

@riverpod
class TransactionDateFilter extends _$TransactionDateFilter {
  @override
  Map<String, String?> build() => {
        'start_date': null,
        'end_date': null,
      };

  void setDates(String? startDate, String? endDate) {
    state = {
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  void clear() {
    state = {
      'start_date': null,
      'end_date': null,
    };
  }
}

@riverpod
class CampaignCategoryFilter extends _$CampaignCategoryFilter {
  @override
  String build() {
    return 'All'; // Default to 'All' category
  }

  void setCategory(String category) {
    state = category.isEmpty ? 'All' : category;
  }
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
    final selectedCategory = ref.watch(campaignCategoryFilterProvider);

    // If category is 'All' or empty, fetch all campaigns
    if (selectedCategory == 'All' || selectedCategory.isEmpty) {
      final response = await campaignsApi.getAllCampaigns(
        pageNo: 1,
        limit: 10,
        myCampaigns: false,
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
    } else {
      // Fetch campaigns by category
      final response = await campaignsApi.getCampaignsByCategory(
        category: selectedCategory,
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
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;
    state = await AsyncValue.guard(() async {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final selectedCategory = ref.watch(campaignCategoryFilterProvider);
      final nextPage = currentState.currentPage + 1;

      late final ApiResponse<Map<String, dynamic>> response;
      if (selectedCategory == 'All' || selectedCategory.isEmpty) {
        response = await campaignsApi.getAllCampaigns(
          pageNo: nextPage,
          limit: currentState.limit,
          myCampaigns: false,
        );
      } else {
        response = await campaignsApi.getCampaignsByCategory(
          category: selectedCategory,
          pageNo: nextPage,
          limit: currentState.limit,
        );
      }

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

@riverpod
class CreatedCampaignsNotifier extends _$CreatedCampaignsNotifier {
  @override
  Future<CampaignPaginationState> build() async {
    final campaignsApi = ref.watch(campaignsApiProvider);

    final response = await campaignsApi.getAllCampaigns(
      pageNo: 1,
      limit: 10,
      myCampaigns: true,
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
      throw Exception(response.message ?? 'Failed to fetch created campaigns');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;
    state = await AsyncValue.guard(() async {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await campaignsApi.getAllCampaigns(
        pageNo: nextPage,
        limit: currentState.limit,
        myCampaigns: true,
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
        throw Exception(response.message ?? 'Failed to load more created campaigns');
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
    final search = ref.watch(transactionSearchProvider);
    final dates = ref.watch(transactionDateFilterProvider);

    final response = await campaignsApi.getParticipatedCampaigns(
      pageNo: 1,
      limit: 10,
      search: search,
      startDate: dates['start_date'],
      endDate: dates['end_date'],
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
    state = await AsyncValue.guard(() async {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final search = ref.read(transactionSearchProvider);
      final dates = ref.read(transactionDateFilterProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await campaignsApi.getParticipatedCampaigns(
        pageNo: nextPage,
        limit: currentState.limit,
        search: search,
        startDate: dates['start_date'],
        endDate: dates['end_date'],
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
class MemberDonationsNotifier extends _$MemberDonationsNotifier {
  @override
  Future<DonationPaginationState> build() async {
    final campaignsApi = ref.watch(campaignsApiProvider);
    final search = ref.watch(transactionSearchProvider);
    final dates = ref.watch(transactionDateFilterProvider);

    final response = await campaignsApi.getMemberDonations(
      pageNo: 1,
      limit: 10,
      search: search,
      startDate: dates['start_date'],
      endDate: dates['end_date'],
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
      throw Exception(response.message ?? 'Failed to fetch member donations');
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;
    state = await AsyncValue.guard(() async {
      final campaignsApi = ref.watch(campaignsApiProvider);
      final search = ref.read(transactionSearchProvider);
      final dates = ref.read(transactionDateFilterProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await campaignsApi.getMemberDonations(
        pageNo: nextPage,
        limit: currentState.limit,
        search: search,
        startDate: dates['start_date'],
        endDate: dates['end_date'],
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
        throw Exception(response.message ?? 'Failed to load more member donations');
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
