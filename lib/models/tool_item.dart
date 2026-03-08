import 'package:flutter/material.dart';

class ToolItem {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext context) pageBuilder;
  final String category;

  const ToolItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.pageBuilder,
    required this.category,
  });
}
