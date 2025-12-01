import 'package:flutter/material.dart';

class AnimatedDropdown<T> extends StatefulWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T) itemLabel;
  final double borderRadius;
  final double height;
  final double maxMenuHeight;

  const AnimatedDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.borderRadius = 12,
    this.height = 52,
    this.maxMenuHeight = 240,
  });

  @override
  State<AnimatedDropdown<T>> createState() => _AnimatedDropdownState<T>();
}

class _AnimatedDropdownState<T> extends State<AnimatedDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool openUpwards = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 230),
      vsync: this,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    _calculateDirection();
    _configureSlideAnimation();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    _controller.forward();
  }

  void _closeDropdown() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _calculateDirection() {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset offset = box.localToGlobal(Offset.zero);

    double screenHeight = MediaQuery.of(context).size.height;

    double spaceBelow = screenHeight - (offset.dy + widget.height);
    double spaceAbove = offset.dy;

    // If below space < required height, open upwards
    openUpwards = spaceBelow < 200 && spaceAbove > spaceBelow;
  }

  void _configureSlideAnimation() {
    _slide = Tween<Offset>(
      begin: openUpwards ? const Offset(0, 0.05) : const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox box = context.findRenderObject() as RenderBox;
    final Size size = box.size;

    // menu height = min(maxHeight, actual required height)
    double menuHeight =
        (widget.items.length * 48).toDouble().clamp(0, widget.maxMenuHeight);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap outside to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
            ),
          ),

          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,

              // ⭐ FIXED OFFSET LOGIC
              offset: openUpwards
                  ? Offset(0, -menuHeight - 6) // place just above dropdown
                  : Offset(0, size.height + 6), // place below dropdown

              showWhenUnlinked: false,
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
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        children: widget.items.map((item) {
                          return GestureDetector(
                            onTap: () {
                              widget.onChanged(item);
                              _closeDropdown();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Text(
                                widget.itemLabel(item),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
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
                  color: widget.value == null
                      ? Colors.grey.shade600
                      : Colors.black,
                  fontSize: 14,
                ),
              ),
              Icon(
                openUpwards
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
