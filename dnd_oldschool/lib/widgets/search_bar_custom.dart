import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBarCustom({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Buscar...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}