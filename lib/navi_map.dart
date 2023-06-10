import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:loggy/loggy.dart';

class NaviMap extends StatefulWidget {
  const NaviMap({super.key, required this.title});

  final String title;

  @override
  State<NaviMap> createState() => _NaviMapState();
}

class _NaviMapState extends State<NaviMap> {
  CarouselController buttonCarouselController = CarouselController();

  late int patchId;

  late int mapId;

  late Future jsonLoaderFuture;

  ///
  /// 画面初期化時
  ///
  @override
  void initState() {
    super.initState();

    // ff14_map.json読み込み
    Future<List<dynamic>> ff14MapFuture = Future<List<dynamic>>(() async {
      final loadData = await rootBundle.load('assets/json/ff14_map.json');
      final jsonStr =
          const Utf8Decoder().convert(loadData.buffer.asUint8List());
      final ff14MapJsonList = jsonDecode(jsonStr) as List<dynamic>;

      // デフォルトパッチ、マップID
      patchId = ff14MapJsonList[0]['patch_id'];
      mapId = ff14MapJsonList[0]['map_id'];

      return ff14MapJsonList;
    });

    // ff14_aetheryte_coordinate.json読み込み
    Future<List<dynamic>> ff14AetheryteCoordinateFuture =
        Future<List<dynamic>>(() async {
      final loadData =
          await rootBundle.load('assets/json/ff14_aetheryte_coordinate.json');
      final jsonStr =
          const Utf8Decoder().convert(loadData.buffer.asUint8List());
      return jsonDecode(jsonStr) as List<dynamic>;
    });

    // 上記Futureの完了を待つ
    jsonLoaderFuture =
        Future.wait([ff14MapFuture, ff14AetheryteCoordinateFuture]);
  }

  void _selectMapName(int argPatchId, int argMapId) {
    setState(() {
      // カルーセルのアニメーション
      buttonCarouselController.animateToPage(
        argMapId - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linearToEaseOut,
      );
      // 選択したパッチ、マップID
      patchId = argPatchId;
      mapId = argMapId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: jsonLoaderFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none: // ？？？
              case ConnectionState.waiting: // 処理中データ: Null
              case ConnectionState.active: // 処理中データ: Not Null
                return const Center(
                  child: Text('準備中'),
                );
              case ConnectionState.done: // 完了
                return Stack(
                  children: [
                    _flutterMap(snapshot.data[0], snapshot.data[1]),
                    _carouselSlider(snapshot.data[0]),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  ///
  /// カルーセル
  ///
  Widget _carouselSlider(List<dynamic> ff14MapJsonList) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 80.0,
        viewportFraction: 0.45,
        initialPage: 0,
        enlargeCenterPage: true,
      ),
      items: ff14MapJsonList.map((ff14MapJson) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.srcATop,
                  ),
                  image: AssetImage(
                      'assets/images/maps/${ff14MapJson['map_name'].toString().toLowerCase().replaceAll(' ', '_')}/thumbnail.jpg'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: ListTile(
                title: Text(
                  ff14MapJson['map_name_ja'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  _selectMapName(
                      ff14MapJson['patch_id'], ff14MapJson['map_id']);
                },
              ),
            );
          },
        );
      }).toList(),
      carouselController: buttonCarouselController,
    );
  }

  ///
  /// 地図
  ///
  Widget _flutterMap(List<dynamic> ff14MapJsonList,
      List<dynamic> ff14AetheryteCoordinateJsonList) {
    // マップ画像パス
    List<dynamic> selectedFf14MapJsonList = ff14MapJsonList
        .where((item) => item['patch_id'] == patchId && item['map_id'] == mapId)
        .toList();
    String selectedFf14MapName = selectedFf14MapJsonList[0]['map_name'];
    String selectedFf14MapPath =
        "assets/images/maps/${selectedFf14MapName.toLowerCase().replaceAll(' ', '_')}/{z}/{x}/{y}.jpg";
    // エーテライト座標リスト
    List<dynamic> selectedAetheryteCieJsonList = ff14AetheryteCoordinateJsonList
        .where((item) => item['patch_id'] == patchId && item['map_id'] == mapId)
        .toList();

    // エーテライトマーカー
    List<Marker> aetheryteMarkerList = List.empty(growable: true);
    for (dynamic aetheryteCieJson in selectedAetheryteCieJsonList) {
      Marker iconMarker = Marker(
        height: 20,
        width: 20,
        point: LatLng(-(1 / 409 * (aetheryteCieJson['y_coordinate'] - 10)),
            (1 / 409 * (aetheryteCieJson['x_coordinate'] - 10))),
        builder: (ctx) => Image.asset('assets/images/aetheryte.png'),
      );
      Marker textMarker = Marker(
        width: 200,
        point: LatLng(-(1 / 409 * (aetheryteCieJson['y_coordinate'] - 10 + 5)),
            (1 / 409 * (aetheryteCieJson['x_coordinate'] - 10))),
        builder: (ctx) => Center(
          child: Text(
            aetheryteCieJson['coordinate_name_ja'],
            style: const TextStyle(fontSize: 10),
          ),
        ),
      );
      aetheryteMarkerList.add(iconMarker);
      aetheryteMarkerList.add(textMarker);
    }

    return FlutterMap(
      options: MapOptions(
        crs: CrsSimple(),
        center: const LatLng(-0.5, 0.5),
        zoom: 0.65,
        maxZoom: 3.0,
      ),
      nonRotatedChildren: const [
        SimpleAttributionWidget(
          source: Text('2010-2023 SQUARE ENIX CO., LTD.\nAll Rights Reserved.'),
        ),
      ],
      children: [
        TileLayer(
          tileProvider: AssetTileProvider(),
          urlTemplate: selectedFf14MapPath,
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        MarkerLayer(
          markers: aetheryteMarkerList,
        ),
      ],
    );
  }
}
