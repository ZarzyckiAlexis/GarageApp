import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {

  // Partie LocalStorage

  static Future<void> saveResponseLocally(
      Map<String, dynamic> jsonResponse, String strName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(jsonResponse);
    await prefs.setString(strName, jsonData);
  }

  static Future<void> saveResponseLocallyList(
      List<dynamic> jsonResponse, String strName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonDataList = jsonResponse.map((item) => json.encode(item)).toList();
    await prefs.setStringList(strName, jsonDataList);
  }

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

  void putCar(Map<String, dynamic> data, BuildContext context) async {
    String apiPutCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      int id = data['id'];
      var response = await sendPutRequest("$apiPutCarUrl/$id", headers, data);
      if (response.statusCode == 204) {
        try {
          int ownerId = data['ownerId'];
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers);
          if (responsefetchCarList.statusCode == 200) {
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
            Utils.navigateTo(context, "/cars");
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

  Future<http.Response> sendPutRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
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

  // POST

  void postCar(Map<String, dynamic> data, BuildContext context) async {
    String apiAddCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      var response = await sendPostRequest(apiAddCarUrl, headers, data);
      if (response.statusCode == 201) {
        try {
          int ownerId = data['ownerId'];
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers);
          if (responsefetchCarList.statusCode == 200) {
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
        showErrorDialog(context, 'Erreur', 'Impossible d\'ajouter le véhicule via l\'API.');
      }
    } catch (error) {
      showErrorDialog(context, 'Erreur', 'Erreur: $error');
    }
  }

  void register(String username, String password, String confPassword, BuildContext context) async {
    String apiUrl = "https://10.0.2.2:7230/api/Users/Register";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'confirmPassword': confPassword
    };

    try {
      var response = await sendPostRequest(apiUrl, headers, data);
      if (response.statusCode == 201) {
        navigateTo(context, "/login");
      } else {
        showErrorDialog(context, 'Erreur', 'Combinaison Username / Mot de passe / Confirmation Mot de passe invalide.');
      }
    } catch (error) {
      showErrorDialog(context, 'Erreur', 'Erreur: $error');
    }
  }

  void login(String username, String password, BuildContext context) async {
    String apiLoginUrl = "https://10.0.2.2:7230/api/Users/Login";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> data = {
      'username': username,
      'password': password,
    };

    try {
      var response = await sendPostRequest(apiLoginUrl, headers, data);
      // Après la connexion réussie
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        await saveResponseLocally(jsonResponse, 'userData');
        try {
          int userId = jsonResponse['id'];
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$userId", headers);
          if (responsefetchCarList.statusCode == 200) {
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

  Future<http.Response> sendPostRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
    String requestBody = json.encode(data);

    HttpClient httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

    IOClient ioClient = IOClient(httpClient);

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

  Future<http.Response> fetchCarList(String apiUrl, Map<String, String> headers) async {
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

  // Delete

  void delete(Map<String, dynamic> data, BuildContext context) async {
    String apiDeleteCarUrl = "https://10.0.2.2:7230/api/Cars";
    String apiFetchCarsOwnerUrl = "https://10.0.2.2:7230/api/Cars/CarsByOwnerId";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      int id = data['id'];
      var response = await sendDeleteRequest("$apiDeleteCarUrl/$id", headers, data);
      if (response.statusCode == 204) {
        try {
          int ownerId = data['ownerId'];
          var responsefetchCarList = await fetchCarList("$apiFetchCarsOwnerUrl/$ownerId", headers);
          if (responsefetchCarList.statusCode == 200) {
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

  Future<http.Response> sendDeleteRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
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

  // Partie Widget

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

  static void navigateTo(BuildContext context, String path) {
    Navigator.of(context).pushReplacementNamed(path);
  }

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

  void logOut(BuildContext context) async {
    await clearDataLocally();
    navigateTo(context, "/login");
  }

  Future<void> clearDataLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

}
