import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medsystem_app/features/appointments/presentation/pages/appointment_scheduling_screen.dart';
import 'package:medsystem_app/features/appointments/presentation/blocs/appointments_bloc.dart';
import 'package:medsystem_app/features/appointments/presentation/blocs/appointments_event.dart';
import 'package:medsystem_app/features/appointments/presentation/blocs/appointments_state.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String? _role; // Rol del usuario autenticado
  String? _uid; // UID del usuario autenticado

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Inicializar el rol y UID del usuario autenticado
  Future<void> _initializeUser() async {
    try {
      // Obtener el usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        _uid = user.uid;

        // Obtener el rol desde Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(_uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _role = userDoc['role'];
          });

          // Cargar las citas en el Bloc
          context.read<AppointmentsBloc>().add(GetAppointments(uid: _uid!));
        }
      }
    } catch (e) {
      print('Error al inicializar el usuario: $e');
    }
  }

  Future<String?> fetchName(String endpoint, int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/$endpoint/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fullName']; // Se asume que el backend devuelve 'fullName'
      } else {
        debugPrint('Failed to fetch name for $endpoint/$id: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching name for $endpoint/$id: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
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
          Column(
            children: [
              // Título centrado
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8, height: 60),
                    Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
                    builder: (context, state) {
                      if (state is AppointmentsLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is AppointmentsLoadedState) {
                        if (state.appointments.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 65,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'You don\'t have appointments booked',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Schedule a Medical Appointment or Service with us',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: state.appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = state.appointments[index];
                            return FutureBuilder(
                              future: Future.wait([
                                fetchName('doctors', appointment.doctorId),
                                fetchName('patients', appointment.patientId),
                              ]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final names = snapshot.data as List<String?>;
                                final doctorName = names[0] ?? 'Unknown Doctor';
                                final patientName =
                                    names[1] ?? 'Unknown Patient';

                                return Card(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255)
                                          .withOpacity(0.7),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    title: Text(
                                      'Doctor: $doctorName',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Patient: $patientName',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        Text(
                                          'Date: ${appointment.date}',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        Text(
                                          'Reason: ${appointment.reason}',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                        Text(
                                          'Specialty: ${appointment.specialty}',
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'Failed to load appointments',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _role == 'Doctor'
          ? null // Ocultar el botón para doctores
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentSchedulingScreen(),
                  ),
                );
              },
              backgroundColor: const Color.fromARGB(255, 68, 138, 255),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
