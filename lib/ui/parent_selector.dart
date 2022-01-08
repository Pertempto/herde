import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data/animal.dart';
import '../data/category.dart';
import '../data/herd.dart';
import '../ui/category_icon.dart';
import 'list_item.dart';

class ParentSelector extends StatelessWidget {
  final Parent parent;
  final Herd herd;
  final bool Function(Animal)? filterFunction;

  const ParentSelector({
    required this.parent,
    required this.herd,
    this.filterFunction,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late String name;
    late Gender gender;
    if (parent == Parent.father) {
      name = 'Father';
      gender = Gender.male;
    } else if (parent == Parent.mother) {
      name = 'Mother';
      gender = Gender.female;
    }
    List<Animal> animals = herd.animals.values.where((animal) {
      if (filterFunction != null && !filterFunction!(animal)) {
        return false;
      }
      return animal.category.canReproduce && animal.category.gender == gender;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Select $name'),
      ),
      body: ListView(
        children: animals
            .map((animal) => ListItem(
                  title: animal.fullName,
                  trailing: CategoryIcon(typeName: animal.typeName, categoryName: animal.categoryName),
                  onTap: () => Navigator.pop(context, animal.id),
                ))
            .toList(),
      ),
    );
  }
}
