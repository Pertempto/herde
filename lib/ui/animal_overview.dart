import 'package:flutter/material.dart';

import '../data/animal.dart';
import '../data/data_store.dart';
import '../data/herd.dart';
import 'category_icon.dart';
import 'list_item.dart';
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
      builder: (Herd? herd, Animal? animal, bool isLoading) {
        List<Widget> children = [];

        if (animal != null) {
          children = [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(animal.fullName, style: textTheme.headline4),
            ),
            const SizedBox(height: 12),
            if (animal.tagNumber != -1)
              ListItem.thin(title: 'Tag Number', value: animal.tagNumber.toString()),
            ListItem.thin(title: 'Type', trailing: TypeIcon(type: animal.typeName, showLabel: true)),
            ListItem.thin(
              title: 'Category',
              trailing: CategoryIcon(
                typeName: animal.typeName,
                categoryName: animal.categoryName,
                showLabel: true,
              ),
            ),
          ];
          if (animal.birthDate != null) {
            children.add(ListItem.thin(title: 'Birth Date', value: animal.birthDateString));
            children.add(ListItem.thin(title: 'Age', value: animal.ageString));
          }
          if (animal.fatherId != null && herd!.animals[animal.fatherId] != null) {
            Animal father = herd.animals[animal.fatherId]!;
            children.add(ListItem.thin(title: 'Father', value: father.fullName));
          }
          if (animal.motherId != null && herd!.animals[animal.motherId] != null) {
            Animal mother = herd.animals[animal.motherId]!;
            children.add(ListItem.thin(title: 'Mother', value: mother.fullName));
          }
          if (animal.category.canReproduce) {
            List<Animal> childList = herd!.getChildren(animal: animal, sort: false);
            String childrenString = childList.isEmpty ? 'None' : childList.map((a) => a.fullName).join(', ');
            children.add(ListItem.thin(title: 'Children', value: childrenString));
          }
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }
}
