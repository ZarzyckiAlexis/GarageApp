import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditCarDetails extends StatefulWidget {
  final Map<String, dynamic> carData;

  const EditCarDetails({Key? key, required this.carData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditCarDetailsState();
}

class _EditCarDetailsState extends State<EditCarDetails> {
  late final Map<String, dynamic> carData;

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
              inputStyle("Marque", "", brandController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              inputStyle("Modèle", "", modelController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              inputStyle("Nom personnalisé", "", customNameController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              inputStyle("Chevaux", "", horsePowerController),
              const SizedBox(height: 10), // Espace réduit entre les champs
              inputStyle("Kilométrage", "", kilometersController),
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
                      _put(carData);
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
                      _navigateTo("/cars");
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


  void _put(Map<String, dynamic> data) async {
    String apiPutCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      int id = data['id'];
      var response = await _sendPutRequest("$apiPutCarUrl/$id", headers, data);
      if (response.statusCode == 204) {
        try {
          int ownerId = data['ownerId'];
          var responsefetchCarList = await _fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers);
          if (responsefetchCarList.statusCode == 200) {
            var jsonResponseCars = json.decode(responsefetchCarList.body);
            if (jsonResponseCars is List<dynamic>) {
              List<dynamic> userCars = jsonResponseCars;
              await saveResponseLocallyList(userCars, 'userCars');
            } else if (jsonResponseCars is Map<String, dynamic>) {
              Map<String, dynamic> userCars = jsonResponseCars;
              await saveResponseLocally(userCars, 'userCars');
            }
            _navigateTo("/cars");
            // Erreur : No cars found for this owner
          } else if (responsefetchCarList.statusCode == 404){
            Map<String, dynamic> userCars = {};
            await saveResponseLocally(userCars, 'userCars');
            _navigateTo("/cars");
          } else {
            _showErrorDialog('Erreur', 'Impossible de récupéré les véhicules via l\'API.');
          }
        } catch (error) {
          _showErrorDialog('Erreur', 'Erreur: $error');
        }
      } else {
        _showErrorDialog('Erreur', 'Impossible de modifier cette voiture dans l\'API.');
      }
    } catch (error) {
      _showErrorDialog('Erreur', 'Erreur: $error');
    }
  }

  Future<http.Response> _sendPutRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
    String requestBody = json.encode(data);

    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

    IOClient ioClient = IOClient(httpClient);

    try {
      var response = await ioClient.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      return http.Response(response.body, response.statusCode);
    } catch (e) {
      rethrow;
    } finally {
      ioClient.close();
    }
  }

  Future<http.Response> _fetchCarList(String apiUrl, Map<String, String> headers) async {
    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(httpClient);

    try {
      var response = await ioClient.get(
        Uri.parse(apiUrl),
        headers: headers,
      );
      print(response.body);
      print(response.statusCode);
      return http.Response(response.body, response.statusCode);
    } catch (e) {
      rethrow;
    } finally {
      ioClient.close();
    }
  }

  Future<void> saveResponseLocally(Map<String, dynamic> jsonResponse, String strName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(jsonResponse);
    await prefs.setString(strName, jsonData);
  }

  Future<void> saveResponseLocallyList(List<dynamic> jsonResponse, String strName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonDataList = jsonResponse.map((item) => json.encode(item)).toList();
    await prefs.setStringList(strName, jsonDataList);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateTo(String path) {
    Navigator.of(context).pushReplacementNamed(path);
  }

  Widget inputStyle(String title, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 10), // Réduction de la taille ici
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 10),
              hintText: hintText,
            ),
          ),
        ),
        const SizedBox(height: 10), // Réduction de la taille ici
      ],
    );
  }


}
