import 'package:flutter/material.dart';
import 'package:projet_tm/addCar.dart';
import 'package:projet_tm/cars.dart';
import 'package:projet_tm/editCarDetails.dart';
import 'package:projet_tm/login.dart';
import 'package:projet_tm/profile.dart';
import 'package:projet_tm/register.dart';
import 'package:projet_tm/splash.dart';

import 'carDetails.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      "/":(context) => const Splash(),
      "/login":(context) => const Login(),
      "/register":(context) => const Register(),
      "/profile":(context) => const Profile(),
      '/cars':(context) => const Cars(),
      '/car': (context) => const CarDetails(carData: {},),
      '/car/edit': (context) => const EditCarDetails(carData: {},),
      '/car/add': (context) => const AddCar()
    },
  ));

}