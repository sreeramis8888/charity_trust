import 'package:Annujoom/src/data/models/document_model.dart';
import 'package:Annujoom/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentsApi {
  static const String _endpoint = '/documents';

  final ApiProvider _apiProvider;

  DocumentsApi({required ApiProvider apiProvider}) : _apiProvider = apiProvider;

  /// App-facing list: active documents only.
  Future<ApiResponse<Map<String, dynamic>>> getAppDocuments({
    int pageNo = 1,
    int limit = 50,
    String? search,
  }) async {
    final queryParams = {
      'page_no': pageNo.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return _apiProvider.get(
      '$_endpoint/app?$queryString',
      requireAuth: true,
    );
  }
}

final documentsApiProvider = Provider<DocumentsApi>((ref) {
  return DocumentsApi(apiProvider: ref.watch(apiProviderProvider));
});

/// Loads active documents for the mobile Documents screen.
final appDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final api = ref.watch(documentsApiProvider);
  final response = await api.getAppDocuments();

  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load documents');
  }

  final raw = response.data!['data'];
  if (raw is! List) return [];

  return raw
      .whereType<Map>()
      .map((item) => DocumentModel.fromJson(Map<String, dynamic>.from(item)))
      .where((doc) => doc.fileUrl.isNotEmpty)
      .toList();
});
