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
    // On configure les routes du projet
    routes: {
      "/":(context) => const Splash(), // Redirige vers le SplashScreen
      "/login":(context) => const Login(), // Redirige vers le Login
      "/register":(context) => const Register(), // Redigrige vers le Register
      "/profile":(context) => const Profile(), // Redirige vers le UserProfile
      '/cars':(context) => const Cars(), // Redirige vers la liste des voitures
      '/car': (context) => const CarDetails(carData: {},), // Redirige vers le détail d'une voiture
      '/car/edit': (context) => const EditCarDetails(carData: {},), // Redirige vers la modification d'une voiture
      '/car/add': (context) => const AddCar() // Redirige vers la création d'une voiture
    },
  ));

}