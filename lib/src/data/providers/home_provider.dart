import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:Annujoom/src/data/models/campaign_model.dart';
import 'package:Annujoom/src/data/models/promotions_model.dart';
import 'package:Annujoom/src/data/models/news_model.dart';

part 'home_provider.g.dart';

class HomeApi {
  static const String _endpoint = '/home';

  final ApiProvider _apiProvider;

  HomeApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> getHomeData() async {
    return await _apiProvider.get(
      _endpoint,
      requireAuth: true,
    );
  }
}

@riverpod
HomeApi homeApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return HomeApi(apiProvider: apiProvider);
}

class HomePageData {
  final List<CampaignModel> endingCampaigns;
  final List<NewsModel> latestNews;
  final List<Promotions> posterPromotions;
  final List<Promotions> videoPromotions;
  final int referralsReceived;
  final int pendingReferrals;

  HomePageData({
    required this.endingCampaigns,
    required this.latestNews,
    required this.posterPromotions,
    required this.videoPromotions,
    required this.referralsReceived,
    required this.pendingReferrals,
  });

  HomePageData copyWith({
    List<CampaignModel>? endingCampaigns,
    List<NewsModel>? latestNews,
    List<Promotions>? posterPromotions,
    List<Promotions>? videoPromotions,
    int? referralsReceived,
    int? pendingReferrals,
  }) {
    return HomePageData(
      endingCampaigns: endingCampaigns ?? this.endingCampaigns,
      latestNews: latestNews ?? this.latestNews,
      posterPromotions: posterPromotions ?? this.posterPromotions,
      videoPromotions: videoPromotions ?? this.videoPromotions,
      referralsReceived: referralsReceived ?? this.referralsReceived,
      pendingReferrals: pendingReferrals ?? this.pendingReferrals,
    );
  }
}

@riverpod
Future<HomePageData> homePageData(Ref ref) async {
  final homeApi = ref.watch(homeApiProvider);
  final response = await homeApi.getHomeData();

  if (response.success && response.data != null) {
    final data = response.data!['data'] as Map<String, dynamic>?;

    final endingCampaigns = (data?['ending_campaign'] as List<dynamic>?)
            ?.map((item) => CampaignModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final latestNews = (data?['latest_news'] as List<dynamic>?)
            ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final posterPromotions = (data?['poster_promotion'] as List<dynamic>?)
            ?.map((item) => Promotions.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final videoPromotions = (data?['video_promotion'] as List<dynamic>?)
            ?.map((item) => Promotions.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final referralsReceived = data?['referrals_received'] as int? ?? 0;
    final pendingReferrals = data?['pending_referrals'] as int? ?? 0;

    return HomePageData(
      endingCampaigns: endingCampaigns,
      latestNews: latestNews,
      posterPromotions: posterPromotions,
      videoPromotions: videoPromotions,
      referralsReceived: referralsReceived,
      pendingReferrals: pendingReferrals,
    );
  } else {
    throw Exception(response.message ?? 'Failed to fetch home page data');
  }
}

@riverpod
class HomePageNotifier extends _$HomePageNotifier {
  @override
  Future<HomePageData> build() async {
    final homeApi = ref.watch(homeApiProvider);
    final response = await homeApi.getHomeData();

    if (response.success && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;

      final endingCampaigns = (data?['ending_campaigns'] as List<dynamic>?)
              ?.map((item) => CampaignModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      final latestNews = (data?['latest_news'] as List<dynamic>?)
              ?.map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      final posterPromotions = (data?['poster_promotion'] as List<dynamic>?)
              ?.map((item) => Promotions.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      final videoPromotions = (data?['video_promotion'] as List<dynamic>?)
              ?.map((item) => Promotions.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      final referralsReceived = data?['referrals_received'] as int? ?? 0;
      final pendingReferrals = data?['pending_referrals'] as int? ?? 0;

      return HomePageData(
        endingCampaigns: endingCampaigns,
        latestNews: latestNews,
        posterPromotions: posterPromotions,
        videoPromotions: videoPromotions,
        referralsReceived: referralsReceived,
        pendingReferrals: pendingReferrals,
      );
    } else {
      throw Exception(response.message ?? 'Failed to fetch home page data');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
