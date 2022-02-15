import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../utils/map_utils.dart' as map_utils;

class Map extends StatefulWidget {
  Map(this.southWest, this.northEast, this.urlTemplate, {Key? key})
      : super(key: key);

  static const String route = 'map';
  late String urlTemplate;
  late LatLng southWest;
  late LatLng northEast;

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  MapController _mapController = MapController();
  Marker _currentPositionMarker =
      map_utils.getDevicePositionMarker(LatLng(0, 0));
  final List<LatLng> _movementPoints = [];
  late Timer timer;

  Future<void> _updateMap() async {
    LatLng pos = await map_utils.getDevicePosition();
    setState(() {
      _mapController.move(pos, _mapController.zoom);
      _currentPositionMarker = map_utils.getDevicePositionMarker(pos);
      _movementPoints.add(pos);
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 15), (_) => _updateMap());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          onMapCreated: (c) {
            _mapController = c;
          },
          zoom: 15,
          minZoom: 15,
          maxZoom: 17,
          swPanBoundary: widget.southWest,
          nePanBoundary: widget.northEast,
          center: LatLngBounds(widget.southWest, widget.northEast).center,
        ),
        layers: [
          TileLayerOptions(
            tileProvider: const FileTileProvider(),
            urlTemplate: widget.urlTemplate,
            errorImage: const AssetImage("images/stripes.png"),
            attributionBuilder: (_) {
              return const Text(
                "Kartverket",
                style: TextStyle(color: Colors.black, fontSize: 10),
              );
            },
          ),
          MarkerLayerOptions(markers: [_currentPositionMarker], rotate: true),
          PolylineLayerOptions(polylines: [
            Polyline(
                points: _movementPoints,
                color: Colors.red,
                isDotted: true,
                strokeWidth: 10.0)
          ])
        ],
      ),
    );
  }
}
