import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 5, 50, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  inputStyle(
                    "Nom d'utilisateur",
                    "Entrez votre nom d'utilisateur",
                    usernameController
                  ),
                  inputStyle("Mot de passe", "Entrez votre mot de passe", passwordController),
                ],
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
                    String username = usernameController.text;
                    String password = passwordController.text;
                    _login(username, password);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Se connecter",
                    style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Pas de compte? ",
                      style: GoogleFonts.notoSans(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: "S'inscrire",
                      style: GoogleFonts.notoSans(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushNamed("/register");
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        const SizedBox(height: 15),
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
        const SizedBox(height: 15),
      ],
    );
  }

  void _login(String username, String password) async {
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
      var response = await _sendLoginRequest(apiLoginUrl, headers, data);
      // Après la connexion réussie
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        await saveResponseLocally(jsonResponse, 'userData');
        try {
          int userId = jsonResponse['id'];
          var responsefetchCarList = await _fetchCarList("$apiFetchCarsOwnerUrl/$userId", headers);
          if (responsefetchCarList.statusCode == 200) {
            var jsonResponseCars = json.decode(responsefetchCarList.body);
            if (jsonResponseCars is List<dynamic>) {
              List<dynamic> userCars = jsonResponseCars;
              await saveResponseLocallyList(userCars, 'userCars');
            } else if (jsonResponseCars is Map<String, dynamic>) {
              Map<String, dynamic> userCars = jsonResponseCars;
              await saveResponseLocally(userCars, 'userCars');
            }
            navigateToProfile();
            // Erreur : No cars found for this owner
          } else if (responsefetchCarList.statusCode == 404){
            Map<String, dynamic> userCars = {};
            await saveResponseLocally(userCars, 'userCars');
            navigateToProfile();
          } else {
            _showErrorDialog('Erreur', 'Impossible de récupéré les véhicules via l\'API.');
          }
        } catch (error) {
          _showErrorDialog('Erreur', 'Erreur: $error');
        }
      } else {
        _showErrorDialog('Erreur', 'Combinaison Username / Mot de passe invalide.');
      }
    } catch (error) {
      _showErrorDialog('Erreur', 'Erreur: $error');
    }
  }

  Future<http.Response> _sendLoginRequest(String apiUrl, Map<String, String> headers, Map<String, dynamic> data) async {
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

  void navigateToProfile() {
    Navigator.of(context).pushReplacementNamed('/profile');
  }

}
