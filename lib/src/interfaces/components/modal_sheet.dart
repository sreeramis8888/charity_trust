import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/models/paginated_response.dart';

class ModalSheet<T> {
  final BuildContext context;
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onItemSelected;
  final bool Function(T, String)? searchFilter;
  final Widget Function(T)? itemBuilder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Color backgroundColor;
  final Color barrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsets contentPadding;
  final double borderRadius;
  final bool showSearchBar;
  final String searchHint;
  final TextInputType searchInputType;
  final int? maxLines;
  final VoidCallback? onDismiss;

  ModalSheet({
    required this.context,
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.searchFilter,
    this.itemBuilder,
    this.initialChildSize = 0.85,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.95,
    this.backgroundColor = Colors.white,
    this.barrierColor = Colors.black54,
    this.isDismissible = true,
    this.enableDrag = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.contentPadding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.showSearchBar = true,
    this.searchHint = 'Search...',
    this.searchInputType = TextInputType.text,
    this.maxLines,
    this.onDismiss,
  });

  /// Paginated modal sheet for API-based search with pagination
  static Future<void> showPaginated<T>({
    required BuildContext context,
    required String title,
    required Future<PaginatedResponse<T>> Function(int pageNo, String query)
        onFetchPage,
    required String Function(T) itemLabel,
    required void Function(T) onItemSelected,
    required Widget Function(T)? itemBuilder,
    String searchHint = 'Search...',
    double initialChildSize = 0.85,
    double minChildSize = 0.5,
    double maxChildSize = 0.95,
    Color backgroundColor = Colors.white,
    Color barrierColor = Colors.black54,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsets contentPadding = const EdgeInsets.all(16),
    double borderRadius = 20,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => _PaginatedModalSheetContent<T>(
        title: title,
        onFetchPage: onFetchPage,
        itemLabel: itemLabel,
        onItemSelected: onItemSelected,
        itemBuilder: itemBuilder,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        backgroundColor: backgroundColor,
        contentPadding: contentPadding,
        borderRadius: borderRadius,
        searchHint: searchHint,
        onDismiss: onDismiss,
      ),
    );
  }

  Future<void> show() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => _ModalSheetContent<T>(
        title: title,
        items: items,
        itemLabel: itemLabel,
        onItemSelected: onItemSelected,
        searchFilter: searchFilter,
        itemBuilder: itemBuilder,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        backgroundColor: backgroundColor,
        contentPadding: contentPadding,
        borderRadius: borderRadius,
        showSearchBar: showSearchBar,
        searchHint: searchHint,
        searchInputType: searchInputType,
        maxLines: maxLines,
        onDismiss: onDismiss,
      ),
    );
  }
}

class _ModalSheetContent<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onItemSelected;
  final bool Function(T, String)? searchFilter;
  final Widget Function(T)? itemBuilder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Color backgroundColor;
  final EdgeInsets contentPadding;
  final double borderRadius;
  final bool showSearchBar;
  final String searchHint;
  final TextInputType searchInputType;
  final int? maxLines;
  final VoidCallback? onDismiss;

  const _ModalSheetContent({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onItemSelected,
    this.searchFilter,
    this.itemBuilder,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.backgroundColor,
    required this.contentPadding,
    required this.borderRadius,
    required this.showSearchBar,
    required this.searchHint,
    required this.searchInputType,
    this.maxLines,
    this.onDismiss,
  });

  @override
  State<_ModalSheetContent<T>> createState() => _ModalSheetContentState<T>();
}

class _ModalSheetContentState<T> extends State<_ModalSheetContent<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          if (widget.searchFilter != null) {
            return widget.searchFilter!(item, query);
          }
          return widget
              .itemLabel(item)
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.borderRadius),
              topRight: Radius.circular(widget.borderRadius),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: widget.contentPadding.copyWith(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              if (widget.showSearchBar)
                Padding(
                  padding: widget.contentPadding.copyWith(top: 0, bottom: 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    keyboardType: widget.searchInputType,
                    maxLines: widget.maxLines ?? 1,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _filterItems('');
                              },
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              // Items list
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: widget.contentPadding.copyWith(top: 8),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return GestureDetector(
                              onTap: () {
                                widget.onItemSelected(item);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: widget.itemBuilder != null
                                    ? widget.itemBuilder!(item)
                                    : Text(
                                        widget.itemLabel(item),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.onDismiss?.call();
    super.dispose();
  }
}

/// Paginated modal sheet content widget for API-based search
class _PaginatedModalSheetContent<T> extends StatefulWidget {
  final String title;
  final Future<PaginatedResponse<T>> Function(int pageNo, String query)
      onFetchPage;
  final String Function(T) itemLabel;
  final void Function(T) onItemSelected;
  final Widget Function(T)? itemBuilder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Color backgroundColor;
  final EdgeInsets contentPadding;
  final double borderRadius;
  final String searchHint;
  final VoidCallback? onDismiss;

  const _PaginatedModalSheetContent({
    required this.title,
    required this.onFetchPage,
    required this.itemLabel,
    required this.onItemSelected,
    required this.itemBuilder,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.backgroundColor,
    required this.contentPadding,
    required this.borderRadius,
    required this.searchHint,
    this.onDismiss,
  });

  @override
  State<_PaginatedModalSheetContent<T>> createState() =>
      _PaginatedModalSheetContentState<T>();
}

class _PaginatedModalSheetContentState<T>
    extends State<_PaginatedModalSheetContent<T>> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  List<T> _items = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _isLoading = false;
  bool _hasMore = false;
  String _currentQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _items = [];
    });

    try {
      final response = await widget.onFetchPage(1, _currentQuery);
      setState(() {
        _items = response.items;
        _totalCount = response.totalCount;
        _currentPage = response.currentPage;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await widget.onFetchPage(nextPage, _currentQuery);
      setState(() {
        _items.addAll(response.items);
        _currentPage = response.currentPage;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more items: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadNextPage();
    }
  }

  Future<void> _onSearchChanged(String query) async {
    _currentQuery = query;

    if (query.isEmpty) {
      await _loadFirstPage();
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _currentPage = 1;
      _items = [];
    });

    try {
      final response = await widget.onFetchPage(1, query);
      setState(() {
        _items = response.items;
        _totalCount = response.totalCount;
        _currentPage = response.currentPage;
        _hasMore = response.hasMore;
        _isLoading = false;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.borderRadius),
              topRight: Radius.circular(widget.borderRadius),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: widget.contentPadding.copyWith(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: widget.contentPadding.copyWith(top: 0, bottom: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  keyboardType: TextInputType.text,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              // Items list
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: _isLoading && _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: LoadingAnimation(
                               
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No results found',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: widget.contentPadding.copyWith(top: 8),
                              itemCount: _items.length +
                                  (_hasMore && _isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _items.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: LoadingAnimation(
                     
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final item = _items[index];
                                return GestureDetector(
                                  onTap: () {
                                    widget.onItemSelected(item);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: widget.itemBuilder != null
                                        ? widget.itemBuilder!(item)
                                        : Text(
                                            widget.itemLabel(item),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    widget.onDismiss?.call();
    super.dispose();
  }
}
