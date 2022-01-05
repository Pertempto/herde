import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

part 'category.freezed.dart';

enum Parent { father, mother }

enum Gender {
  male,
  female,
  unknown,
}

@freezed
class Category with _$Category {
  factory Category({
    required String name,
    required int sortIndex,
    required Color color,
    required IconData iconData,
    @Default(Gender.unknown) Gender gender,
    required bool canReproduce,
  }) = _Category;
}

Map<String, Map<String, Category>> _categories = {
  'Goat': {
    'Buck': Category(
      name: 'Buck',
      sortIndex: 0,
      color: Colors.blue,
      iconData: MdiIcons.multiplication,
      gender: Gender.male,
      canReproduce: true,
    ),
    'Doe': Category(
      name: 'Doe',
      sortIndex: 1,
      color: Colors.pink,
      iconData: MdiIcons.plus,
      gender: Gender.female,
      canReproduce: true,
    ),
    'Wether': Category(
      name: 'Wether',
      sortIndex: 2,
      color: Colors.green,
      iconData: MdiIcons.minus,
      gender: Gender.male,
      canReproduce: false,
    ),
    'Kid': Category(
      name: 'Kid',
      sortIndex: 3,
      color: Colors.purple,
      iconData: MdiIcons.circleSmall,
      canReproduce: false,
    ),
  },
  'Cow': {
    'Bull': Category(
      name: 'Bull',
      sortIndex: 0,
      color: Colors.blue,
      iconData: MdiIcons.multiplication,
      gender: Gender.male,
      canReproduce: true,
    ),
    'Cow': Category(
      name: 'Cow',
      sortIndex: 1,
      color: Colors.pink,
      iconData: MdiIcons.plus,
      gender: Gender.female,
      canReproduce: true,
    ),
    'Heifer': Category(
      name: 'Heifer',
      sortIndex: 2,
      color: Colors.red,
      iconData: MdiIcons.plusCircleOutline,
      gender: Gender.female,
      canReproduce: true,
    ),
    'Steer': Category(
      name: 'Steer',
      sortIndex: 3,
      color: Colors.green,
      iconData: MdiIcons.minus,
      gender: Gender.male,
      canReproduce: false,
    ),
    'Calf': Category(
      name: 'Calf',
      sortIndex: 4,
      color: Colors.purple,
      iconData: MdiIcons.circleSmall,
      canReproduce: false,
    ),
  },
  'Cat': {
    'Tom': Category(
      name: 'Tom',
      sortIndex: 0,
      color: Colors.blue,
      iconData: MdiIcons.multiplication,
      gender: Gender.male,
      canReproduce: true,
    ),
    'Queen': Category(
      name: 'Queen',
      sortIndex: 1,
      color: Colors.pink,
      iconData: MdiIcons.plus,
      gender: Gender.female,
      canReproduce: true,
    ),
    'Gib': Category(
      name: 'Gib',
      sortIndex: 2,
      color: Colors.green,
      iconData: MdiIcons.minus,
      gender: Gender.male,
      canReproduce: false,
    ),
    'Kitten': Category(
      name: 'Kitten',
      sortIndex: 3,
      color: Colors.purple,
      iconData: MdiIcons.circleSmall,
      canReproduce: false,
    ),
  },
  'Duck': {
    'Drake': Category(
      name: 'Drake',
      sortIndex: 0,
      color: Colors.blue,
      iconData: MdiIcons.multiplication,
      gender: Gender.male,
      canReproduce: true,
    ),
    'Duck': Category(
      name: 'Duck',
      sortIndex: 1,
      color: Colors.pink,
      iconData: MdiIcons.plus,
      gender: Gender.female,
      canReproduce: true,
    ),
    'Duckling': Category(
      name: 'Duckling',
      sortIndex: 2,
      color: Colors.purple,
      iconData: MdiIcons.circleSmall,
      canReproduce: false,
    ),
  },
  'Dog': {
    'Male': Category(
      name: 'Male',
      sortIndex: 0,
      color: Colors.blue,
      iconData: MdiIcons.multiplication,
      gender: Gender.male,
      canReproduce: true,
    ),
    'Female': Category(
      name: 'Female',
      sortIndex: 1,
      color: Colors.pink,
      iconData: MdiIcons.plus,
      gender: Gender.female,
      canReproduce: true,
    ),
    'Pup': Category(
      name: 'Pup',
      sortIndex: 2,
      color: Colors.purple,
      iconData: MdiIcons.circleSmall,
      canReproduce: false,
    ),
  },
};

Category getCategory(String typeName, String categoryName) {
  Category unknownCategory = Category(
    name: '',
    sortIndex: 1000,
    color: Colors.transparent,
    iconData: MdiIcons.helpCircleOutline,
    canReproduce: false,
  );
  Map<String, Category>? typeCategories = _categories[typeName];
  if (typeCategories == null) {
    return unknownCategory;
  }
  Category? category = typeCategories[categoryName];
  return category ?? unknownCategory;
}

List<String> getCategoryNames(String typeName) {
  Map<String, Category>? typeCategories = _categories[typeName];
  if (typeCategories == null) {
    return [];
  }
  List<Category> categoriesList = typeCategories.values.toList();
  categoriesList.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
  return categoriesList.map((c) => c.name).toList();
}
