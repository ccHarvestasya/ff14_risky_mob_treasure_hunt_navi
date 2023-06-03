import 'package:flutter/material.dart';

class NaviMap extends StatefulWidget {
  const NaviMap({super.key, required this.title});

  final String title;

  @override
  State<NaviMap> createState() => _NaviMapState();
}

class _NaviMapState extends State<NaviMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('NaviMapですよ'),
            ],
          ),
        ),
      ),
    );
  }
}
