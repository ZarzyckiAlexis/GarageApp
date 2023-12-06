import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './utils.dart';

class AddCar extends StatefulWidget {

  const AddCar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {

  Map<String, dynamic>? userData;
  late final Map<String, dynamic> carData;
  Utils utils = Utils();

  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController customNameController;
  late TextEditingController horsePowerController;
  late TextEditingController kilometersController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    brandController = TextEditingController();
    modelController = TextEditingController();
    customNameController = TextEditingController();
    horsePowerController = TextEditingController();
    kilometersController = TextEditingController();
    carData = {};
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? localData = await Utils.getUserLocalData();
    setState(() {
      userData = localData;
    });
  }

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    customNameController.dispose();
    horsePowerController.dispose();
    kilometersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _content(),
      ),
    );
  }

  Widget _content() {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView( // Ajout d'un SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              utils.inputStyle("Marque", "Entrez la marque", brandController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Modèle", "Entrez le modèle", modelController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Nom personnalisé", "Entrez le nom personnalisé", customNameController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Chevaux", "Entrez le nombre de chevaux", horsePowerController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Kilométrage", "Entrez le nombre de kilomètres", kilometersController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      carData['brandName'] = brandController.text;
                      carData['modelName'] = modelController.text;
                      carData['customName'] = customNameController.text;
                      carData['horsePower'] = horsePowerController.text;
                      carData['kilometersAge'] = kilometersController.text;
                      carData['ownerId'] = userData!['id'];
                      utils.postCar(carData, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Enregistrer",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Utils.navigateTo(context, "/profile");
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
          ),
        ),
      ),
    );
  }

}
