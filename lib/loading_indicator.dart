import 'dart:math';

import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final Color color;
  final double radius;
  final int count;
  final int snapPoints;
  final Duration duration;

  const LoadingIndicator({
    super.key,
    required this.color,
    required this.radius,
    required this.duration,
    this.count = 5,
    this.snapPoints = 20,
  })  : assert(count > 0),
        assert(snapPoints > 0),
        assert(radius > 0);

  @override
  State<StatefulWidget> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Iterable<Animation<double>> animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        setState(() {});
      })
      ..repeat();
    _recreateAnimations();
  }

  @override
  void didUpdateWidget(covariant LoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.count != widget.count || oldWidget.snapPoints != widget.snapPoints) {
      _recreateAnimations();
    }
  }

  void _recreateAnimations() {
    List<Animation<double>> animations = [];
    final snap = widget.snapPoints;
    final count = widget.count;
    final stepCount = snap;

    for (int i = 0; i < count; i++) {
      List<TweenSequenceItem<double>> items = [];
      double position = snappingPoint(snap, -i);
      int restForCycles = 0;
      for (int t = 0; t < stepCount; t++) {
        final round = t ~/ count;
        final shouldMove = t.remainder(count) == i;
        if (shouldMove) {
          if (restForCycles != 0) {
            items.add(
                TweenSequenceItem<double>(tween: ConstantTween<double>(position), weight: restForCycles.toDouble()));
          }
          final double newPosition = snappingPoint(snap, -i - (round * count) - count) + 2 * pi;
          items.add(
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: position, end: newPosition).chain(CurveTween(curve: Curves.easeInOut)),
              weight: 1,
            ),
          );
          position = snappingPoint(snap, -i - (round * count) - count);
          restForCycles = 0;
        } else {
          restForCycles += 1;
        }
        if (t == stepCount - 1 && restForCycles != 0) {
          items.add(
            TweenSequenceItem<double>(tween: ConstantTween<double>(position), weight: restForCycles.toDouble()),
          );
        }
      }

      final controller = _controller;
      final Animation<double> animation = TweenSequence<double>(items).animate(controller);
      animations.add(animation);
    }
    this.animations = animations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double snappingPoint(int into, int count) {
    final double step = 2 * 3.14 / into;
    return count * step;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 150,
      child: LoadingIndicatorView(
        angles: animations.map((e) => e.value).toList(),
        color: widget.color,
        radius: widget.radius,
      ),
    );
  }
}

class LoadingIndicatorView extends LeafRenderObjectWidget {
  final List<double> angles;
  final Color color;
  final double radius;

  const LoadingIndicatorView({super.key, required this.angles, required this.color, required this.radius});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLoadingIndicator();
  }

  @override
  void updateRenderObject(BuildContext context, RenderLoadingIndicator renderObject) {
    renderObject.angles = angles;
    renderObject.color = color;
    renderObject.radius = radius;
  }
}

class RenderLoadingIndicator extends RenderBox {
  List<double> _angles = [];
  set angles(List<double> value) {
    if (value == _angles) return;
    if (value.length != _angles.length) {
      markNeedsPaint();
    } else {
      for (int i = 0; i < value.length; i++) {
        if (value[i] != _angles[i]) {
          markNeedsPaint();
          break;
        }
      }
    }
    _angles = value;
    markNeedsPaint();
  }

  List<double> get angles => _angles;

  Color _color = Colors.red;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  Color get color => _color;

  double _raduis = 10;
  set radius(double value) {
    if (value == _raduis) return;
    _raduis = value;
    markNeedsPaint();
  }

  double get radius => _raduis;

  RenderLoadingIndicator() : super();

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  final Paint circlePaint = Paint();

  @override
  void paint(PaintingContext context, Offset offset) {
    circlePaint
      ..color = color
      ..style = PaintingStyle.fill;

    final center = size.center(offset);
    for (final angle in angles) {
      context.canvas.drawCircle(
        center + Offset.fromDirection(angle, (size.height / 2) - radius),
        radius,
        circlePaint,
      );
    }
  }
}
