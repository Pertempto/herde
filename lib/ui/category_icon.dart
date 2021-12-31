import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data/category.dart';

class CategoryIcon extends StatelessWidget {
  final String typeName;
  final String categoryName;
  final bool showLabel;

  const CategoryIcon({required this.typeName, required this.categoryName, this.showLabel = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle textStyle = textTheme.headline6!.copyWith(fontWeight: FontWeight.w400);
    Category category = getCategory(typeName, categoryName);
    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(categoryName, style: textStyle),
          const SizedBox(width: 8),
          Icon(category.iconData, color: category.color),
        ],
      );
    } else {
      return Tooltip(
        message: categoryName,
        child: Icon(category.iconData, color: category.color),
      );
    }
  }
}
