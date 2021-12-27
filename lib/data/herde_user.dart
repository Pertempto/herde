import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'herde_user.freezed.dart';

part 'herde_user.g.dart';

@freezed
class HerdeUser with _$HerdeUser {
  factory HerdeUser({required String uid, required String name, @Default('') String currentHerd}) = _HerdeUser;

  factory HerdeUser.fromJson(Map<String, dynamic> json) => _$HerdeUserFromJson(json);
}
