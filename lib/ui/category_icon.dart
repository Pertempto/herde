import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CategoryIcon extends StatelessWidget {
  static const Map<String, IconData> icons = {
    'Buck': MdiIcons.multiplication,
    'Wether': MdiIcons.minus,
    'Doe': MdiIcons.plus,
    'Kid': MdiIcons.slashForward,
    'Bull': MdiIcons.multiplication,
    'Steer': MdiIcons.minus,
    'Cow': MdiIcons.plusCircleOutline,
    'Heifer': MdiIcons.plus,
    'Calf': MdiIcons.slashForward,
    'Tom': MdiIcons.multiplication,
    'Gib': MdiIcons.minus,
    'Queen': MdiIcons.plus,
    'Kitten': MdiIcons.slashForward,
  };
  static const Map<String, Color> colors = {
    'Buck': Colors.blue,
    'Wether': Colors.green,
    'Doe': Colors.pink,
    'Kid': Colors.purple,
    'Bull': Colors.blue,
    'Steer': Colors.green,
    'Cow': Colors.red,
    'Heifer': Colors.pink,
    'Calf': Colors.purple,
    'Tom': Colors.blue,
    'Gib': Colors.green,
    'Queen': Colors.pink,
    'Kitten': Colors.purple,
  };
  final String category;
  final bool showLabel;

  const CategoryIcon({required this.category, this.showLabel = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (category.isEmpty) {
      return const SizedBox(width:0, height:0);
    }
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle textStyle = textTheme.headline6!.copyWith(fontWeight: FontWeight.w400);
    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category, style: textStyle),
          const SizedBox(width: 8),
          Icon(icons[category] ?? MdiIcons.helpCircleOutline, color: colors[category] ?? Colors.black54),
        ],
      );
    } else {
      return Tooltip(
        message: category,
        child: Icon(icons[category] ?? MdiIcons.helpCircleOutline, color: colors[category] ?? Colors.black54),
      );
    }
  }
}
