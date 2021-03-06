import 'dart:developer';
import 'dart:io';
import 'package:app/utils/constants.dart';
import 'package:app/utils/map_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test("Download tiles to app document directory", () async {
    String slash = Platform.isWindows ? '\\' : '/';

    setConstants();

    List<String> acutalDirectoryListing = [];
    List<String> expectedDirectoryListing = [];
    LatLng northWest = LatLng(63.419818, 10.397676);
    LatLng southEast = LatLng(63.415958, 10.408697);
    double minZoom = 15;
    double maxZoom = 16;
    Directory baseDir = await getApplicationDocumentsDirectory();
    String basePath = baseDir.path + "${slash}maps";

    try {
      Directory(basePath).deleteSync(recursive: true);
    } on FileSystemException {
      log("Could not find directory, probably doesn't exist");
    }

    //Construct expected directory listing
    for (int zoom = minZoom.toInt(); zoom <= maxZoom.toInt(); zoom++) {
      int west = getTileIndexX(longitude: northWest.longitude, zoom: zoom);
      int east = getTileIndexX(longitude: southEast.longitude, zoom: zoom);
      int north = getTileIndexY(latitude: northWest.latitude, zoom: zoom);
      int south = getTileIndexY(latitude: southEast.latitude, zoom: zoom);
      String currentPath = basePath + slash + zoom.toString();
      expectedDirectoryListing.add(currentPath);
      for (int x = west; x <= east; x++) {
        expectedDirectoryListing.add(currentPath + slash + x.toString());
        for (int y = north; y <= south; y++) {
          expectedDirectoryListing.add(currentPath +
              slash +
              x.toString() +
              slash +
              y.toString() +
              ".png");
        }
      }
    }

    await downloadTiles(
        northWest: northWest,
        southEast: southEast,
        minZoom: minZoom,
        maxZoom: maxZoom);

    Directory mapDir = Directory(basePath);
    await for (var entity in mapDir.list(recursive: true, followLinks: false)) {
      acutalDirectoryListing.add(entity.path);
    }

    expect(acutalDirectoryListing.length, expectedDirectoryListing.length);

    Set<String> expectedDirectoryListingSet = expectedDirectoryListing.toSet();

    expect(acutalDirectoryListing.length, expectedDirectoryListingSet.length);

    for (var path in acutalDirectoryListing) {
      expect(true, expectedDirectoryListingSet.contains(path));
    }

    int oldLength = acutalDirectoryListing.length;

    await downloadTiles(
        northWest: northWest,
        southEast: southEast,
        minZoom: minZoom,
        maxZoom: maxZoom);

    acutalDirectoryListing = [];
    await for (var entity in mapDir.list(recursive: true, followLinks: false)) {
      acutalDirectoryListing.add(entity.path);
    }

    expect(oldLength, acutalDirectoryListing.length);

    Directory(basePath).deleteSync(recursive: true);
  });
}
