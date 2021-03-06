import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web/my_page/define_ties/tie_or_eartag_dropdown.dart';
import 'package:web/utils/constants.dart';
import 'package:web/utils/custom_widgets.dart';
import 'package:web/utils/styles.dart';

class MyEartags extends StatefulWidget {
  const MyEartags({Key? key}) : super(key: key);

  @override
  State<MyEartags> createState() => _MyEartagsState();
}

class _MyEartagsState extends State<MyEartags> {
  _MyEartagsState();

  List<Color> _eartagColors = [];
  List<bool> _eartagOwners = [];
  List<Color?> _oldEartagColors = [];
  List<bool> _oldEartagOwners = [];

  bool _loadingData = true;
  bool _valuesChanged = false;
  bool _equalValues = false;
  bool _eartagsAdded = false;
  bool _eartagsDeleted = false;
  String _helpText = '';

  static const String dataSavedText = 'Øremerker er lagret';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _readEartagData();
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
                      const Text('Øremerker', style: pageHeadlineTextStyle),
                      const SizedBox(height: 10),
                      const Text(
                          'Her kan du legge til øremerker som oppsynspersonell kan møte på under oppsynstur.',
                          style: pageInfoTextStyle),
                      const Text(
                          'Oppsynspersonell kan ikke registrere andre øremerker enn de som er lagt til her.',
                          style: pageInfoTextStyle),
                      DataTable(
                        border: TableBorder.symmetric(),
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Øremerke',
                            style: dataColumnTextStyle,
                          )),
                          DataColumn(
                              label: Text(
                            'Eier',
                            style: dataColumnTextStyle,
                          )),
                          DataColumn(label: Text('')),
                        ],
                        rows: _eartagColors.length <
                                possibleEartagColorStringToKey.length
                            ? _eartagRows() + [_newEartagRow()]
                            : _eartagRows(),
                      )
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      _helpText,
                      style: TextStyle(
                          fontSize: 17,
                          color:
                              _helpText == dataSavedText ? Colors.green : null),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    if (_valuesChanged) _saveOrDeleteButtons(),
                  ]));
  }

  List<DataRow> _eartagRows() {
    return _eartagColors
        .asMap()
        .entries
        .map((MapEntry<int, Color> data) => DataRow(cells: [
              _eartagCell(index: data.key, color: data.value),
              _ownerCell(index: data.key, isOwner: _eartagOwners[data.key]),
              DataCell(IconButton(
                icon: Icon(Icons.delete, color: Colors.grey.shade800, size: 26),
                splashRadius: 22,
                hoverColor: Colors.red,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => Padding(
                          padding: const EdgeInsets.only(left: 128),
                          child: _deleteEartagDialog(context, data.key)));
                },
              ))
            ]))
        .toList();
  }

  DataRow _newEartagRow() {
    return DataRow(cells: [
      DataCell.empty,
      DataCell.empty,
      DataCell(FloatingActionButton(
        mini: true,
        child: const Icon(Icons.add, size: 26),
        onPressed: _onEartagAdded,
      ))
    ]);
  }

  DataCell _eartagCell({required int index, required Color color}) {
    return DataCell(Container(
        color: !_eartagsAdded &&
                !_eartagsDeleted &&
                _eartagColors[index] != _oldEartagColors[index]
            ? Colors.green.shade100
            : null,
        constraints: const BoxConstraints(minWidth: 115),
        child: Row(children: [
          SizedBox(
            width: 140,
            child: TieOrEartagDropdownButton(
                selectedColor: color,
                colors: possibleEartagColorStringToKey.keys
                    .map((String value) => Color(int.parse(value, radix: 16)))
                    .toList(),
                onChanged: (Color? newColor) {
                  _onColorChanged(
                      newColor: newColor!, index: index, ownColor: color);
                },
                isTie: false),
          ),
        ])));
  }

  DataCell _ownerCell({required int index, required bool isOwner}) {
    return DataCell(Container(
        color: !_eartagsAdded &&
                !_eartagsDeleted &&
                _eartagOwners[index] != _oldEartagOwners[index]
            ? Colors.green.shade100
            : null,
        constraints: const BoxConstraints(minHeight: 50),
        child: Row(
          children: [
            ChoiceChip(
              label: Text(
                'Meg',
                style: isOwner ? dataCellBoldTextStyle : dataCellTextStyle,
              ),
              selected: isOwner,
              selectedColor: Colors.green.shade400,
              labelStyle: isOwner ? dataCellBoldTextStyle : null,
              onSelected: (value) {
                if (!isOwner) {
                  setState(() {
                    _eartagOwners[index] = true;
                    _valuesChanged = true;
                  });
                }
              },
            ),
            ChoiceChip(
              label: Text(
                'Annen',
                style: !isOwner ? dataCellBoldTextStyle : dataCellTextStyle,
              ),
              selected: !isOwner,
              selectedColor: Colors.orange.shade300,
              labelStyle: !isOwner ? dataCellBoldTextStyle : null,
              onSelected: (value) {
                if (isOwner) {
                  setState(() {
                    _eartagOwners[index] = false;
                    _valuesChanged = true;
                  });
                }
              },
            )
          ],
        )));
  }

  void _onEartagAdded() {
    setState(() {
      _eartagColors.add(Color(
          int.parse(possibleEartagColorStringToKey.keys.first, radix: 16)));
      _eartagOwners.add(true);
      _valuesChanged = true;
      _eartagsAdded = true;

      _checkEqualColors();
    });
  }

  void _onColorChanged(
      {required Color newColor, required int index, required Color ownColor}) {
    if (newColor != ownColor) {
      setState(() {
        _eartagColors[index] = newColor;
        _valuesChanged = true;

        _checkEqualColors();
      });
    }
  }

  void _checkEqualColors() {
    if (_eartagColors.toSet().length < _eartagColors.length) {
      _helpText = 'Øremerkefarge må være unik';
      _equalValues = true;
    } else {
      _helpText = '';
      _equalValues = false;
    }
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
                      _oldEartagColors = List.from(_eartagColors),
                      _oldEartagOwners = List.from(_eartagOwners),
                      setState(() {
                        _valuesChanged = false;
                        _helpText = dataSavedText;
                        _eartagsDeleted = false;
                        _eartagsAdded = false;
                      }),
                      _saveEartagData()
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
              _eartagsAdded = false;
              _eartagsDeleted = false;
              _eartagColors = List.from(_oldEartagColors);
              _eartagOwners = List.from(_oldEartagOwners);
              _helpText = '';
            })
          },
        ),
      ])
    ]);
  }

  BackdropFilter _deleteEartagDialog(BuildContext context, int index) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: AlertDialog(
          title: Text(
              'Slette ${dialogColorToString[_eartagColors[index]]} øremerke?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop('dialog');
                  setState(() {
                    _eartagColors.removeAt(index);
                    _eartagOwners.removeAt(index);

                    _valuesChanged = true;
                    _eartagsDeleted = true;

                    _checkEqualColors();
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

  void _readEartagData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    Map<String, dynamic>? dataMap;

    DocumentSnapshot<Object?> doc = await farmDoc.get();
    if (doc.exists) {
      dataMap = doc.get('eartags');
      if (dataMap != null) {
        for (MapEntry<String, dynamic> data in dataMap.entries) {
          _eartagColors.add(Color(int.parse(data.key, radix: 16)));
          _eartagOwners.add(data.value as bool);
        }
      }
    }
    _oldEartagColors = List.from(_eartagColors);
    _oldEartagOwners = List.from(_eartagOwners);
    setState(() {
      _loadingData = false;
    });
  }

  void _saveEartagData() async {
    Map<String, bool> dataMap = {};

    for (int i = 0; i < _eartagColors.length; i++) {
      dataMap[_eartagColors[i].value.toRadixString(16)] = _eartagOwners[i];
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference farmCollection =
        FirebaseFirestore.instance.collection('farms');
    DocumentReference farmDoc = farmCollection.doc(uid);

    DocumentSnapshot<Object?> doc = await farmDoc.get();

    if (doc.exists) {
      farmDoc.update({'eartags': dataMap});
    } else {
      farmDoc.set({
        'name': null,
        'address': null,
        'farmNumber': null,
        'maps': null,
        'ties': null,
        'personnel': [FirebaseAuth.instance.currentUser!.email],
        'eartags': dataMap
      });
    }
  }
}
