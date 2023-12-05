import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Charger les données utilisateur lors de l'initialisation de la page
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? localData = await getUserLocalData();

    setState(() {
      userData = localData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content(),
    );
  }

  Widget content() {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Transform.scale(
                  scale: 0.85,
                  child: Image.asset("assets/logo.png"),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            userData != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nom d\'utilisateur: ${userData!['username']}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            )

                : const Center(
              child: CircularProgressIndicator(), // Afficher une indication de chargement si les données sont en cours de chargement
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    navigateTo("/cars");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Vos voitures",
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
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    navigateTo("/car/add");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Ajouter une voiture",
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
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _logOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Se déconnecter",
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
        ),
      ),
    );
  }

  void _logOut() async {
    await clearDataLocally();
    navigateTo("/login");
  }

  Future<void> clearDataLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>?> getUserLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Récupérer les données à partir de SharedPreferences
    String? jsonData = prefs.getString('userData');

    if (jsonData != null) {
      // Si des données sont présentes, les décoder depuis JSON en Map
      Map<String, dynamic> decodedData = json.decode(jsonData);
      return decodedData;
    } else {
      // Si aucune donnée n'est trouvée, retourner null
      return null;
    }
  }

  navigateTo(String path) {
    Navigator.of(context).pushReplacementNamed(path);
  }

}