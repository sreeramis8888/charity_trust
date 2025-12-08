import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchableDropdown<T> extends ConsumerStatefulWidget {
  final String hint;
  final T? value;
  final Future<List<T>> Function(String search, int page) onFetch;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final double borderRadius;
  final double height;
  final double maxMenuHeight;

  const SearchableDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.onFetch,
    required this.itemLabel,
    required this.onChanged,
    this.borderRadius = 12,
    this.height = 52,
    this.maxMenuHeight = 300,
  });

  @override
  ConsumerState<SearchableDropdown<T>> createState() =>
      _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends ConsumerState<SearchableDropdown<T>>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  List<T> _items = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool openUpwards = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  Future<void> _openDropdown() async {
    _determineOpenDirection();
    _configureSlideAnimation();

    _currentPage = 1;
    _hasMorePages = true;
    await _loadItems();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    _controller.forward();
  }

  void _closeDropdown() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _searchController.clear();
    });
  }

  Future<void> _loadItems() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result =
          await widget.onFetch(_searchController.text.trim(), _currentPage);

      setState(() {
        if (_currentPage == 1) {
          _items = result;
        } else {
          _items.addAll(result);
        }

        _hasMorePages = result.length >= 10;
      });
    } catch (e) {
      debugPrint("Error fetching items: $e");
    }

    setState(() => _isLoading = false);
  }

  Future<void> _onSearch(String value) async {
    _currentPage = 1;
    _hasMorePages = true;
    await _loadItems();
    _overlayEntry?.markNeedsBuild();
  }

  Future<void> _loadMore() async {
    if (!_hasMorePages || _isLoading) return;
    _currentPage++;
    await _loadItems();
    _overlayEntry?.markNeedsBuild();
  }

  void _determineOpenDirection() {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset pos = box.localToGlobal(Offset.zero);

    double screenHeight = MediaQuery.of(context).size.height;

    double spaceBelow = screenHeight - (pos.dy + widget.height);
    double spaceAbove = pos.dy;

    openUpwards = spaceBelow < 250 && spaceAbove > spaceBelow;
  }

  void _configureSlideAnimation() {
    _slide = Tween<Offset>(
      begin: openUpwards ? const Offset(0, 0.1) : const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox box = context.findRenderObject() as RenderBox;
    final Size size = box.size;
    final Offset offset = box.localToGlobal(Offset.zero);
    double menuHeight =
        (_items.length * 48 + 56).clamp(0, widget.maxMenuHeight).toDouble();

    double top =
        openUpwards ? offset.dy - menuHeight - 6 : offset.dy + size.height + 6;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDropdown,
                behavior: HitTestBehavior.translucent,
              ),
            ),

            /// FIXED: Proper position using left + top
            Positioned(
              left: offset.dx,
              top: top,
              width: size.width,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Container(
                      height: menuHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearch,
                              decoration: InputDecoration(
                                hintText: "Search...",
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
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.4,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _isLoading && _items.isEmpty
                                ? const Center(child: LoadingAnimation())
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    itemCount:
                                        _items.length + (_hasMorePages ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _items.length) {
                                        _loadMore();
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            height: 30,
                                            child: LoadingAnimation(),
                                          ),
                                        );
                                      }

                                      final item = _items[index];

                                      return GestureDetector(
                                        onTap: () {
                                          widget.onChanged(item);
                                          _closeDropdown();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                          child: Text(
                                            widget.itemLabel(item),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.value == null
                  ? widget.hint
                  : widget.itemLabel(widget.value as T),
              style: TextStyle(
                color:
                    widget.value == null ? Colors.grey.shade600 : Colors.black,
                fontSize: 14,
              ),
            ),
            Icon(
              openUpwards ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
