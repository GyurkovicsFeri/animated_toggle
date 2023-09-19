import 'package:animated_toggle/animated_toggle.dart';
import 'package:animated_toggle/loading_indicator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  bool isActive = false;
  late final AnimationController _controller;

  late Animation<Color?> colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      debugLabel: 'Color',
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });
    colorAnimation = ColorTween(begin: Colors.red, end: Colors.blue).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedToggle(
              active: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
                if (isActive) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
            ),
            LoadingIndicator(
              color: colorAnimation.value!,
              radius: 8,
              duration: const Duration(seconds: 10),
              count: 10,
              snapPoints: 20,
            ),
          ],
        ),
      ),
    );
  }
}
