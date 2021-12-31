import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
            TypeIcon(type: animal.type, showLabel: true),
            CategoryIcon(category: animal.category, showLabel: true),
          ];
          if (animal.birthDate != null) {
            String birthString = DateFormat.yMd().format(animal.birthDate!);
            String age = getAge(animal.birthDate!);
            children.add(Text('Born: $birthString ($age)', style: textStyle));
          }
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }

  String getAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;
    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += (days < 0 ? 11 : 12);
    }
    if (days < 0) {
      final monthAgo = DateTime(now.year, now.month - 1, birthDate.day);
      days = now.difference(monthAgo).inDays + 1;
    }

    if (years > 1) {
      return '$years years';
    } else if (years > 0) {
      return '${months + 12} months';
    } else if (months > 1) {
      return '$months months';
    } else if (months == 1) {
      return '1 month';
    } else {
      return '$days days';
    }
  }
}
