import 'package:flutter/material.dart';

import '../data/animal.dart';
import '../data/data_store.dart';
import '../data/herd.dart';
import 'category_icon.dart';
import 'type_icon.dart';

class AnimalOverview extends StatelessWidget {
  final String animalId;
  final String herdId;

  const AnimalOverview({required this.animalId, required this.herdId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle textStyle = textTheme.headline6!.copyWith(fontWeight: FontWeight.w400);
    return DataStore.animalWidget(
      herdId: herdId,
      animalId: animalId,
      builder: (Herd? herd, Animal? animal) {
        List<Widget> children = [];

        if (animal != null) {
          children = [
            Text(animal.fullName, style: textTheme.headline4),
            const SizedBox(height: 12),
            TypeIcon(type: animal.typeName, showLabel: true),
            CategoryIcon(typeName: animal.typeName, categoryName: animal.categoryName, showLabel: true),
          ];
          if (animal.birthDate != null) {
            children.add(Text('Born: ${animal.birthDateString} (${animal.ageString})', style: textStyle));
          }
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }
}
