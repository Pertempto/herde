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

  String get ageString {
    if (birthDate == null) {
      return '';
    }
    DateTime now = DateTime.now();
    int years = now.year - birthDate!.year;
    int months = now.month - birthDate!.month;
    int days = now.day - birthDate!.day;
    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += (days < 0 ? 11 : 12);
    }
    if (days < 0) {
      final monthAgo = DateTime(now.year, now.month - 1, birthDate!.day);
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
