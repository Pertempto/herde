import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'animal.dart';
import 'category.dart';

part 'herd.freezed.dart';

part 'herd.g.dart';

@freezed
class Herd with _$Herd {
  const Herd._();

  factory Herd(
      {required String id,
      required String ownerId,
      required String name,
      required String type,
      @Default({}) Map<String, Animal> animals}) = _Herde;

  factory Herd.fromJson(Map<String, dynamic> json) => _$HerdFromJson(json);

  List<Animal> getChildren(Animal animal) {
    if (animal.category.canReproduce) {
      List<Animal> childList = animals.values.where((a) {
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
      return childList;
    }
    return [];
  }
}
