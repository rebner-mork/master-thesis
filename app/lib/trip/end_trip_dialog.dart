import 'package:app/utils/styles.dart';
import 'package:flutter/material.dart';

// 0: discard, 1 or null: continue, 2: end trip
class EndTripDialog extends StatelessWidget {
  const EndTripDialog({Key? key, required this.isConnected}) : super(key: key);

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: Text(
          isConnected
              ? "Fullfør og last opp oppsynstur?"
              : "Fullfør og arkiver oppsynstur på enheten?",
          textAlign: TextAlign.center,
        ),
        children: [
          const SizedBox(
            height: 10,
          ),
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            size: 80,
            color: Colors.grey,
          ),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(isConnected
                    ? "Tilkoblet nettverk"
                    : "Oppsynsturen lagres lokalt og lastes opp når enheten er tilkoblet nettverk."),
              )),
          const SizedBox(
            height: 30,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SimpleDialogOption(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Center(
                    child: Text('Forkast',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: okDialogButtonTextStyle.fontSize,
                            fontWeight: okDialogButtonTextStyle.fontWeight))),
                onPressed: () => {Navigator.pop(context, 0)}),
            SimpleDialogOption(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Center(
                    child:
                        Text("Fortsett", style: cancelDialogButtonTextStyle)),
                onPressed: () => Navigator.pop(context, 1)),
            SimpleDialogOption(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Center(
                  child: Text(
                "Fullfør",
                style: okDialogButtonTextStyle,
              )),
              onPressed: () => Navigator.pop(context, 2),
            ),
          ]),
        ]);
  }
}

// 0: discard, 1 or null: continue, 2: end trip
Future<int?> showEndTripDialog(BuildContext context, connected) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EndTripDialog(
          isConnected: connected,
        );
      });
}
