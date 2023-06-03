import 'package:ff14_risky_mob_treasure_hunt_navi/navi_map.dart';
import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';

import 'custom_pretty_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Loggy.initLoggy(logPrinter: const CustomPrettyPrinter(showColors: true));

    return MaterialApp(
      title: 'FF14 Risky Mob & Treasure Hunt Navi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FF14 Risky Mob & Treasure Hunt Navi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('NaviMapへ移動'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NaviMap(
                      title: 'NaviMap',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
