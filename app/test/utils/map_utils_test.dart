import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/utils/map_utils.dart';

void main() {
  group("Map utils unit tests:", () {
    test('Get device position marker', () async {
      var pos = LatLng(61.123, 6.123);
      expect(getDevicePositionMarker(pos).point, pos);
    });

    test('Convert latitude and longitude to tile indexes', () {
      // Far north - King Oscar 2's Chapell
      expect(153508, getTileIndexX(longitude: 30.811433, zoom: 18));
      expect(59123, getTileIndexY(latitude: 69.784858, zoom: 18));

      // Far south - Lindesnes Lighthouse
      expect(68101, getTileIndexX(longitude: 7.047648, zoom: 17));
      expect(39489, getTileIndexY(latitude: 57.982383, zoom: 17));

      // In the middle of the map - Studentersamfundet
      expect(34660, getTileIndexX(longitude: 10.395004, zoom: 16));
      expect(17715, getTileIndexY(latitude: 63.422493, zoom: 16));

      // Zoomed all the way out - Norway
      expect(0, getTileIndexX(longitude: 6.151630, zoom: 0));
      expect(0, getTileIndexY(latitude: 62.470818, zoom: 0));

      // Unaccurate coordinates - Norway
      expect(135550, getTileIndexX(longitude: 6.15, zoom: 18));
      expect(72386, getTileIndexY(latitude: 62.47, zoom: 18));
    });
  });
}
