import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:loggy/loggy.dart';

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
      body: SafeArea(
        child: FlutterMap(
          options: MapOptions(
            crs: CrsSimple(),
            center: LatLng(-0.5, 0.5),
            zoom: 1.0,
            maxZoom: 3.0,
          ),
          nonRotatedChildren: const [
            SimpleAttributionWidget(
              source:
                  Text('2010-2023 SQUARE ENIX CO., LTD.\nAll Rights Reserved.'),
            ),
          ],
          children: [
            TileLayer(
              tileProvider: AssetTileProvider(),
              urlTemplate: "assets/images/elpis/{z}/{x}/{y}.jpg",
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(0, 0),
                  builder: (ctx) => const FlutterLogo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
