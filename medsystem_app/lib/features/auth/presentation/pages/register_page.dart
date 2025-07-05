import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medsystem_app/features/auth/data/remote/auth_gate.dart';
import 'package:medsystem_app/features/auth/data/remote/auth_service.dart';
import 'package:medsystem_app/features/auth/presentation/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dniController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController licenseNumberController = TextEditingController();

  // Campos para Patient
  TextEditingController streetController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  String? selectedRole;
  String? selectedSpecialty;

  void register(BuildContext context) async {
    final auth = AuthService();

    try {
      // Verifica que el rol esté seleccionado
      if (selectedRole == null) {
        throw Exception('Por favor, selecciona un rol.');
      }

      // Registro en Firebase
      UserCredential userCredential = await auth.signUpWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        selectedRole!, // Pasar el rol como tercer argumento
      );

      if (userCredential.user != null) {
        final String uid = userCredential.user!.uid; // Capturar el UID

        // Guardar el rol del usuario en Firestore
        await FirebaseFirestore.instance.collection('Users').doc(uid).set({
          'uid': uid,
          'email': emailController.text,
          'role': selectedRole, // Guardar el rol (Doctor o Patient)
        });

        // Construcción del cuerpo de la solicitud para el backend
        Map<String, dynamic> body = {
          "uid": uid, // Incluir el UID en la solicitud al backend
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "role": selectedRole,
        };

        if (selectedRole == "Doctor") {
          body["licenseNumber"] = licenseNumberController.text;
          body["specialty"] = selectedSpecialty;
        } else if (selectedRole == "Patient") {
          body.addAll({
            "street": streetController.text,
            "number": numberController.text,
            "city": cityController.text,
            "postalCode": postalCodeController.text,
            "country": countryController.text,
          });
        }

        // URL del backend
        const backendUrl = "http://10.0.2.2:8080/api/v1";
        final endpoint = selectedRole == "Doctor"
            ? "$backendUrl/doctors"
            : "$backendUrl/patients";

        // Enviar la solicitud al backend
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {"Content-Type": "application/json"},
          body: json.encode(body),
        );

        if (response.statusCode == 201) {
          // Navegar a la siguiente pantalla si todo es exitoso
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
            );
          }
        } else {
          throw Exception("Error al registrar en el backend: ${response.body}");
        }
      }
    } catch (e) {
      // Mostrar un diálogo de error si ocurre algún problema
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/fondo.jpg',
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _inputField("First name", firstNameController),
                  const SizedBox(height: 10),
                  _inputField("Last name", lastNameController),
                  const SizedBox(height: 10),
                  _inputField("DNI", dniController),
                  const SizedBox(height: 10),
                  _inputField("Email", emailController),
                  const SizedBox(height: 10),
                  _inputField("Password", passwordController, isPassword: true),
                  const SizedBox(height: 10),
                  _inputField("Phone", phoneController),
                  const SizedBox(height: 10),
                  _roleSelection(),
                  if (selectedRole == "Doctor") _doctorFields(),
                  if (selectedRole == "Patient") _patientFields(),
                  const SizedBox(height: 10),
                  _registerBtn(),
                  const SizedBox(height: 10),
                  _extraText(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
      ),
      obscureText: isPassword,
    );
  }

  Widget _roleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Role:",
          style: TextStyle(color: Colors.white),
        ),
        RadioListTile<String>(
          title: const Text("Doctor", style: TextStyle(color: Colors.white)),
          value: "Doctor",
          activeColor: Colors.white,
          groupValue: selectedRole,
          onChanged: (value) {
            setState(() {
              selectedRole = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text("Patient", style: TextStyle(color: Colors.white)),
          value: "Patient",
          activeColor: Colors.white,
          groupValue: selectedRole,
          onChanged: (value) {
            setState(() {
              selectedRole = value;
            });
          },
        ),
      ],
    );
  }

  Widget _doctorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField("License Number", licenseNumberController),
        const SizedBox(height: 10),
        _specialtySelection(),
      ],
    );
  }

  Widget _patientFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField("Street", streetController),
        const SizedBox(height: 10),
        _inputField("Number", numberController),
        const SizedBox(height: 10),
        _inputField("City", cityController),
        const SizedBox(height: 10),
        _inputField("Postal Code", postalCodeController),
        const SizedBox(height: 10),
        _inputField("Country", countryController),
      ],
    );
  }

  Widget _specialtySelection() {
    const specialties = [
      "CARDIOLOGY",
      "DERMATOLOGY",
      "ENDOCRINOLOGY",
      "GASTROENTEROLOGY",
      "GYNECOLOGY",
      "HEMATOLOGY",
      "NEUROLOGY",
      "OPHTHALMOLOGY",
      "OTOLARYNGOLOGY",
      "PEDIATRICS",
      "PSYCHIATRY",
      "PULMONOLOGY",
      "RHEUMATOLOGY",
      "UROLOGY",
    ];

    return DropdownButton<String>(
      value: selectedSpecialty,
      hint: const Text(
        "Select Specialty",
        style: TextStyle(color: Colors.white),
      ),
      items: specialties.map((specialty) {
        return DropdownMenuItem(
          value: specialty,
          child: Text(
            specialty,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedSpecialty = value;
        });
      },
      dropdownColor: const Color.fromARGB(255, 73, 73, 73),
    );
  }

  Widget _registerBtn() {
    return ElevatedButton(
      onPressed: () => register(context),
      style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Sign up",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
    );
  }

  Widget _extraText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Do you have an account?",
            style: TextStyle(color: Colors.white)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            "Sign in",
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
