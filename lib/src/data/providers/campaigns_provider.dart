import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/providers/api_provider.dart';
import 'package:charity_trust/src/data/models/campaign_model.dart';

part 'campaigns_provider.g.dart';

class CampaignsApi {
  static const String _endpoint = '/campaign';

  final ApiProvider _apiProvider;

  CampaignsApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> getCampaignsForUser({
    int pageNo = 1,
    int limit = 10,
    String? type,
  }) async {
    final queryParams = {
      'page_no': pageNo,
      'limit': limit,
      if (type != null) 'type': type,
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await _apiProvider.get(
      '$_endpoint/user?$queryString',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getAllCampaigns({
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
      '$_endpoint?$queryString',
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
      final campaignsList =
          (response.data!['data'] as List<dynamic>?)
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
        final campaignsList =
            (response.data!['data'] as List<dynamic>?)
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
class MyCampaignsNotifier extends _$MyCampaignsNotifier {
  List<CampaignModel> _generateDummyCampaigns(int count) {
    return List.generate(
      count,
      (index) => CampaignModel(
        id: 'my_campaign_${index + 1}',
        title: 'My Campaign ${index + 1}',
        description: 'This is my campaign for helping communities in need.',
        category: 'Funding Campaigns',
        targetAmount: (150000.0 + (index * 50000)).toInt(),
        collectedAmount: (75000.0 + (index * 25000)).toInt(),
        targetDate: DateTime.now().add(Duration(days: 30 + (index * 10))),
        coverImage: 'https://picsum.photos/id/${237 + index}/200/300',
      ),
    );
  }

  @override
  Future<CampaignPaginationState> build() async {
    final dummyCampaigns = _generateDummyCampaigns(10);

    return CampaignPaginationState(
      currentPage: 1,
      limit: 10,
      totalCount: 25,
      campaigns: dummyCampaigns,
    );
  }

  Future<void> loadNextPage() async {
    if (!state.hasValue) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final startIndex = (nextPage - 1) * currentState.limit;
      final dummyCampaigns = _generateDummyCampaigns(
        currentState.limit,
      ).asMap().entries.map((entry) {
        final campaign = entry.value;
        return campaign.copyWith(
          id: 'my_campaign_${startIndex + entry.key + 1}',
          title: 'My Campaign ${startIndex + entry.key + 1}',
        );
      }).toList();

      return currentState.copyWith(
        currentPage: nextPage,
        campaigns: [...currentState.campaigns, ...dummyCampaigns],
      );
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
