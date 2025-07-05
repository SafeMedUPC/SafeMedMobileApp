import 'dart:math';
import 'dart:async';

import '../domain/heart_rate.dart';
import 'heart_rate_repository.dart';


class HeartRateRepositoryImpl implements HeartRateRepository {
  @override
  Stream<HeartRate> getHeartRateStream() async* {
    final random = Random();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 1500)); // 1.5 segundos
      yield HeartRate(
        timestamp: DateTime.now(),
        bpm: 60 + random.nextInt(120), // Genera BPM entre 60 y 180
      );
    }
  }
}
