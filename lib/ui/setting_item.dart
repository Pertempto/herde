import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const SettingsItem({required this.title, required this.value, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle leadingStyle = textTheme.headline6!;
    TextStyle trailingStyle = textTheme.headline6!.copyWith(fontWeight: FontWeight.w400);
    return ListTile(
      title: Text(title, style: leadingStyle),
      trailing: Text(value, style: trailingStyle),
      onTap: onTap,
      dense: false,
    );
  }
}
