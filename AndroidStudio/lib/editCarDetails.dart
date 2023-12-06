import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils.dart';
class EditCarDetails extends StatefulWidget {
  final Map<String, dynamic> carData;

  const EditCarDetails({Key? key, required this.carData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditCarDetailsState();
}

class _EditCarDetailsState extends State<EditCarDetails> {
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
    carData = widget.carData;
    brandController = TextEditingController(text: carData['brandName']);
    modelController = TextEditingController(text: carData['modelName']);
    customNameController = TextEditingController(text: carData['customName']);
    horsePowerController =
        TextEditingController(text: carData['horsePower'].toString());
    kilometersController =
        TextEditingController(text: carData['kilometersAge'].toString());
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
              utils.inputStyle("Marque", "", brandController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Modèle", "", modelController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Nom personnalisé", "", customNameController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Chevaux", "", horsePowerController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              utils.inputStyle("Kilométrage", "", kilometersController),
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
                      utils.putCar(carData, context);
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
                      Utils.navigateTo(context, "/cars");
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
