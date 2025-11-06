import 'package:flutter/material.dart';

class EditionBadge extends StatelessWidget {
  final String editionName;
  final Color? backgroundColor;
  final Color? textColor;

  const EditionBadge({
    super.key,
    required this.editionName,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        editionName,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    );
  }
}