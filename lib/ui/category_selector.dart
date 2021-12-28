import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'category_icon.dart';
import 'list_item.dart';

class CategorySelector extends StatelessWidget {
  static const Map<String, List<String>> categories = {
    'Goat': ['Buck', 'Wether', 'Doe', 'Kid'],
    'Cow': ['Bull', 'Steer', 'Cow', 'Heifer', 'Calf'],
    'Cat': ['Tom', 'Gib', 'Queen', 'Kitten'],
  };
  final String type;

  const CategorySelector({required this.type, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: ListView(
        children: (categories[type] ?? [])
            .map((category) => ListItem(
                title: category,
                trailing: CategoryIcon(category: category),
                onTap: () => Navigator.pop(context, category)))
            .toList(),
      ),
    );
  }
}
