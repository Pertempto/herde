import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListItem extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool thin;

  const ListItem({
    required this.title,
    this.trailing,
    this.value,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    Key? key,
  })  : thin = false,
        super(key: key);

  const ListItem.thin({
    required this.title,
    this.trailing,
    this.value,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    Key? key,
  })  : thin = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle leadingStyle = textTheme.headline6!;
    TextStyle trailingStyle = textTheme.headline6!.copyWith(fontWeight: FontWeight.w400);
    TextStyle subtitleStyle = textTheme.subtitle1!;
    return ListTile(
      title: Text(title, style: leadingStyle),
      trailing: trailing ?? Text(value ?? '', style: trailingStyle),
      subtitle: subtitle == null ? null : Text(subtitle!, style: subtitleStyle),
      onTap: onTap,
      onLongPress: onLongPress,
      dense: true,
      visualDensity: thin ? VisualDensity.compact : VisualDensity.standard,
    );
  }
}
