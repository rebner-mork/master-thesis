import 'dart:collection';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web/my_page/define_ties/tie_or_eartag_dropdown.dart';
import 'package:web/utils/constants.dart';
import 'package:web/utils/custom_widgets.dart';
import 'package:web/utils/styles.dart';

class MyTies extends StatefulWidget {
  const MyTies({Key? key}) : super(key: key);

  @override
  State<MyTies> createState() => _MyTiesState();
}

class _MyTiesState extends State<MyTies> {
  _MyTiesState();

  List<Color> _tieColors = [];
  List<int> _tieMeaning = [];
  List<Color?> _oldTieColors = [];
  List<int?> _oldTieMeaning = [];

  bool _loadingData = true;
  bool _valuesChanged = false;
  bool _equalValues = false;
  bool _tiesAdded = false;
  bool _tiesDeleted = false;
  String _helpText = '';

  Map<String, String> feedback = {
    'nonUniqueColor': 'Slipsfarge må være unik',
    'nonUniqueTieMeaning': 'Antall lam må være unikt',
    'dataSaved': 'Slips er lagret'
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _readTieData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
            children: _loadingData
                ? const [SizedBox(height: 20), LoadingData()]
                : [
                    Column(children: [
                      const SizedBox(height: 20),
                      const Text('Mine slips', style: pageHeadlineTextStyle),
                      const SizedBox(height: 10),
                      const Text(
                          'Her kan du legge til slips som brukes på søyene dine.',
                          style: pageInfoTextStyle),
                      const Text(
                          'Oppsynspersonell kan ikke registrere andre slips enn de som er lagt til her.',
                          style: pageInfoTextStyle),
                      DataTable(
                        border: TableBorder.symmetric(),
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Slipsfarge',
                            style: dataColumnTextStyle,
                          )),
                          DataColumn(
                              label: Text(
                            'Antall lam',
                            style: dataColumnTextStyle,
                          )),
                          DataColumn(label: Text('')),
                        ],
                        rows: _tieColors.length <
                                possibleTieColorStringToKey.length
                            ? _tieRows() + _newTieRow()
                            : _tieRows(),
                      )
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      _helpText,
                      style: TextStyle(
                          fontSize: 17,
                          color: _helpText == feedback['dataSaved']!
                              ? Colors.green
                              : null),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    if (_valuesChanged) _saveOrDeleteButtons(),
                  ]));
  }

  DataCell _tieCell({required int index, required Color color}) {
    return DataCell(Container(
        color: !_tiesAdded &&
                !_tiesDeleted &&
                _tieColors[index] != _oldTieColors[index]
            ? Colors.green.shade100
            : null,
        constraints: const BoxConstraints(minWidth: 115),
        child: Row(children: [
          SizedBox(
            width: 140,
            child: TieOrEartagDropdownButton(
                selectedColor: color,
                colors: possibleTieColorStringToKey.keys
                    .map((String value) => Color(int.parse(value, radix: 16)))
                    .toList(),
                onChanged: (Color? newColor) {
                  _onColorChanged(
                      newColor: newColor!, index: index, ownColor: color);
                },
                isTie: true),
          ),
        ])));
  }

  DataCell _lambCell(int index) {
    return DataCell(Container(
        color: !_tiesAdded &&
                !_tiesDeleted &&
                _tieMeaning[index] != _oldTieMeaning[index]
            ? Colors.green.shade100
            : null,
        child: Center(
            child: DropdownButton<int>(
          iconSize: dropdownArrowSize,
          value: _tieMeaning[index],
          items: <int>[0, 1, 2, 3, 4, 5, 6]
              .map((int value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: dataCellTextStyle,
                  )))
              .toList(),
          onChanged: (int? newValue) {
            _onLambsChanged(newValue, index);
          },
        ))));
  }

  List<DataRow> _tieRows() {
    return _tieColors
        .asMap()
        .entries
        .map((MapEntry<int, Color> data) => DataRow(cells: [
              _tieCell(index: data.key, color: data.value),
              _lambCell(data.key),
              _deleteCell(data.key)
            ]))
        .toList();
  }

  List<DataRow> _newTieRow() {
    return [
      DataRow(cells: [
        DataCell.empty,
        DataCell.empty,
        DataCell(FloatingActionButton(
          mini: true,
          child: const Icon(
            Icons.add,
            size: 26,
          ),
          onPressed: _onTieAdded,
        ))
      ])
    ];
  }

  DataCell _deleteCell(int index) {
    return DataCell(IconButton(
      icon: Icon(Icons.delete, color: Colors.grey.shade800, size: 26),
      splashRadius: 22,
      hoverColor: Colors.red,
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) => Padding(
                padding: const EdgeInsets.only(left: 128),
                child: _deleteTieDialog(context, index)));
      },
    ));
  }

  Column _saveOrDeleteButtons() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
            style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(const Size.fromHeight(35)),
                backgroundColor: MaterialStateProperty.all(
                    _equalValues ? Colors.grey : Colors.green)),
            child: const Text(
              "Lagre",
              style: buttonTextStyle,
              textAlign: TextAlign.center,
            ),
            onPressed: () => {
                  if (!_equalValues)
                    {
                      _oldTieColors = List.from(_tieColors),
                      _oldTieMeaning = List.from(_tieMeaning),
                      setState(() {
                        _valuesChanged = false;
                        _helpText = feedback['dataSaved']!;
                        _tiesDeleted = false;
                        _tiesAdded = false;
                      }),
                      _saveTieData()
                    }
                }),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size.fromHeight(35)),
              backgroundColor: MaterialStateProperty.all(Colors.red)),
          child: const Text(
            "Avbryt",
            style: buttonTextStyle,
          ),
          onPressed: () => {
            setState(() {
              _valuesChanged = false;
              _tieColors = List.from(_oldTieColors);
              _tieMeaning = List.from(_oldTieMeaning);
              _helpText = '';
              _tiesAdded = false;
              _tiesDeleted = false;
            })
          },
        ),
      ])
    ]);
  }

  BackdropFilter _deleteTieDialog(BuildContext context, int index) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: AlertDialog(
          title:
              Text('Slette ${dialogColorToString[_tieColors[index]]} slips?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop('dialog');
                  setState(() {
                    _tieColors.removeAt(index);
                    _tieMeaning.removeAt(index);

                    _valuesChanged = true;
                    _tiesDeleted = true;

                    _checkEqualColors();
                    if (_helpText == '') {
                      _checkEqualLambAmount();
                    }
                  });
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

  void _onColorChanged(
      {required Color newColor, required int index, required Color ownColor}) {
    _helpText = '';

    if (newColor != ownColor) {
      setState(() {
        _tieColors[index] = newColor;
        _valuesChanged = true;

        _checkEqualColors();
      });
    }
  }

  void _checkEqualColors() {
    if (_tieColors.toSet().length < _tieColors.length) {
      _helpText = 'Slipsfarge må være unik';
      _equalValues = true;
    } else if (_tieMeaning.toSet().length == _tieMeaning.length) {
      _helpText = '';
      _equalValues = false;
    } else {
      _helpText = feedback['nonUniqueTieMeaning']!;
    }
  }

  void _onLambsChanged(int? newValue, int index) {
    _helpText = '';
    if (newValue! != _tieMeaning[index]) {
      setState(() {
        _tieMeaning[index] = newValue;
        _valuesChanged = true;

        _checkEqualLambAmount();
      });
    }
  }

  void _checkEqualLambAmount() {
    if (_tieMeaning.toSet().length < _tieMeaning.length) {
      _helpText = 'Antall lam må være unikt';
      _equalValues = true;
    } else if (_tieColors.toSet().length == _tieColors.length) {
      _helpText = '';
      _equalValues = false;
    } else {
      _helpText = feedback['nonUniqueColor']!;
    }
  }

  void _onTieAdded() {
    setState(() {
      _tieColors.add(
          Color(int.parse(possibleTieColorStringToKey.keys.last, radix: 16)));
      _tieMeaning.add(0);
      _valuesChanged = true;
      _tiesAdded = true;

      _checkEqualColors();
      if (_helpText == '') {
        _checkEqualLambAmount();
      }
    });
  }

  void _useDefaultTies() {
    for (MapEntry<Color, int> data in defaultTieMap.entries) {
      _tieColors.add(data.key);
      _tieMeaning.add(data.value);
    }
    _saveTieData();
  }

  void _readTieData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    LinkedHashMap<String, dynamic>? dataMap;

    DocumentSnapshot<Object?> doc = await farmDoc.get();

    if (doc.exists) {
      dataMap = doc.get('ties');
      if (dataMap != null) {
        for (MapEntry<String, dynamic> data in dataMap.entries) {
          _tieColors.add(Color(int.parse(data.key, radix: 16)));
          _tieMeaning.add(data.value as int);
        }
      } else {
        _useDefaultTies();
      }
    } else {
      _useDefaultTies();
    }
    _oldTieColors = List.from(_tieColors);
    _oldTieMeaning = List.from(_tieMeaning);
    setState(() {
      _loadingData = false;
    });
  }

  void _saveTieData() async {
    Map<String, int> dataMap = <String, int>{};

    for (int i = 0; i < _tieColors.length; i++) {
      dataMap[_tieColors[i].value.toRadixString(16)] = _tieMeaning[i];
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    DocumentSnapshot<Object?> doc = await farmDoc.get();

    if (doc.exists) {
      farmDoc.update({'ties': dataMap});
    } else {
      farmDoc.set({
        'name': null,
        'address': null,
        'farmNumber': null,
        'maps': null,
        'eartags': null,
        'personnel': [FirebaseAuth.instance.currentUser!.email],
        'ties': dataMap
      });
    }
  }
}
