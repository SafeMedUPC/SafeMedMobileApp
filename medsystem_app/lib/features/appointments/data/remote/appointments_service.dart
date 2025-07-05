import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medsystem_app/features/appointments/domain/appointment.dart';
import 'package:http/http.dart' as http;

class AppointmentsService {
  final baseUrl = 'http://10.0.2.2:8080/api/v1';

  // Obtener el rol del usuario autenticado desde Firebase Firestore
  Future<String?> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return userDoc['role'];
        }
      } catch (e) {
        print('Error al obtener el rol del usuario: $e');
      }
    }
    return null;
  }

  Future<int?> getUserIdByUid(String uid, String role) async {
    String endpoint = role == 'Patient' ? 'patients' : 'doctors';
    Uri uri = Uri.parse('$baseUrl/$endpoint/uid/$uid');
    http.Response response = await http.get(uri);

    if (response.statusCode == HttpStatus.ok) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['id'];
    }
    return null;
  }

  Future<List<Appointment>> getAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    String? role = await getUserRole();
    if (role == null) {
      return [];
    }

    int? userId = await getUserIdByUid(user.uid, role);
    if (userId == null) {
      return [];
    }

    Uri uri;

    if (role == 'Patient') {
      uri = Uri.parse('$baseUrl/appointments/patientId/$userId');
    } else if (role == 'Doctor') {
      uri = Uri.parse('$baseUrl/appointments/doctorId/$userId');
    } else {
      return [];
    }

    http.Response response = await http.get(uri);
    if (response.statusCode == HttpStatus.ok) {
      List maps = jsonDecode(response.body);
      return maps.map((json) => Appointment.fromJson(json)).toList();
    }
    return [];
  }
}
