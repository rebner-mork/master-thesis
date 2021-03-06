import 'package:flutter/material.dart';
import 'package:web/trips/detailed/registration_details/cadaver_registration_details.dart';
import 'package:web/trips/detailed/registration_details/injured_sheep_registration_details.dart';
import 'package:web/trips/detailed/registration_details/note_registration_details.dart';
import 'package:web/trips/detailed/registration_details/predator_registration_details.dart';
import 'package:web/trips/detailed/registration_details/sheep_registration_details.dart';

class RegistrationDetails extends StatelessWidget {
  const RegistrationDetails({required this.registration, Key? key})
      : super(key: key);

  final Map<String, dynamic> registration;

  @override
  Widget build(BuildContext context) {
    switch (registration['type']) {
      case 'sheep':
        return SheepRegistrationDetails(registration: registration);
      case 'injuredSheep':
        return InjuredSheepRegistrationDetails(registration: registration);
      case 'cadaver':
        return CadaverRegistrationDetails(registration: registration);
      case 'predator':
        return PredatorRegistrationDetails(registration: registration);
      case 'note':
        return NoteRegistrationDetails(registration: registration);
    }

    return const SimpleDialog(children: [Text('Det har skjedd en feil')]);
  }
}
