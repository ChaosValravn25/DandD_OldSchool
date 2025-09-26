import 'package:flutter/material.dart';

// SimpleCard: una tarjeta sencilla con título, subtítulo y acción al tocar
class SimpleCard extends StatelessWidget {
final String title;
final String subtitle;
final VoidCallback? onTap;


const SimpleCard({super.key, required this.title, required this.subtitle, this.onTap});


@override
Widget build(BuildContext context) {
return Card(
child: ListTile(
title: Text(title),
subtitle: Text(subtitle),
onTap: onTap,
),
);
}
}