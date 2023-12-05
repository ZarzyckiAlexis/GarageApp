import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_tm/editCarDetails.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarDetails extends StatefulWidget {
  final Map<String, dynamic> carData;

  const CarDetails({Key? key, required this.carData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  late final Map<String, dynamic> carData;

  @override
  void initState() {
    super.initState();
    carData = widget.carData;
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
        body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 100,
            ),
            Card(
              color: Colors.white,
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Surnom: ${carData['customName']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Marque: ${carData['brandName']}'),
                    Text('Modèle: ${carData['modelName']}'),
                    Text('${carData['horsePower']} ch'),
                    Text('Kilométrage: ${carData['kilometersAge']} km'),
                  ],
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCarDetails(carData: carData),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Modifier",
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
                    _delete(carData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Supprimer",
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
      )
    );
  }

  void _delete(Map<String, dynamic> data) async {
    String apiDeleteCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      int id = data['id'];
      var response = await _sendDeleteRequest("$apiDeleteCarUrl/$id", headers, data);
      if (response.statusCode == 204) {
        try {
          int ownerId = data['ownerId'];
          print(data['ownerId']);
          var responsefetchCarList = await _fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers);
          print(responsefetchCarList.statusCode);
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
        _showErrorDialog('Erreur', 'Cette voiture n\'existe pas dans l\'API.');
      }
    } catch (error) {
      _showErrorDialog('Erreur', 'Erreur: $error');
    }
  }

  Future<http.Response> _sendDeleteRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
    String requestBody = json.encode(data);

    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

    IOClient ioClient = IOClient(httpClient);

    try {
      var response = await ioClient.delete(
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
}
