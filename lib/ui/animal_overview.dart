import 'package:flutter/material.dart';

import '../data/animal.dart';
import '../data/category.dart';
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
            Text(animal.fullName, style: textTheme.headline5),
            const SizedBox(height: 12),
            TypeIcon(type: animal.typeName, showLabel: true),
            CategoryIcon(typeName: animal.typeName, categoryName: animal.categoryName, showLabel: true),
          ];
          if (animal.birthDate != null) {
            children.add(Text('Born: ${animal.birthDateString} (${animal.ageString})', style: textStyle));
          }
          if (animal.fatherId != null && herd!.animals[animal.fatherId] != null) {
            Animal father = herd.animals[animal.fatherId]!;
            children.add(Text('Father: ${father.fullName}', style: textStyle));
          }
          if (animal.motherId != null && herd!.animals[animal.motherId] != null) {
            Animal mother = herd.animals[animal.motherId]!;
            children.add(Text('Mother: ${mother.fullName}', style: textStyle));
          }
          if (animal.category.canReproduce) {
            List<Animal> childList = herd!.animals.values.where((a) {
              if (animal.category.gender == Gender.male) {
                return a.fatherId == animal.id;
              } else if (animal.category.gender == Gender.female) {
                return a.motherId == animal.id;
              }
              return false;
            }).toList();
            // Sort the children by oldest to youngest.
            childList.sort((Animal a, Animal b) {
              if (a.birthDate == null) return 1;
              if (b.birthDate == null) return -1;
              return a.birthDate!.compareTo(b.birthDate!);
            });
            String childrenString = childList.isEmpty ? 'None' : childList.map((a) => a.fullName).join(', ');
            children.add(Text('Children: $childrenString', style: textStyle));
          }
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }
}
