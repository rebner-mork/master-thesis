import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:web/trips/main_trip_info_table.dart';
import 'package:web/trips/map_of_trip_widget.dart';
import 'package:latlong2/latlong.dart';

class DetailedTrip extends StatefulWidget {
  const DetailedTrip(this.tripData, {Key? key}) : super(key: key);

  final Map<String, Object> tripData;

  @override
  State<DetailedTrip> createState() => _DetailedTripState();
}

class _DetailedTripState extends State<DetailedTrip> {
  late DateTime startTime;
  late DateTime stopTime;

  @override
  void initState() {
    super.initState();
    startTime = (widget.tripData['startTime']! as Timestamp).toDate();
    stopTime = (widget.tripData['stopTime']! as Timestamp).toDate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Flexible(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: MainTripInfoTable(
                startTime: startTime,
                stopTime: stopTime,
                email: widget.tripData['personnelEmail']! as String,
                phone: widget.tripData['personnelPhone']! as String,
              ))),
      Flexible(
          child: MapOfTripWidget(
              mapCenter: widget.tripData['mapCenter']! as LatLng,
              track: widget.tripData['track']! as List<Map<String, double>>,
              registrations: widget.tripData['registrations']!
                  as List<Map<String, dynamic>>))
    ]);
  }
}
