import 'dart:collection';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  List<int> _tieLambs = [];
  List<Color?> _oldTieColors = [];
  List<int?> _oldTieLambs = [];

  bool _loadingData = true;
  bool _valuesChanged = false;
  bool _equalValues = false;
  bool _tiesAdded = false;
  bool _tiesDeleted = false;
  String _helpText = '';

  static const String nonUniqueColorFeedback = 'Slipsfarge må være unik';
  static const String nonUniqueLambsFeedback = 'Antall lam må være unikt';
  static const String dataSavedFeedback = 'Data er lagret';

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
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [
              _loadingData
                  ? const Text(
                      'Laster data...',
                      style: TextStyle(fontSize: 18),
                    )
                  : DataTable(
                      border: TableBorder.symmetric(),
                      columns: [
                        DataColumn(
                            label: Text(
                          'Slipsfarge',
                          style: columnNameTextStyle,
                        )),
                        DataColumn(
                            label: Text(
                          'Antall lam',
                          style: columnNameTextStyle,
                        )),
                        const DataColumn(label: Text('')),
                      ],
                      rows: _tieRows() + _newTieRow(),
                    ),
              const SizedBox(height: 10),
              Text(
                _helpText,
                style: TextStyle(
                    fontSize: 17,
                    color:
                        _helpText == dataSavedFeedback ? Colors.green : null),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (_valuesChanged) _saveOrDeleteButtons(),
            ])));
  }

  DataCell _tieCell(int index, Color color) {
    return DataCell(Container(
        color: !_tiesAdded &&
                !_tiesDeleted &&
                _tieColors[index] != _oldTieColors[index]
            ? Colors.orange.shade100
            : null,
        constraints: const BoxConstraints(minWidth: 115),
        child: Row(children: [
          DropdownButton<DropdownIcon>(
              value: DropdownIcon(color),
              items: possibleColors
                  .map((Color color) => DropdownMenuItem<DropdownIcon>(
                      value: DropdownIcon(color),
                      child: DropdownIcon(color).icon))
                  .toList(),
              onChanged: (DropdownIcon? newIcon) {
                _onColorChanged(newIcon!.icon.color!, index, color);
              }),
          const SizedBox(width: 8),
          Text(
            colorValueToString[color.value].toString(),
            style: largerTextStyle,
          ),
        ])));
  }

  DataCell _lambCell(int index) {
    return DataCell(Container(
        color: !_tiesAdded &&
                !_tiesDeleted &&
                _tieLambs[index] != _oldTieLambs[index]
            ? Colors.orange.shade100
            : null,
        child: Center(
            child: DropdownButton<int>(
          value: _tieLambs[index],
          items: <int>[0, 1, 2, 3, 4, 5, 6]
              .map((int value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: largerTextStyle,
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
              _tieCell(data.key, data.value),
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
            context: context, builder: (_) => _deleteTieDialog(context, index));
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
            child: Text(
              "Lagre",
              style: largerTextStyle,
              textAlign: TextAlign.center,
            ),
            onPressed: () => {
                  if (!_equalValues)
                    {
                      _oldTieColors = _tieColors,
                      _oldTieLambs = _tieLambs,
                      setState(() {
                        _valuesChanged = false;
                        _helpText = dataSavedFeedback;
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
          child: Text(
            "Avbryt",
            style: largerTextStyle,
          ),
          onPressed: () => {
            setState(() {
              _valuesChanged = false;
              _tieColors = List.from(_oldTieColors);
              _tieLambs = List.from(_oldTieLambs);
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
                    _tieLambs.removeAt(index);

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

  void _onColorChanged(Color newColor, int index, Color ownColor) {
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
    } else if (_tieLambs.toSet().length == _tieLambs.length) {
      _helpText = '';
      _equalValues = false;
    } else {
      _helpText = nonUniqueLambsFeedback;
    }
  }

  void _onLambsChanged(int? newValue, int index) {
    _helpText = '';
    if (newValue! != _tieLambs[index]) {
      setState(() {
        _tieLambs[index] = newValue;
        _valuesChanged = true;

        _checkEqualLambAmount();
      });
    }
  }

  void _checkEqualLambAmount() {
    if (_tieLambs.toSet().length < _tieLambs.length) {
      _helpText = 'Antall lam må være unikt';
      _equalValues = true;
    } else if (_tieColors.toSet().length == _tieColors.length) {
      _helpText = '';
      _equalValues = false;
    } else {
      _helpText = nonUniqueColorFeedback;
    }
  }

  void _onTieAdded() {
    setState(() {
      _tieColors.add(possibleColors.last);
      _tieLambs.add(0);
      _valuesChanged = true;
      _tiesAdded = true;

      _checkEqualColors();
      if (_helpText == '') {
        _checkEqualLambAmount();
      }
    });
  }

  void _readTieData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    LinkedHashMap<String, dynamic> dataMap;

    await farmDoc.get().then((doc) => {
          if (doc.exists)
            {
              dataMap = doc.get('ties'),
              for (MapEntry<String, dynamic> data in dataMap.entries)
                {
                  _tieColors.add(Color(int.parse(data.key, radix: 16))),
                  _tieLambs.add(data.value as int)
                },
            }
          else
            {
              for (MapEntry<Color, int> data in defaultTieMap.entries)
                {_tieColors.add(data.key), _tieLambs.add(data.value)},
            },
          _oldTieColors = List.from(_tieColors),
          _oldTieLambs = List.from(_tieLambs),
          setState(() {
            _loadingData = false;
          })
        });
  }

  void _saveTieData() async {
    Map<String, int> dataMap = <String, int>{};

    for (int i = 0; i < _tieColors.length; i++) {
      dataMap[_tieColors[i].value.toRadixString(16)] = _tieLambs[i];
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    await farmDoc.get().then((doc) => {
          if (doc.exists)
            {
              farmDoc.update({'ties': dataMap})
            }
          else
            {
              farmDoc.set({
                'name': null,
                'address': null,
                'maps': null,
                'ties': dataMap
              })
            }
        });
  }
}
