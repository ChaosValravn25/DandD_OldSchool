import 'package:flutter/material.dart';
import '../app_router.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});


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
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.black, Colors.red],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/Dungeons-and-Dragons-Logo-2000.png',
            width: 220,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'OldSchool Compendium',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ),
);
}
}