import 'dart:convert';
import 'dart:io';

import 'package:medsystem_app/features/treatments/domain/treatment.dart';
import 'package:http/http.dart' as http;

class TreatmentsService {
  final baseUrl = 'http://10.0.2.2:8080/api/v1/treatments';
  Future<List<Treatment>> getTreatments() async {
    Uri uri = Uri.parse(baseUrl);
    http.Response response = await http.get(uri);
    if (response.statusCode == HttpStatus.ok) {
      List maps = jsonDecode(response.body);
      return maps.map((json) => Treatment.fromJson(json)).toList();
    }
    return [];
  }
}
