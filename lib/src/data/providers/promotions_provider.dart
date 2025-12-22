import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';

part 'promotions_provider.g.dart';



class PromotionsApi {
  static const String _endpoint = '/promotions/user';

  final ApiProvider _apiProvider;

  PromotionsApi({required ApiProvider apiProvider})
      : _apiProvider = apiProvider;

  Future<ApiResponse<Map<String, dynamic>>> getPromotions({
    String? type,
  }) async {
    return await _apiProvider.get(
      _endpoint,
      requireAuth: true,
      queryParams: type != null ? {'type': type} : null,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPromotionById(String id) async {
    return await _apiProvider.get(
      '$_endpoint/$id',
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createPromotion(
    Map<String, dynamic> promotionData,
  ) async {
    return await _apiProvider.post(
      _endpoint,
      promotionData,
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePromotion(
    String id,
    Map<String, dynamic> promotionData,
  ) async {
    return await _apiProvider.patch(
      '$_endpoint/$id',
      promotionData,
      requireAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deletePromotion(String id) async {
    return await _apiProvider.delete(
      '$_endpoint/$id',
      requireAuth: true,
    );
  }
}

@riverpod
PromotionsApi promotionsApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return PromotionsApi(apiProvider: apiProvider);
}

@riverpod
Future<Map<String, dynamic>> promotions(Ref ref, {String? type}) async {
  final promotionsApi = ref.watch(promotionsApiProvider);
  final response = await promotionsApi.getPromotions(type: type);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.message ?? 'Failed to fetch promotions');
  }
}

@riverpod
Future<Map<String, dynamic>> promotionById(
  Ref ref,
  String id,
) async {
  final promotionsApi = ref.watch(promotionsApiProvider);
  final response = await promotionsApi.getPromotionById(id);

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.message ?? 'Failed to fetch promotion');
  }
}

@riverpod
class PromotionsListNotifier extends _$PromotionsListNotifier {
  @override
  Future<Map<String, dynamic>> build({String? type}) async {
    final promotionsApi = ref.watch(promotionsApiProvider);
    final response = await promotionsApi.getPromotions(type: type);

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch promotions');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final promotionsApi = ref.watch(promotionsApiProvider);
      final response = await promotionsApi.getPromotions(type: null);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch promotions');
      }
    });
  }

  Future<void> createPromotion(Map<String, dynamic> promotionData) async {
    final promotionsApi = ref.watch(promotionsApiProvider);
    final response = await promotionsApi.createPromotion(promotionData);

    if (response.success) {
      await refresh();
    } else {
      throw Exception(response.message ?? 'Failed to create promotion');
    }
  }

  Future<void> updatePromotion(
    String id,
    Map<String, dynamic> promotionData,
  ) async {
    final promotionsApi = ref.watch(promotionsApiProvider);
    final response = await promotionsApi.updatePromotion(id, promotionData);

    if (response.success) {
      await refresh();
    } else {
      throw Exception(response.message ?? 'Failed to update promotion');
    }
  }

  Future<void> deletePromotion(String id) async {
    final promotionsApi = ref.watch(promotionsApiProvider);
    final response = await promotionsApi.deletePromotion(id);

    if (response.success) {
      await refresh();
    } else {
      throw Exception(response.message ?? 'Failed to delete promotion');
    }
  }
}
