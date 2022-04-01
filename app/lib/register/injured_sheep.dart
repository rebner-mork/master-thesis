import 'package:app/register/radio_button.dart';
import 'package:app/register/registration_input_headline.dart';
import 'package:app/register/tie_dropdown_item.dart';
import 'package:app/utils/custom_widgets.dart';
import 'package:app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../utils/map_utils.dart' as map_utils;

const double leftMargin = 40;

class RegisterInjuredSheep extends StatefulWidget {
  const RegisterInjuredSheep({required this.ties, Key? key}) : super(key: key);

  final Map<String, int?> ties;

  @override
  State<RegisterInjuredSheep> createState() => _RegisterInjuredSheepState();
}

class _RegisterInjuredSheepState extends State<RegisterInjuredSheep> {
  bool _isLoading = true;
  late LatLng _devicePosition;
  bool _isModerate = true;
  bool _isSevere = false;

  late final TextEditingController _startIdController;
  final TextEditingController _farmNumberController = TextEditingController();
  late final TextEditingController _individualNumberController;
  final TextEditingController _noteController = TextEditingController();

  late String _selectedTieColor;
  late Map<String, int?> _ties;

  late String _selectedInjuryType;
  static const List<String> injuryTypes = [
    'Annen',
    'Beinskade',
    'Hodeskade',
    'Blodutredning'
  ];

  @override
  void initState() {
    super.initState();

    _startIdController = TextEditingController(text: 'MT-NO');
    _individualNumberController = TextEditingController(text: '0');
    _selectedTieColor = Colors.transparent.value.toRadixString(16);
    _selectedInjuryType = injuryTypes.first;

    _ties = {...widget.ties};
    if (!_ties.keys.contains(Colors.transparent.value.toRadixString(16))) {
      _ties[Colors.transparent.value.toRadixString(16)] = null;
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getDevicePosition();
    });
  }

  Future<void> _getDevicePosition() async {
    _devicePosition = await map_utils.getDevicePosition();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _backButtonPressed() async {
    await cancelRegistrationDialog(context).then((value) => {
          if (value) {Navigator.pop(context)}
        });
  }

  Future<bool> _onWillPop() async {
    bool returnValue = false;
    await cancelRegistrationDialog(context)
        .then((value) => {returnValue = value});
    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrer skadd sau', style: appBarTextStyle),
          leading: BackButton(onPressed: _backButtonPressed),
        ),
        body: Form(
          onWillPop: _onWillPop,
          child: _isLoading
              ? const LoadingData()
              : SingleChildScrollView(
                  child: SizedBox(
                      height: 650,
                      child: Container(
                          margin: const EdgeInsets.only(left: leftMargin),
                          child: Column(
                            children: [
                              appbarBodySpacer(),
                              const RegistrationInputHeadline(
                                  title: 'Øremerke'),
                              inputFieldSpacer(),
                              Flexible(
                                  child: Row(children: [
                                SizedBox(
                                    width: 90,
                                    height: textFormFieldHeight,
                                    child: TextFormField(
                                        textAlign: TextAlign.center,
                                        controller: _startIdController,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder()))),
                                const SizedBox(width: 10),
                                SizedBox(
                                    width: 120,
                                    height: textFormFieldHeight,
                                    child: TextFormField(
                                        // TODO: validering
                                        textAlign: TextAlign.center,
                                        controller: _farmNumberController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(),
                                        decoration: const InputDecoration(
                                            labelText: 'Gårds-nr',
                                            border: OutlineInputBorder()))),
                                const SizedBox(width: 10),
                                SizedBox(
                                    width: 90,
                                    height: textFormFieldHeight,
                                    child: TextFormField(
                                        // TODO: validering
                                        textAlign: TextAlign.center,
                                        controller: _individualNumberController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(),
                                        decoration: const InputDecoration(
                                            labelText: 'ID-nr',
                                            border: OutlineInputBorder())))
                              ])),
                              inputFieldSpacer(),
                              const RegistrationInputHeadline(title: 'Slips'),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 205,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4))),
                                            child: DropdownButton<String>(
                                              underline: const SizedBox(),
                                              isExpanded: true,
                                              itemHeight: 60,
                                              iconSize: dropdownArrowSize,
                                              value: _selectedTieColor,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedTieColor = newValue!;
                                                });
                                              },
                                              items: _ties.keys
                                                  .map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String colorHex) =>
                                                          DropdownMenuItem(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            value: colorHex,
                                                            child:
                                                                TieDropDownItem(
                                                              colorHex:
                                                                  colorHex,
                                                            ),
                                                          ))
                                                  .toList(),
                                            ))),
                                    const SizedBox(width: 40),
                                  ]),
                              inputFieldSpacer(),
                              const RegistrationInputHeadline(title: 'Skade'),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(4))),
                                        child: DropdownButton(
                                            itemHeight: 60,
                                            underline: const SizedBox(),
                                            alignment: Alignment.center,
                                            iconSize: dropdownArrowSize,
                                            value: _selectedInjuryType,
                                            items: injuryTypes
                                                .map<DropdownMenuItem<String>>(
                                                    (String type) =>
                                                        DropdownMenuItem(
                                                            value: type,
                                                            child: Text(
                                                              type,
                                                              style:
                                                                  dropDownTextStyle,
                                                            )))
                                                .toList(),
                                            onChanged: (String? newType) {
                                              if (_selectedInjuryType !=
                                                  newType!) {
                                                setState(() {
                                                  _selectedInjuryType = newType;
                                                });
                                              }
                                            })),
                                    const SizedBox(width: leftMargin),
                                  ]),
                              inputFieldSpacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(children: [
                                    const Text(
                                      'Moderat',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    RadioButton(
                                        value: _isModerate,
                                        groupValue: !_isSevere,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            _isModerate = !_isModerate;
                                          });
                                        }),
                                  ]),
                                  const SizedBox(width: 20),
                                  Column(children: [
                                    const Text(
                                      'Alvorlig',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    RadioButton(
                                        value: _isSevere,
                                        groupValue: _isModerate,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            _isSevere = !_isSevere;
                                          });
                                        }),
                                  ]),
                                  const SizedBox(width: leftMargin)
                                ],
                              ),
                              const SizedBox(height: 8),
                              const RegistrationInputHeadline(title: 'Notat'),
                              inputFieldSpacer(),
                              Container(
                                  margin:
                                      const EdgeInsets.only(right: leftMargin),
                                  child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      maxLines: 3,
                                      controller: _noteController,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder())))
                            ],
                          )))),
        ),
        floatingActionButton:
            _isLoading ? null : completeRegistrationButton(context, () {}),
        floatingActionButtonLocation:
            MediaQuery.of(context).viewInsets.bottom == 0
                ? FloatingActionButtonLocation.centerFloat
                : FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  /*void _registerInjuredSheep() {
    Map<String, Object> data = {};
    data.addAll(gatherRegisteredData(_textControllers));
    data['timestamp'] = DateTime.now();
    data['devicePosition'] = {
      'latitude': _devicePosition.latitude,
      'longitude': _devicePosition.longitude
    };
    data['registrationPosition'] = {
      'latitude': widget.sheepPosition.latitude,
      'longitude': widget.sheepPosition.longitude
    };

    if (widget.onCompletedSuccessfully != null) {
      widget.onCompletedSuccessfully!(data);
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }*/
}
