import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medsystem_app/features/appointments/domain/appointment.dart';
import 'package:medsystem_app/features/appointments/presentation/pages/day_of_the_appointment_screen.dart';

class AppointmentSchedulingScreen extends StatefulWidget {
  const AppointmentSchedulingScreen({super.key});

  @override
  State<AppointmentSchedulingScreen> createState() =>
      _AppointmentSchedulingScreenState();
}

class _AppointmentSchedulingScreenState
    extends State<AppointmentSchedulingScreen> {
  String? patientId;
  String? selectedDoctor;
  String? selectedSpecialty;
  List<Map<String, String>> doctors = [];
  TextEditingController reasonController = TextEditingController();

  final List<String> specialties = [
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
    "UROLOGY"
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    fetchPatientId();
  }

  Future<void> fetchDoctors() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'Doctor')
          .get();

      final List<String> doctorUids =
          querySnapshot.docs.map((doc) => doc.id).toList();

      List<Map<String, String>> fetchedDoctors = [];
      for (String uid in doctorUids) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8080/api/v1/doctors/uid/$uid'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> doctorData = jsonDecode(response.body);
          fetchedDoctors.add({
            'uid': uid,
            'id': doctorData['id'].toString(),
            'name': doctorData['fullName'],
          });
        } else {
          debugPrint('Error fetching doctor with UID $uid: ${response.body}');
        }
      }

      setState(() {
        doctors = fetchedDoctors;
      });
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
    }
  }

  Future<void> fetchPatientId() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser; // Obtener usuario autenticado
      if (user == null) {
        debugPrint('Usuario no autenticado');
        return;
      }

      final String uid = user.uid; // UID del usuario autenticado

      // Buscar en el endpoint de pacientes usando el UID
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/patients/uid/$uid'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> patientData = jsonDecode(response.body);

        // Asignar el ID del paciente
        setState(() {
          patientId = patientData['id'].toString();
        });

        debugPrint('Patient ID obtenido: $patientId');
      } else {
        debugPrint(
            'Error fetching patient ID (UID: $uid): ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching patient ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            top: 16,
            left: 16,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8, height: 80),
                const Text(
                  'Schedule Appointment',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Card(
                      color: const Color(0xFFEDF2FA),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Complete the Data',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Reason for the appointment?',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: reasonController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Which specialty?',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedSpecialty,
                              hint: const Text('Select a specialty'),
                              items: specialties.map((specialty) {
                                return DropdownMenuItem<String>(
                                  value: specialty,
                                  child: Text(specialty),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSpecialty = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Do you have a favorite doctor?',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedDoctor,
                              hint: const Text('Select a doctor'),
                              items: doctors.map((doctor) {
                                return DropdownMenuItem<String>(
                                  value: doctor['id'],
                                  child: Text(doctor['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDoctor = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    final appointment = Appointment(
                      doctorId: int.parse(selectedDoctor ?? '0'),
                      patientId: int.parse(patientId!),
                      date: '',
                      reason: reasonController.text,
                      specialty: selectedSpecialty ?? 'N/A',
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DayOfAppointmentScreen(appointment: appointment),
                      ),
                    );
                  },
                  child: const Center(
                    child: Text('Process',
                        style: TextStyle(
                            color: Color.fromARGB(255, 25, 38, 56),
                            fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
