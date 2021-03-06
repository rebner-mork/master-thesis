import 'package:flutter/material.dart';
import 'package:web/utils/styles.dart';

class SheepInfoTable extends StatelessWidget {
  const SheepInfoTable({required this.sheepData, Key? key}) : super(key: key);

  final Map<String, int> sheepData;

  @override
  Widget build(BuildContext context) {
    return Table(
        border: const TableBorder(horizontalInside: BorderSide(width: 0.5)),
        columnWidths: const {
          0: FixedColumnWidth(74),
          1: FixedColumnWidth(64),
          2: FixedColumnWidth(74),
          3: FixedColumnWidth(74),
          4: FixedColumnWidth(74),
          5: FixedColumnWidth(106)
        },
        children: [
          const TableRow(children: [
            Padding(
              padding: tableCellPadding,
              child: Text(
                'Totalt',
                style: tableRowDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: tableCellPadding,
              child: Text(
                'Lam',
                style: tableRowDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: tableCellPadding,
              child: Text(
                'Hvite',
                style: tableRowDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: tableCellPadding,
              child: Text(
                'Brune',
                style: tableRowDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: tableCellPadding,
              child: Text(
                'Svarte',
                style: tableRowDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: tableCellPadding,
              child: Text(
                'Svart hode',
                style: tableRowDescriptionTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ]),
          TableRow(children: [
            ...sheepData.entries
                .map((MapEntry<String, int> mapEntry) => Padding(
                      padding: tableCellPadding,
                      child: Text(
                        mapEntry.value.toString(),
                        style: mapEntry.key == sheepData.keys.first
                            ? tableRowDescriptionTextStyle
                            : tableRowTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ]),
        ]);
  }
}
