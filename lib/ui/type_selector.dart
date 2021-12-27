import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'animal_icon.dart';
import 'list_item.dart';

class TypeSelector extends StatelessWidget {
  static const List<String> types = ['Goat', 'Cow', 'Cat'];

  const TypeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Type'),
      ),
      body: ListView(
        children: types
            .map((type) =>
                ListItem(title: type, trailing: AnimalIcon(type: type), onTap: () => Navigator.pop(context, type)))
            .toList(),
      ),
    );
  }
}
