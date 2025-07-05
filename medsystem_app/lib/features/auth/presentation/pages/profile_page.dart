import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medsystem_app/features/auth/data/remote/auth_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? fullName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void logout() {
    final authService = AuthService();
    authService.signOut();
  }

  Future<void> loadUser() async {
    final authService = AuthService();
    final user = authService.getCurrentUser();
    final uid = user?.uid;

    if (uid == null) {
      setState(() {
        fullName = "Usuario desconocido";
      });
      return;
    }

    try {
      // Consulta en doctors
      final doctorResponse = await http
          .get(Uri.parse('http://10.0.2.2:8080/api/v1/doctors/uid/$uid'));
      if (doctorResponse.statusCode == 200) {
        final doctorData = json.decode(doctorResponse.body);
        setState(() {
          fullName = doctorData['fullName'];
        });
        return;
      }

      // Consulta en patients si no está en doctors
      final patientResponse = await http
          .get(Uri.parse('http://10.0.2.2:8080/api/v1/patients/uid/$uid'));
      if (patientResponse.statusCode == 200) {
        final patientData = json.decode(patientResponse.body);
        setState(() {
          fullName = patientData['fullName'];
        });
        return;
      }

      setState(() {
        fullName = "Usuario no encontrado";
      });
    } catch (e) {
      setState(() {
        fullName = "Error al cargar datos";
      });
    }

    final email = await authService.getCurrentUserEmail();
    setState(() {
      userEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/fondo.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                          "assets/images/profile.jpg"), // Cambia esto por la URL de la imagen del usuario
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hola de nuevo ${fullName ?? 'Cargando...'}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail ?? 'Cargando...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton(
                      onPressed: () {
                        logout();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
