import 'package:flutter/material.dart';
import 'package:projet_tm/login.dart';
import 'package:projet_tm/register.dart';
import 'package:projet_tm/splash.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      "/":(context) => const Splash(),
      "/login":(context) => const Login(),
      "/register":(context) => const Register()
    },
  ));
}