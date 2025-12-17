import 'package:flutter/material.dart';

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
          return widget.itemLabel(item)
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
