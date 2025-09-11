import 'package:flutter/material.dart';
import '../app_router.dart';


class SplashPage extends StatefulWidget {
const SplashPage({Key? key}) : super(key: key);


@override
State<SplashPage> createState() => _SplashPageState();
}


class _SplashPageState extends State<SplashPage> {
@override
void initState() {
super.initState();
_navigateToHome();
}


void _navigateToHome() async {
await Future.delayed(const Duration(milliseconds: 900));
if (!mounted) return;
Navigator.of(context).pushReplacementNamed(AppRouter.home);
}


@override
Widget build(BuildContext context) {
return Scaffold(
body: Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: const [
Icon(Icons.shield, size: 96),
SizedBox(height: 16),
Text('D&D OldSchool', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
SizedBox(height: 8),
Text('Compendium', style: TextStyle(fontSize: 16)),
],
),
),
);
}
}