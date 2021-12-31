import 'package:freezed_annotation/freezed_annotation.dart';

import 'note.dart';

part 'animal.freezed.dart';

part 'animal.g.dart';

@freezed
class Animal with _$Animal {
  const Animal._();

  factory Animal({
    required String id,
    @Default(-1) int tagNumber,
    required String name,
    required String type,
    required String category,
    DateTime? birthDate,
    @Default({}) Map<String, Note> notes,
  }) = _Animal;

  factory Animal.fromJson(Map<String, dynamic> json) => _$AnimalFromJson(json);

  String get fullName {
    if (tagNumber == -1) {
      return name;
    } else if (name == '') {
      return tagNumber.toString();
    } else {
      return tagNumber.toString() + ' - ' + name;
    }
  }
}
