import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../utils/map_utils.dart' as map_utils;
import '../utils/constants.dart';

// ignore: must_be_immutable
class Map extends StatefulWidget {
  Map(this.southWest, this.northEast, {Key? key}) : super(key: key);

  static const String route = 'map';
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
  late String urlTemplate;
  bool urlTemplateLoaded = false;

  Future<void> _updateMap() async {
    LatLng pos = await map_utils.getDevicePosition();
    setState(() {
      //_mapController.move(pos, _mapController.zoom);
      _currentPositionMarker = map_utils.getDevicePositionMarker(pos);
      _movementPoints.add(pos);
    });
  }

  Future<void> _loadUrlTemplate() async {
    urlTemplate = await map_utils.getOffllineUrlTemplate();
    setState(() {
      urlTemplateLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 15), (_) => _updateMap());

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _loadUrlTemplate();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: urlTemplateLoaded
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onMapCreated: (c) {
                  _mapController = c;
                },
                zoom: OfflineZoomLevels.min,
                minZoom: OfflineZoomLevels.min,
                maxZoom: OfflineZoomLevels.max,
                swPanBoundary: widget.southWest,
                nePanBoundary: widget.northEast,
                center: LatLngBounds(widget.southWest, widget.northEast).center,
              ),
              layers: [
                TileLayerOptions(
                  tileProvider: const FileTileProvider(),
                  urlTemplate: urlTemplate,
                  errorImage: const AssetImage("images/stripes.png"),
                  attributionBuilder: (_) {
                    return const Text(
                      "Kartverket",
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    );
                  },
                ),
                MarkerLayerOptions(
                    markers: [_currentPositionMarker], rotate: true),
                PolylineLayerOptions(polylines: [
                  Polyline(
                      points: _movementPoints,
                      color: Colors.red,
                      isDotted: true,
                      strokeWidth: 10.0)
                ])
              ],
            )
          : const Center(child: Text("Laster inn")),
    );
  }
}
