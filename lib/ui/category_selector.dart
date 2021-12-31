import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data/category.dart';
import 'category_icon.dart';
import 'list_item.dart';

class CategorySelector extends StatelessWidget {
  final String typeName;

  const CategorySelector({required this.typeName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: ListView(
        children: getCategoryNames(typeName)
            .map((category) => ListItem(
                title: category,
                trailing: CategoryIcon(typeName: typeName, categoryName: category),
                onTap: () => Navigator.pop(context, category)))
            .toList(),
      ),
    );
  }
}
