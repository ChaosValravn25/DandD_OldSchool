import 'package:flutter/material.dart';
import 'app_router.dart';


void main() {
runApp(const MyApp());
}


class MyApp extends StatelessWidget {
const MyApp({Key? key}) : super(key: key);


@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'D&D OldSchool Compendium',
debugShowCheckedModeBanner: false,
theme: ThemeData(
primarySwatch: Colors.brown,
scaffoldBackgroundColor: const Color(0xFFF7EFE0), // pergamino
appBarTheme: const AppBarTheme(
elevation: 2,
backgroundColor: Colors.brown,
),
),
initialRoute: AppRouter.splash,
onGenerateRoute: AppRouter.generateRoute,
);
}
}