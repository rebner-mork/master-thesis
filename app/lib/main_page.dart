import 'dart:async';
import 'package:app/map/map_widget.dart';
import 'package:app/registration_options.dart';
import 'package:app/trip/end_trip_dialog.dart';
import 'package:app/trip/trip_data_manager.dart';
import 'package:app/utils/custom_widgets.dart';
import 'package:app/utils/other.dart';
import 'package:app/widgets/circular_buttons.dart';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../utils/map_utils.dart' as map_utils;

class MainPage extends StatefulWidget {
  const MainPage(
      {required this.speechToText,
      required this.ongoingDialog,
      required this.northWest,
      required this.southEast,
      required this.mapName,
      required this.farmId,
      required this.personnelEmail,
      required this.eartags,
      required this.ties,
      this.onCompleted,
      Key? key})
      : super(key: key);

  final SpeechToText speechToText;
  final ValueNotifier<bool> ongoingDialog;

  final VoidCallback? onCompleted;

  final LatLng northWest;
  final LatLng southEast;

  final String mapName;

  final String farmId;
  final String personnelEmail;

  final Map<String, bool?> eartags;
  final Map<String, int?> ties;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const double buttonInset = 8;
  late final TripDataManager _tripData;

  late LatLng _deviceStartPosition;

  int _sheepAmount = 0;
  double iconSize = 42;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _setDeviceStartPosition();
    });
  }

  Future<void> _setDeviceStartPosition() async {
    _deviceStartPosition = await map_utils.getDevicePosition();

    _tripData = TripDataManager.start(
        personnelEmail: widget.personnelEmail,
        farmId: widget.farmId,
        mapName: widget.mapName);
    _tripData.track.add(_deviceStartPosition);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: _isLoading
            ? const LoadingData()
            : WillPopScope(
                onWillPop: () async {
                  return _endTripButtonPressed(context, _tripData);
                },
                child: Scaffold(
                    endDrawer: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewPadding.bottom +
                                        50 + // height of CircularButton
                                        2 * buttonInset),
                            child: const ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    bottomLeft: Radius.circular(30)),
                                child: SizedBox(
                                    width: 280,
                                    height: 520,
                                    child: Drawer(
                                      child: RegistrationOptions(),
                                    ))))),
                    body: Stack(children: [
                      ValueListenableBuilder<bool>(
                          valueListenable: widget.ongoingDialog,
                          builder: (context, value, child) => MapWidget(
                                northWest: widget.northWest,
                                southEast: widget.southEast,
                                stt: widget.speechToText,
                                ongoingDialog: widget.ongoingDialog,
                                eartags: widget.eartags,
                                ties: widget.ties,
                                deviceStartPosition: _deviceStartPosition,
                                onSheepRegistered: (Map<String, Object> data) {
                                  int sheepAmountRegistered =
                                      data['sheep']! as int;
                                  if (sheepAmountRegistered > 0) {
                                    _tripData.registrations.add(data);
                                    setState(() {
                                      _sheepAmount += sheepAmountRegistered;
                                    });
                                  }
                                },
                                onNewPosition: (position) =>
                                    _tripData.track.add(position),
                              )),
                      Positioned(
                        top: buttonInset +
                            MediaQuery.of(context).viewPadding.top,
                        left: buttonInset,
                        child: CircularButton(
                            child: Icon(
                              Icons.cloud_upload,
                              size: iconSize,
                            ),
                            onPressed: () {
                              _endTripButtonPressed(context, _tripData);
                            }),
                      ),
                      Positioned(
                          top: buttonInset +
                              MediaQuery.of(context).viewPadding.top,
                          right: buttonInset,
                          child: CircularButton(
                            child: SettingsIcon(iconSize: iconSize),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => const SettingsDialog());
                            },
                          )),
                      Positioned(
                        bottom: buttonInset +
                            MediaQuery.of(context).viewPadding.bottom,
                        left: buttonInset,
                        child: CircularButton(
                          child: Sheepometer(
                              sheepAmount: _sheepAmount, iconSize: iconSize),
                          onPressed: () {},
                          width: 62 +
                              textSize(_sheepAmount.toString(),
                                      circularButtonTextStyle)
                                  .width,
                        ),
                      ),
                      Builder(
                          builder: (context) => Positioned(
                              bottom: buttonInset +
                                  MediaQuery.of(context).viewPadding.bottom,
                              right: buttonInset,
                              child: CircularButton(
                                child: const Text(
                                  '+?',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Scaffold.of(context).openEndDrawer();
                                },
                              )))
                    ]))));
  }

  Future<bool> _endTripButtonPressed(
      BuildContext context, TripDataManager _trip) async {
    bool isConnected = await isConnectedToInternet();
    await showEndTripDialog(context, isConnected).then((isFinished) {
      if (isFinished) {
        if (isConnected) {
          _trip.post();
        } else {
          _trip.archive();
        }
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        }
        Navigator.pop(context);
      }
      return isFinished;
    });
    return false;
  }
}
