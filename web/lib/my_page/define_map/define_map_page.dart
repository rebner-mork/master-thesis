import 'dart:collection';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web/my_page/define_map/define_map.dart';
import 'package:latlong2/latlong.dart';

class DefineMapPage extends StatefulWidget {
  const DefineMapPage({Key? key}) : super(key: key);

  @override
  State<DefineMapPage> createState() => _DefineMapPageState();
}

class _DefineMapPageState extends State<DefineMapPage> {
  _DefineMapPageState();

  final List<String> _mapNames = [];
  final List<Map<String, LatLng>> _mapCoordinates = [];
  final List<TextEditingController> _mapNameControllers = [];
  final List<bool> _showDeleteIcon = [];

  TextEditingController _newMapNameController = TextEditingController();
  Map<String, LatLng> _newCoordinates = {};
  late String _newCoordinatesText;
  static const String coordinatesPlaceholder = "(?, ?), (?, ?)";

  bool showMap = false;
  bool _loadingData = true;

  String _helpText = '';
  static const String helpTextNorthWest =
      "Klikk og hold på kartet for å markere nordvestlig hjørne av beiteområdet";
  static const String helpTextSouthEast =
      "Klikk og hold på kartet for å markere sørøstlig hjørne av beiteområdet";
  static const String helpTextSave =
      "Klikk på lagre-knappen når du har skrevet inn navn på kartområdet";
  static const String secondMarkerIncorrectlyPlacedText =
      "Sørøstlig hjørne må være sørøst for nordvest-markøren. Klikk og hold på kartet på nytt for å markere sørøstlig hjørne av beiteområdet";

  static const int graphicalDecimalAmount = 4;
  static const int databaseDecimalAmount = 6;

  final TextStyle largerTextStyle = const TextStyle(fontSize: 18);
  final TextStyle columnNameStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();

