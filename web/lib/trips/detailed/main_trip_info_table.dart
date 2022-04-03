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
      required this.personnelName,
      Key? key})
      : super(key: key);

  final String personnelName;
  final DateTime startTime;
  final DateTime stopTime;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        // Combined width should match 486 (combined width of SheepInfoTable)
        0: const FixedColumnWidth(80),
        1: textSize(personnelName, tableRowTextStyle).width > 330
            ? FixedColumnWidth(textSize(personnelName, tableRowTextStyle).width)
            : const FixedColumnWidth(406)
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
                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${stopTime.hour.toString().padLeft(2, '0')}:${stopTime.minute.toString().padLeft(2, '0')}',
                  style: textStyle))
        ]),
        TableRow(children: [
          Padding(
              padding: tableCellPadding,
              child: Text('Gått av', style: decsriptionTextStyle)),
          Padding(
              padding: tableCellPadding,
              child: Text(
                personnelName,
                style: textStyle,
              ))
        ]),
      ],
    );
  }
}
