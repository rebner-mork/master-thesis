import 'package:flutter/material.dart';
import 'package:web/trips/detailed/registration_details/injured_sheep_registration_details.dart';
import 'package:web/utils/styles.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class InjuredSheepTable extends StatelessWidget {
  const InjuredSheepTable({required this.injuredSheep, Key? key})
      : super(key: key);

  final List<Map<String, dynamic>> injuredSheep;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.symmetric(
        inside: const BorderSide(width: 0.5),
      ),
      columnWidths: const {
        0: FixedColumnWidth(150),
        1: FixedColumnWidth(60),
        2: FixedColumnWidth(125),
        3: FixedColumnWidth(110),
        4: FixedColumnWidth(70)
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        const TableRow(children: [
          Padding(
              padding: tableCellPadding,
              child: Text('Øremerke',
                  style: tableRowDescriptionTextStyle,
                  textAlign: TextAlign.center)),
          Padding(
              padding: tableCellPadding,
              child: Text('Slips',
                  style: tableRowDescriptionTextStyle,
                  textAlign: TextAlign.center)),
          Padding(
              padding: tableCellPadding,
              child: Text('Type',
                  style: tableRowDescriptionTextStyle,
                  textAlign: TextAlign.center)),
          Padding(
              padding: tableCellPadding,
              child: Text('Alvorlighet',
                  style: tableRowDescriptionTextStyle,
                  textAlign: TextAlign.center)),
          Padding(
              padding: tableCellPadding,
              child: Text('Notat',
                  style: tableRowDescriptionTextStyle,
                  textAlign: TextAlign.center)),
        ]),
        ...injuredSheep.map((Map<String, dynamic> registration) {
          List<String> eartag = (registration['eartag'] as String).split('-');

          return TableRow(
            children: [
              Padding(
                  padding: tableCellPadding,
                  child: Text(
                    '${eartag[0]}-${eartag[1]}\n${eartag[2]}-${eartag[3]}',
                    style: tableRowTextStyle,
                    textAlign: TextAlign.center,
                  )),
              Padding(
                  padding: tableCellPadding,
                  child: Icon(
                    registration['tieColor'] == '0'
                        ? Icons.disabled_by_default
                        : FontAwesome5.black_tie,
                    size: 24,
                    color: registration['tieColor'] == '0'
                        ? Colors.grey
                        : Color(int.parse(registration['tieColor'], radix: 16)),
                  )),
              Padding(
                  padding: tableCellPadding,
                  child: Text(
                    '${registration['injuryType']}',
                    style: tableRowTextStyle,
                    textAlign: TextAlign.center,
                  )),
              Padding(
                  padding: tableCellPadding,
                  child: Text(
                    '${registration['severity']}',
                    style: tableRowTextStyle,
                    textAlign: TextAlign.center,
                  )),
              Padding(
                  padding: tableCellPadding,
                  child: IconButton(
                      icon: const Icon(Icons.description),
                      color: Colors.grey.shade700,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                InjuredSheepRegistrationDetails(
                                    registration: registration));
                      }))
            ],
          );
        })
      ],
    );
  }
}
