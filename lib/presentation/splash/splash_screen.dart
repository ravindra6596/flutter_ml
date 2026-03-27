import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_ai_ml/presentation/home_screen.dart';
import 'package:flutter_ai_ml/utils/assets_file.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(splashScreen),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
