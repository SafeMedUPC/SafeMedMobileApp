import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/heart_rate.dart';
import 'heart_rate_repository.dart';

class HeartRateRepositoryImpl implements HeartRateRepository {
  final String apiUrl =
      'https://med-system-edge.vercel.app/edge/bpm/data'; // Asegúrate de tener el backend corriendo

  @override
  Stream<List<HeartRate>> getHeartRateStream() async* {
    while (true) {
      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final List<dynamic> dataList = decoded['data'];

          final List<HeartRate> heartRates = dataList.map((item) {
            final double bpmDouble = item['processed_bpm'];
            final int bpm = bpmDouble.toInt();
            final int timestampInt = int.tryParse(item['timestamp']) ??
                DateTime.now().millisecondsSinceEpoch;

            return HeartRate(
              timestamp: DateTime.fromMillisecondsSinceEpoch(timestampInt),
              bpm: bpm,
            );
          }).toList();

          yield heartRates.takeLast(20).toList(); // solo los últimos 20
        } else {
          print('API Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Fetch error: $e');
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }
}

extension<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length > n ? length - n : 0);
}
