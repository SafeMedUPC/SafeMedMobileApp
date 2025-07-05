import 'package:flutter/material.dart';
import 'package:medsystem_app/features/appointments/domain/appointment.dart';
import 'package:medsystem_app/shared/presentation/pages/homepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReserveSummaryScreen extends StatefulWidget {
  final Appointment appointment;

  const ReserveSummaryScreen({super.key, required this.appointment});

  @override
  State<ReserveSummaryScreen> createState() => _ReserveSummaryScreenState();
}

class _ReserveSummaryScreenState extends State<ReserveSummaryScreen> {
  String? doctorName;
  String? patientName;

  @override
  void initState() {
    super.initState();
    fetchDoctorName();
    fetchPatientName();
  }

  Future<void> fetchDoctorName() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8080/api/v1/doctors/${widget.appointment.doctorId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          doctorName = data['fullName'];
        });
      } else {
        debugPrint('Failed to fetch doctor name: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching doctor name: $e');
    }
  }

  Future<void> fetchPatientName() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8080/api/v1/patients/${widget.appointment.patientId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          patientName = data['fullName'];
        });
      } else {
        debugPrint('Failed to fetch patient name: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching patient name: $e');
    }
  }

  Future<void> postAppointment(Appointment appointment) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/appointments');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'doctorId': appointment.doctorId,
          'patientId': appointment.patientId,
          'date': appointment.date,
          'reason': appointment.reason,
          'specialty': appointment.specialty,
        }),
      );

      if (response.statusCode == 201) {
        // Éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created successfully!')),
        );

        // Navegar al Homepage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Homepage(),
          ),
          (route) => false,
        );
      } else {
        // Error del servidor
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create appointment: ${response.body}')),
        );
      }
    } catch (error) {
      // Error de conexión
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
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
                const SizedBox(width: 8),
                const Text(
                  'Reserve Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 16.0, right: 16.0),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Card(
                    color: const Color(0xFFEDF2FA),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Summary Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSummaryRow(
                              icon: Icons.person,
                              label: 'PATIENT:',
                              value: patientName ?? 'Loading...',
                            ),
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              icon: Icons.location_on,
                              label: 'REASON:',
                              value: widget.appointment.reason,
                            ),
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              icon: Icons.healing,
                              label: 'SPECIALITY:',
                              value: widget.appointment.specialty,
                            ),
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              icon: Icons.person_outline,
                              label: 'DOCTOR:',
                              value: doctorName ?? 'Loading...',
                            ),
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              icon: Icons.access_time,
                              label: 'TURN:',
                              value: widget.appointment.date,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await postAppointment(widget.appointment);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Confirm and Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label $value',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
