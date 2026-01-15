import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'zakat_provider.g.dart';

class ZakatCalculatorRequest {
  final String nisabType;
  final Map<String, double> assets;
  final Map<String, double> liabilities;

  ZakatCalculatorRequest({
    required this.nisabType,
    required this.assets,
    required this.liabilities,
  });

  Map<String, dynamic> toJson() => {
        'nisab_type': nisabType,
        'assets': assets,
        'liabilities': liabilities,
      };
}

class ZakatCalculatorResponse {
  final double netWorth;
  final double zakatPayable;

  ZakatCalculatorResponse({
    required this.netWorth,
    required this.zakatPayable,
  });

  factory ZakatCalculatorResponse.fromJson(Map<String, dynamic> json) {
    return ZakatCalculatorResponse(
      netWorth: (json['net_worth'] as num?)?.toDouble() ?? 0.0,
      zakatPayable: (json['zakat_payable'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ZakatApi {
  final ApiProvider _apiProvider;

  ZakatApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  Future<ApiResponse> calculateZakat(ZakatCalculatorRequest request) async {
    return await _apiProvider.post(
      '/zakat/calculate',
      request.toJson(),
      requireAuth: true,
    );
  }
}

@riverpod
ZakatApi zakatApi(Ref ref) {
  final apiProvider = ref.watch(apiProviderProvider);
  return ZakatApi(apiProvider: apiProvider);
}

@riverpod
class ZakatCalculatorNotifier extends _$ZakatCalculatorNotifier {
  @override
  Future<ZakatCalculatorResponse?> build() async {
    return null;
  }

  Future<ZakatCalculatorResponse?> calculateZakat({
    required String nisabType,
    required Map<String, double> assets,
    required Map<String, double> liabilities,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final zakatApi = ref.watch(zakatApiProvider);
      final request = ZakatCalculatorRequest(
        nisabType: nisabType,
        assets: assets,
        liabilities: liabilities,
      );

      final response = await zakatApi.calculateZakat(request);

      if (response.success && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          return ZakatCalculatorResponse.fromJson(data);
        }
        throw Exception('No calculation data in response');
      } else {
        throw Exception(response.message ?? 'Failed to calculate zakat');
      }
    });

    return state.maybeWhen(
      data: (result) => result,
      orElse: () => null,
    );
  }
}
