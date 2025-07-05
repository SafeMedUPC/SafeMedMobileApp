import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/heart_rate.dart';
import '../../repositories/heart_rate_repository.dart';
import '../../repositories/heart_rate_repository_impl.dart';
import '../../usescases/get_hear_rate_stream.dart';

// Provider para el repositorio de ritmo cardíaco
final heartRateRepositoryProvider = Provider<HeartRateRepository>((ref) {
  return HeartRateRepositoryImpl(); // Implementación concreta del repositorio
});

// El controlador que obtiene el stream de ritmo cardíaco
final heartRateControllerProvider =
StreamProvider.autoDispose<List<HeartRate>>((ref) {
  final useCase = GetHeartRateStream(ref.watch(heartRateRepositoryProvider));
  final List<HeartRate> data = [];

  return useCase().map((rate) {
    data.add(rate);
    if (data.length > 20) data.removeAt(0); // Muestra los últimos 20 datos
    return List<HeartRate>.from(data);
  });
});
