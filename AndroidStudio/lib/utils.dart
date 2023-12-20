import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Utils {

  // Partie LocalStorage

    // On enregiste la réponse locallement
  static Future<void> saveResponseLocally(
      Map<String, dynamic> jsonResponse, String strName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(jsonResponse);
    await prefs.setString(strName, jsonData);
  }
    // On enregiste la réponse locallement en list
  static Future<void> saveResponseLocallyList(
      List<dynamic> jsonResponse, String strName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonDataList = jsonResponse.map((item) => json.encode(item)).toList();
    await prefs.setStringList(strName, jsonDataList);
  }

    // On récupère les données de l'utilisateur
  static Future<Map<String, dynamic>?> getUserLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonData = prefs.getString('userData');

    if (jsonData != null) {
      Map<String, dynamic> decodedData = json.decode(jsonData);
      return decodedData;
    } else {
      return null;
    }
  }

  // On récupère l'image de l'utilisateur
  static Future<String?> getImageLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('imagePath');
  }

  // On récupère les voiturees de l'utilisateur
  static Future<List<dynamic>?> getCarsLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonData = prefs.get('userCars');

    if (jsonData != null) {
      if (jsonData is List<String>) {
        List<dynamic> decodedData = [];
        try {
          for (String item in jsonData) {
            decodedData.add(json.decode(item));
          }
          return decodedData;
        } catch (e) {
          print('Erreur décodage List<String>: $e');
        }
      } else if (jsonData is String) {
        try {
          dynamic decodedData = json.decode(jsonData);
          if (decodedData is List) {
            return decodedData;
          }
        } catch (e) {
          print('Erreur décodage String: $e');
        }
      }
    }
    return null;
  }

  // Partie SQL

  // PUT

    // On fais un put (modifier) pour les voitures
  void putCar(Map<String, dynamic> data, BuildContext context) async {
    String apiPutCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    // On définit le headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      int id = data['id'];
      var response = await sendPutRequest("$apiPutCarUrl/$id", headers, data); // On envoie la requête
      if (response.statusCode == 204) { // La réponse est 204: c'est OK
        try {
          int ownerId = data['ownerId']; // On récupère l'id de l'user
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers); // On récupère la liste de voiture associé à l'user
          if (responsefetchCarList.statusCode == 200) { // OK
            // On décode le json, si c'est une Liste, on le stock en list.
            // Si c'est une Map, on le stock en donnée simple.
            var jsonResponseCars = json.decode(responsefetchCarList.body);
            if (jsonResponseCars is List<dynamic>) {
              List<dynamic> userCars = jsonResponseCars;
              await saveResponseLocallyList(userCars, 'userCars');
            } else if (jsonResponseCars is Map<String, dynamic>) {
              Map<String, dynamic> userCars = jsonResponseCars;
              await saveResponseLocally(userCars, 'userCars');
            }
            navigateTo(context, "/cars"); // Redirection
            // Erreur : No cars found for this owner
          } else if (responsefetchCarList.statusCode == 404){
            Map<String, dynamic> userCars = {};
            await saveResponseLocally(userCars, 'userCars'); // On stock une liste vide.
            Utils.navigateTo(context, "/cars"); // Redirection
          } else {
            showErrorDialog(context, 'Erreur', 'Impossible de récupéré les véhicules via l\'API.');
          }
        } catch (error) {
          showErrorDialog(context, 'Erreur', 'Erreur: $error');
        }
      } else {
        showErrorDialog(context, 'Erreur', 'Impossible de modifier cette voiture dans l\'API.');
      }
    } catch (error) {
      showErrorDialog(context, 'Erreur', 'Erreur: $error');
    }
  }

  // Le protocol pour envoyer une requête put
  Future<http.Response> sendPutRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
    String requestBody = json.encode(data); // On transforme les données en String json
    // On crée un httpClient qui permet de bypass le certificat non SSL
    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    // On crée un ioClient qui peut utiliser notre httpClient modifié
    IOClient ioClient = IOClient(httpClient);
    // On essaie de faire la requête, on retourne la réponse et on ferme la connexion.
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

  // POST

  // Requête
  void postCar(Map<String, dynamic> data, BuildContext context) async {
    String apiAddCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    // On définit le header avec le type de réponse
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      var response = await sendPostRequest(apiAddCarUrl, headers, data);
      if (response.statusCode == 201) { // OK
        try {
          int ownerId = data['ownerId']; // On récupère l'id de l'owner
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers);
          if (responsefetchCarList.statusCode == 200) { // OK
            var jsonResponseCars = json.decode(responsefetchCarList.body);
            // On récupère la liste de voiture
            // Si la liste est une liste, la sauvegardé en tant que List
            // Sinon, sauvegarder le résultat en tant que map
            if (jsonResponseCars is List<dynamic>) {
              List<dynamic> userCars = jsonResponseCars;
              await saveResponseLocallyList(userCars, 'userCars');
            } else if (jsonResponseCars is Map<String, dynamic>) {
              Map<String, dynamic> userCars = jsonResponseCars;
              await saveResponseLocally(userCars, 'userCars');
            }
            navigateTo(context, "/cars");
            // Erreur : No cars found for this owner
          } else if (responsefetchCarList.statusCode == 404){
            Map<String, dynamic> userCars = {};
            await saveResponseLocally(userCars, 'userCars'); // On sauvegarde par une liste vide
            navigateTo(context, "/cars");
          } else {
            showErrorDialog(context, 'Erreur', 'Impossible de récupéré les véhicules via l\'API.');
          }
        } catch (error) {
          showErrorDialog(context, 'Erreur', 'Erreur: $error');
        }
      } else {
        showErrorDialog(context, 'Erreur', 'Impossible d\'ajouter le véhicule via l\'API.');
      }
    } catch (error) {
      showErrorDialog(context, 'Erreur', 'Erreur: $error');
    }
  }

    // Requête pour enregistrer un utilisateur
  void register(String username, String password, String confPassword, BuildContext context) async {
    String apiUrl = "https://10.0.2.2:7230/api/Users/Register";

    // On prépare le header adéquat
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // On créer une map blank pour pattern
    Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'confirmPassword': confPassword
    };

    try {
      var response = await sendPostRequest(apiUrl, headers, data); // On effectue la requête
      if (response.statusCode == 201) { // OK
        navigateTo(context, "/login"); // On change de route
      } else {
        showErrorDialog(context, 'Erreur', 'Combinaison Username / Mot de passe / Confirmation Mot de passe invalide.');
      }
    } catch (error) {
      showErrorDialog(context, 'Erreur', 'Erreur: $error');
    }
  }

  // Requête pour se login
  void login(String username, String password, BuildContext context) async {
    String apiLoginUrl = "https://10.0.2.2:7230/api/Users/Login";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    // On crée le header adéquat
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // On crée un pattern de data request
    Map<String, dynamic> data = {
      'username': username,
      'password': password,
    };

    try {
      var response = await sendPostRequest(apiLoginUrl, headers, data); // On envoie la requête
      // Après la connexion réussie
      if (response.statusCode == 200) { // C'est OK
        var jsonResponse = json.decode(response.body);
        await saveResponseLocally(jsonResponse, 'userData'); // On sauvegarde les données de l'user
        try {
          // On essaie de récuperer les voitures de l'utilisateur via son ID
          int userId = jsonResponse['id'];
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$userId", headers);
          if (responsefetchCarList.statusCode == 200) { // C'est OK
            // Si la liste est une List, on l'enregistre en tant que List
            // Sinon, on enregistre les données en tant que MAP
            var jsonResponseCars = json.decode(responsefetchCarList.body);
            if (jsonResponseCars is List<dynamic>) {
              List<dynamic> userCars = jsonResponseCars;
              await saveResponseLocallyList(userCars, 'userCars');
            } else if (jsonResponseCars is Map<String, dynamic>) {
              Map<String, dynamic> userCars = jsonResponseCars;
              await saveResponseLocally(userCars, 'userCars');
            }
            navigateTo(context, "/profile");
            // Erreur : No cars found for this owner
          } else if (responsefetchCarList.statusCode == 404){
            Map<String, dynamic> userCars = {};
            await saveResponseLocally(userCars, 'userCars');
            navigateTo(context, "/profile");
          } else {
            showErrorDialog(context, 'Erreur', 'Impossible de récupéré les véhicules via l\'API.');
          }
        } catch (error) {
          showErrorDialog(context, 'Erreur', 'Erreur: $error');
        }
      } else {
        showErrorDialog(context, 'Erreur', 'Combinaison Username / Mot de passe invalide.');
      }
    } catch (error) {
      showErrorDialog(context, 'Erreur', 'Erreur: $error');
    }
  }

  // SendPost

    // Protocol qui permet d'envoyé une postRequest
  Future<http.Response> sendPostRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
    String requestBody = json.encode(data); // On stock la requête en String Json
    // On crée une instance du httpClient pour bypass le badCertificate SSL
    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    // On crée une instance d'un ioClient qui permet d'utiliser le httpClient modifié
    IOClient ioClient = IOClient(httpClient);
    // On essaie la requête, et on renvoie le résultat.
    try {
      var response = await ioClient.post(
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

  // fetchCar

    // Permet de récuperer la liste des voitures
  Future<http.Response> fetchCarList(String apiUrl, Map<String, String> headers) async {
    // On bypass le certificat grâce à un httpClient modifié
    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    // On utilise un ioClient qui permet d'utiliser notre httpClient
    IOClient ioClient = IOClient(httpClient);

    // On envoie la requête et renvoie la réponse
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

  // Delete

  // Permet de supprimer une voiture
  void delete(Map<String, dynamic> data, BuildContext context) async {
    String apiDeleteCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      int id = data['id']; // On récupère l'ID de la voiture
      var response = await sendDeleteRequest("$apiDeleteCarUrl/$id", headers, data); // On envoie la requête
      if (response.statusCode == 204) { // OK
        try {
          int ownerId = data['ownerId']; // On récupère l'id de l'owner
          // On récupère la liste de voiture
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers);
          if (responsefetchCarList.statusCode == 200) { // OK
            // Si on récupère une List, on enregistre via la fonction List
            // Sinon on enregistre normalement
            var jsonResponseCars = json.decode(responsefetchCarList.body);
            if (jsonResponseCars is List<dynamic>) {
              List<dynamic> userCars = jsonResponseCars;
              await saveResponseLocallyList(userCars, 'userCars');
            } else if (jsonResponseCars is Map<String, dynamic>) {
              Map<String, dynamic> userCars = jsonResponseCars;
              await saveResponseLocally(userCars, 'userCars');
            }
            navigateTo(context, "/cars");
            // Erreur : No cars found for this owner
          } else if (responsefetchCarList.statusCode == 404){
            Map<String, dynamic> userCars = {};
            await saveResponseLocally(userCars, 'userCars');
            navigateTo(context, "/cars");
          } else {
            showErrorDialog(context, 'Erreur', 'Impossible de récupéré les véhicules via l\'API.');
          }
        } catch (error) {
          showErrorDialog(context, 'Erreur', 'Erreur: $error');
        }
      } else {
        showErrorDialog(context, 'Erreur', 'Cette voiture n\'existe pas dans l\'API.');
      }
    } catch (error) {
      showErrorDialog(context, 'Erreur', 'Erreur: $error');
    }
  }

  // Permet d'envoyer une delete request
  Future<http.Response> sendDeleteRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
    String requestBody = json.encode(data); // On stock les données du Json en String
    // On crée une instance du httpClient qui permet de bypass le SSL
    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    // On crée une instance du IOClient qui permet d'utiliser notre httpClient.
    IOClient ioClient = IOClient(httpClient);
    // On essaie la requête, et on renvoie le résultat.
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

  // Partie Widget

  // Permet de créer les input, de façon stylisée et uniforme

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

  // Others

  // Permet de naviguer d'une vue à l'autre plus facilement
  static void navigateTo(BuildContext context, String path) {
    Navigator.of(context).pushReplacementNamed(path);
  }

  // Permet d'afficher un message d'erreur popup
  static void showErrorDialog(BuildContext context, String title, String message) {
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

  // Permet de se déconnecter :
    // On vide le localStorage via la fonction développé ci-dessous
    // On redirigie vers la page de login.
  void logOut(BuildContext context) async {
    await clearDataLocally();
    navigateTo(context, "/login");
  }

  // Permet de clear les localStorage
  Future<void> clearDataLocally() async {
    // On réucpère le localStorage, et on vide les données User & Voiture
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.remove('userCars');
  }

  // Permet de prendre une image et l'enregistrer en localStorage
  Future<void> setImage() async {
    // On initialise l'imagePicker
    final picker = ImagePicker();
    // On attends l'image
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    // Si y'a une image
    if (pickedFile != null) {
      // On enregistre le chemin de l'image dans le localStorage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imagePath', pickedFile.path);
    } else {
      // On met le chemin de l'image à null
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imagePath', "null");
    }
  }

}
