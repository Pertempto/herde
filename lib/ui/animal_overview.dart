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
    return DataStore.animalWidget(
      herdId: herdId,
      animalId: animalId,
      builder: (Herd? herd, Animal? animal) {
        List<Widget> children = [];

        if (animal != null) {
          children = [
            Text(animal.fullName, style: textTheme.headline4),
            const SizedBox(height: 12),
            TypeIcon(type: animal.type, showLabel: true),
            CategoryIcon(category: animal.category, showLabel: true),
            const SizedBox(height: 12),
          ];
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }
}
