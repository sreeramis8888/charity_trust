/// Response model for paginated API calls
class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int limit;

  PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.limit,
  });

  bool get hasMore => (currentPage * limit) < totalCount;
}
