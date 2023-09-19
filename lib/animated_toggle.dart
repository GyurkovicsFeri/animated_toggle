import 'package:flutter/material.dart';

class AnimatedToggle extends StatefulWidget {
  final bool active;
  final ValueChanged<bool>? onChanged;

  final Duration duration;
  final double width;
  final double height;

  final double tagBorder;
  final double tagHeight;
  final double tagWidth;

  const AnimatedToggle({
    super.key,
    required this.active,
    required this.onChanged,
    this.duration = const Duration(milliseconds: 200),
    this.width = 44.0,
    this.height = 24.0,
    this.tagBorder = 2.0,
  })  : tagHeight = height - tagBorder * 2.0,
        tagWidth = height - tagBorder * 2.0;

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: widget.active,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            widget.onChanged?.call(!widget.active);
          },
          child: Stack(
            children: [
              AnimatedContainer(
                duration: widget.duration,
                height: 24,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.active ? Colors.red : Colors.grey[300],
                ),
              ),
              Positioned(
                top: widget.height / 2 - 6,
                left: 6,
                child: AnimatedScale(
                  scale: widget.active ? 1 : 0,
                  duration: widget.duration,
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
              Positioned(
                top: widget.height / 2 - 6,
                right: 6,
                child: AnimatedScale(
                  scale: widget.active ? 0 : 1,
                  duration: widget.duration,
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: widget.duration,
                curve: Curves.easeInOutBack,
                top: widget.tagBorder,
                left: widget.active ? (widget.width - widget.tagWidth - widget.tagBorder) : widget.tagBorder,
                child: Container(
                  height: widget.tagHeight,
                  width: widget.tagWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.tagHeight / 2),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