    _newCoordinatesText = coordinatesPlaceholder;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _readMapData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: [
      Flexible(
          flex: 2,
          child: _loadingData
              ? Text(
                  'Laster data...',
                  style: largerTextStyle,
                )
              : SingleChildScrollView(
                  child: DataTable(
                      border: TableBorder.symmetric(),
                      showCheckboxColumn: false,
                      columns: _tableColumns(),
                      rows: _existingMapRows() + [_newMapRow()]))),
      const SizedBox(height: 10),
      _helpTextWidgets(),
      const SizedBox(height: 10),
      if (showMap)
        Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child:
                DefineMap(_onCornerMarked, _secondMarkerIncorrectlyPlacedText))
    ]));
  }

  void _onCornerMarked(Map<String, LatLng> points) {
    setState(() {
      if (points.length == 1) {
        _helpText = helpTextSouthEast;
        setState(() {
          _newCoordinatesText =
              '(${points['northWest']!.latitude.toStringAsFixed(graphicalDecimalAmount)}, '
              '${points['northWest']!.longitude.toStringAsFixed(graphicalDecimalAmount)})';
        });
      } else {
        setState(() {
          _helpText = helpTextSave;
          _newCoordinatesText =
              '(${points['northWest']!.latitude.toStringAsFixed(graphicalDecimalAmount)}, ${points['northWest']!.longitude.toStringAsFixed(graphicalDecimalAmount)}), '
              '(${points['southEast']!.latitude.toStringAsFixed(graphicalDecimalAmount)}, ${points['southEast']!.longitude.toStringAsFixed(graphicalDecimalAmount)})';
          _newCoordinates = points;
        });
      }
    });
  }

  void _secondMarkerIncorrectlyPlacedText() {
    setState(() {
      _helpText = secondMarkerIncorrectlyPlacedText;
    });
  }

  void _readMapData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    Map<String, Map<String, Map<String, double>>> dataMap;
    LinkedHashMap<String, dynamic>? linkedHashMap;
    TextEditingController textController;

    DocumentSnapshot<Object?> doc = await farmDoc.get();
    if (doc.exists) {
      linkedHashMap = doc.get('maps');

      if (linkedHashMap != null) {
        dataMap = _castFromDynamic(linkedHashMap);

        for (MapEntry<String, Map<String, Map<String, double>>> data
            in dataMap.entries) {
          _mapNames.add(data.key);
          textController = TextEditingController();
          textController.text = data.key;
          _mapNameControllers.add(textController);
          _mapCoordinates.add({
            'northWest': LatLng(data.value['northWest']!['latitude']!,
                data.value['northWest']!['longitude']!),
            'southEast': LatLng(data.value['southEast']!['latitude']!,
                data.value['southEast']!['longitude']!)
          });
          _showDeleteIcon.add(true);
        }
      }
    }
    setState(() {
      _loadingData = false;
    });
  }

  void _saveMapData() async {
    Map dataMap = <String, Map<String, Map<String, double>>>{};

    for (int i = 0; i < _mapNames.length; i++) {
      dataMap[_mapNames[i]] = {
        'northWest': {
          'latitude': double.parse(_mapCoordinates[i]['northWest']!
              .latitude
              .toStringAsFixed(databaseDecimalAmount)),
          'longitude': double.parse(_mapCoordinates[i]['northWest']!
              .longitude
              .toStringAsFixed(databaseDecimalAmount)),
        },
        'southEast': {
          'latitude': double.parse(_mapCoordinates[i]['southEast']!
              .latitude
              .toStringAsFixed(databaseDecimalAmount)),
          'longitude': double.parse(_mapCoordinates[i]['southEast']!
              .longitude
              .toStringAsFixed(databaseDecimalAmount)),
        }
      };
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    DocumentSnapshot<Object?> doc = await farmDoc.get();

    if (doc.exists) {
      farmDoc.update({'maps': dataMap});
    } else {
      farmDoc.set({
        'maps': dataMap,
        'name': null,
        'address': null,
        'ties': null,
        'eartags': null,
        'personnel': null
      });
    }
  }

  _castFromDynamic(LinkedHashMap<String, dynamic>? linkedHashMap) {
    return linkedHashMap!
        .map((key, value) => MapEntry(key, value as Map<String, dynamic>))
        .map((key, value) => MapEntry(
            key,
            value
                .map((key, value) =>
                    MapEntry(key, value as Map<String, dynamic>))
                .map((key, value) => MapEntry(
                    key,
                    value.map(
                        (key, value) => MapEntry(key, value as double))))));
  }

  void _saveChangedMap(int index) {
    String? newName = _mapNameControllers[index].text;
    if (newName.isNotEmpty) {
      if (!_mapNames.contains(newName)) {
        _mapNames[index] = newName;
        _saveMapData();
        setState(() {
          _showDeleteIcon[index] = true;
          _helpText = '';
        });
      } else {
        setState(() {
          _helpText = 'Kartnavnet $newName finnes allerede, skriv unikt navn';
        });
      }
    } else {
      setState(() {
        _helpText = 'Kartet må ha et navn';
      });
    }
  }

  void _saveNewMap() {
    if (_newCoordinates.length == 2) {
      String newMapName = _newMapNameController.text;
      if (newMapName.isNotEmpty) {
        if (!_mapNames.contains(newMapName)) {
          setState(() {
            _mapNames.add(newMapName);
            _mapCoordinates.add(_newCoordinates);
            _mapNameControllers.add(_newMapNameController);
            _showDeleteIcon.add(true);

            showMap = false;
            _newCoordinatesText = coordinatesPlaceholder;
            _newMapNameController = TextEditingController();

            _helpText = '';
          });
          _saveMapData();
        } else {
          setState(() {
            _helpText =
                'Kartnavnet $newMapName finnes allerede, skriv unikt navn';
          });
        }
      } else {
        setState(() {
          _helpText = 'Skriv inn kartnavn';
        });
      }
    }
  }

  BackdropFilter deleteMapDialog(BuildContext context, int index) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: AlertDialog(
          title: Text('Slette ${_mapNames[index]}?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop('dialog');
                  setState(() {
                    _mapNames.removeAt(index);
                    _mapCoordinates.removeAt(index);
                    _mapNameControllers.removeAt(index);
                  });
                  _saveMapData();
                },
                child: const Text('Ja, slett')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop('dialog');
                },
                child: const Text('Nei, ikke slett'))
          ],
        ));
  }

  List<DataColumn> _tableColumns() {
    return [
      DataColumn(
          label: Text(
        'Kartnavn',
        style: columnNameStyle,
      )),
      DataColumn(
          label: Row(children: [
        Text(
          'Koordinater',
          style: columnNameStyle,
        ),
        const Text(
          ' (NV), (SØ)',
        )
      ])),
      const DataColumn(
        label: Text(''),
      ),
    ];
  }

  List<DataRow> _existingMapRows() {
    return _mapNames
        .asMap()
        .entries
        .map((MapEntry<int, String> data) => DataRow(cells: [
              DataCell(
                  TextField(
                    controller: _mapNameControllers[data.key],
                    onChanged: (name) {
                      setState(() {
                        _showDeleteIcon[data.key] = false;
                      });
                    },
                  ),
                  showEditIcon: true),
              DataCell(_coordinatesCell(data.key)),
              DataCell(_deleteOrRenameMapCell(data.key))
            ]))
        .toList();
  }

  DataRow _newMapRow() {
    return DataRow(
        color:
            showMap ? MaterialStateProperty.all(Colors.green.shade100) : null,
        cells: [
          DataCell(
              showMap
                  ? TextField(
                      controller: _newMapNameController,
                      decoration: const InputDecoration(hintText: 'Skriv navn'))
                  : Container(),
              showEditIcon: showMap ? true : false),
          DataCell(showMap ? Text(_newCoordinatesText) : Container()),
          DataCell(_newMapCell())
        ]);
  }

  _newMapCell() {
    return showMap
        ? Row(children: [
            ElevatedButton(
              style: ButtonStyle(
                  fixedSize:
                      MaterialStateProperty.all(const Size.fromHeight(35))),
              child: Text('Lagre', style: largerTextStyle),
              onPressed: () => _saveNewMap(),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ButtonStyle(
                  fixedSize:
                      MaterialStateProperty.all(const Size.fromHeight(35)),
                  textStyle: MaterialStateProperty.all(largerTextStyle),
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
              child: const Text("Avbryt"),
              onPressed: () {
                setState(() {
                  showMap = false;
                  _newCoordinatesText = coordinatesPlaceholder;
                  _newMapNameController.clear();
                  _helpText = '';
                });
              },
            )
          ])
        : ElevatedButton(
            style: ButtonStyle(
                fixedSize:
                    MaterialStateProperty.all(const Size.fromHeight(35))),
            child: Text("Legg til", style: largerTextStyle),
            onPressed: () {
              setState(() {
                showMap = true;
                _helpText = helpTextNorthWest;
              });
            },
          );
  }

  Text _coordinatesCell(int index) {
    return Text('(' +
        _mapCoordinates[index]['northWest']!
            .latitude
            .toStringAsFixed(graphicalDecimalAmount) +
        ', ' +
        _mapCoordinates[index]['northWest']!
            .longitude
            .toStringAsFixed(graphicalDecimalAmount) +
        ')' +
        ', (' +
        _mapCoordinates[index]['southEast']!
            .latitude
            .toStringAsFixed(graphicalDecimalAmount) +
        ', ' +
        _mapCoordinates[index]['southEast']!
            .longitude
            .toStringAsFixed(graphicalDecimalAmount) +
        ')');
  }

  _deleteOrRenameMapCell(int index) {
    return _showDeleteIcon[index]
        ? IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.grey.shade800,
              size: 26,
            ),
            splashRadius: 22,
            hoverColor: Colors.red,
            onPressed: () => showDialog(
                context: context,
                builder: (_) => deleteMapDialog(context, index)))
        : Row(children: [
            ElevatedButton(
              style: ButtonStyle(
                  fixedSize:
                      MaterialStateProperty.all(const Size.fromHeight(35))),
              child: Text(
                "Lagre",
                style: largerTextStyle,
              ),
              onPressed: () => _saveChangedMap(index),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ButtonStyle(
                  fixedSize:
                      MaterialStateProperty.all(const Size.fromHeight(35)),
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
              child: Text(
                "Avbryt",
                style: largerTextStyle,
              ),
              onPressed: () => {
                _mapNameControllers[index].text = _mapNames[index],
                setState(() {
                  _showDeleteIcon[index] = true;
                  _helpText = '';
                })
              },
            ),
          ]);
  }

  _helpTextWidgets() {
    return (_helpText == helpTextNorthWest || _helpText == helpTextSouthEast)
        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              _helpText.substring(0, 14),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _helpText.substring(14, 38),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              _helpText.substring(38, 57),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _helpText.substring(57),
              style: const TextStyle(fontSize: 16),
            ),
          ])
        : Text(
            _helpText,
            style: const TextStyle(fontSize: 16),
          );
  }

  @override
  void dispose() {
    _newMapNameController.dispose();
    for (TextEditingController controller in _mapNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
