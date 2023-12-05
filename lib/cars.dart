import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'carDetails.dart';

class Cars extends StatefulWidget {
  const Cars({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CarsState();
}

class _CarsState extends State<Cars> {
  Map<String, dynamic>? userData;
  Future<List<dynamic>>? carsData;


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? userlocalData = await getUserLocalData();
    setState(() {
      userData = userlocalData;
      _loadCarsData();
    });
  }

  Future<void> _loadCarsData() async {
    List<dynamic>? carslocalData = await getCarsLocalData();
    setState(() {
      carsData = Future.value(carslocalData ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: content(),
      ),
    );
  }

  Widget content() {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: carsData ?? Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erreur: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    List<dynamic> carsList = snapshot.data as List<dynamic>;
                    return ListView.builder(
                      itemCount: carsList.length,
                      itemBuilder: (context, index) {
                        final car = carsList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarDetails(carData: car),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text('Surnom: ${car['customName']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Marque: ${car['brandName']}'),
                                  Text('Modèle: ${car['modelName']}'),
                                  Text('${car['horsePower']} ch'),
                                  Text('Kilométrage: ${car['kilometersAge']} km'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Aucune donnée de voiture à afficher'),
                    );
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  navigateTo("/profile");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Retour",
                  style: GoogleFonts.notoSans(
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Future<Map<String, dynamic>?> getUserLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('userData');

    if (jsonData != null) {
      Map<String, dynamic> decodedData = json.decode(jsonData);
      return decodedData;
    } else {
      return null;
    }
  }

  Future<List<dynamic>?> getCarsLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonString = prefs.getStringList('userCars');

    if (jsonString != null) {
      List<dynamic> decodedData = [];
      for (String item in jsonString) {
        decodedData.add(json.decode(item));
      }
      return decodedData;
    } else {
      return null;
    }
  }

  navigateTo(String path) {
    Navigator.of(context).pushReplacementNamed(path);
  }
}
