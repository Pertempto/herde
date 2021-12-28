import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'animal.dart';

part 'herd.freezed.dart';

part 'herd.g.dart';

@freezed
class Herd with _$Herd {
  factory Herd(
      {required String id,
      required String ownerId,
      required String name,
      required String type,
      @Default([]) List<Animal> animals}) = _Herde;

  factory Herd.fromJson(Map<String, dynamic> json) => _$HerdFromJson(json);
}
