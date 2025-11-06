import 'package:flutter/material.dart';

class FilterChipList extends StatelessWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(String) onSelectionChanged;

  const FilterChipList({
    Key? key,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: options.map((option) {
        return FilterChip(
          label: Text(option),
          selected: selectedOptions.contains(option),
          onSelected: (bool selected) {
            onSelectionChanged(option);
          },
        );
      }).toList(),
    );
  }
}