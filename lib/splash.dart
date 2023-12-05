import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatefulWidget {

  const Splash({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashState();

}

class _SplashState extends State<Splash> {

  @override
  void initState(){
    super.initState();
    startTimer();
  }

  startTimer(){
    var duration = const Duration(seconds: 4);
    return Timer(duration, route);
  }

  route(){
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/logo.png"),
          Text(
            'Chargement...',
            style: GoogleFonts.notoSans(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }


}