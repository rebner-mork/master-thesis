import 'package:flutter/material.dart';
import 'package:web/utils/other.dart';
import 'package:web/utils/styles.dart';

TextStyle textStyle = const TextStyle(fontSize: 19);
TextStyle decsriptionTextStyle =
    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold);

class MainTripInfoTable extends StatelessWidget {
  const MainTripInfoTable(
      {required this.startTime,
      required this.stopTime,
      required this.email,
      required this.phone,
      Key? key})
      : super(key: key);

  final String email;
  final String phone;
  final DateTime startTime;
  final DateTime stopTime;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        // Combined width should match 'idealWidth' (410) in detailed_trip.dart
        0: const FixedColumnWidth(80),
        1: textSize(email, tableRowTextStyle).width > 330
            ? FixedColumnWidth(textSize(email, tableRowTextStyle).width)
            : const FixedColumnWidth(330)
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          Padding(
              padding: tableCellPadding,
              child: Text('Tid', style: decsriptionTextStyle)),
          Padding(
              padding: tableCellPadding,
              child: Text(
                  '${startTime.hour}:${startTime.minute} - ${stopTime.hour}:${stopTime.minute}',
                  style: textStyle))
        ]),
        TableRow(children: [
          Padding(
              padding: tableCellPadding,
              child: Text('Gått av', style: decsriptionTextStyle)),
          Padding(
              padding: tableCellPadding,
              child: Text(
                email,
                style: textStyle,
              ))
        ]),
      ],
    );
  }
}
